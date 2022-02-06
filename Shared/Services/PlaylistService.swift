//
//  PlaylistService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/12/21.
//

import Foundation
import JellyfinAPI
import CoreData

class PlaylistService : JellyfinService {
    
    static let shared = PlaylistService()
    
    let songHelper = SongHelper.shared
    
    let albumService = AlbumService.shared
    
    let artistService = ArtistService.shared
    
    override init() {
        super.init()
        
        JellyfinAPI.basePath = self.server
        setAuthHeader(with: self.accessToken)
    }
    
    func retrievePlaylists(complete: @escaping (ResultSet<PlaylistResult>) -> Void) {
        print("Retrieving playlists, access token is: \(self.accessToken)")
        
//        ItemsAPI.getItems(userId: self.userId, parentId: self.playlistId, enableImages: true, apiResponseQueue: JellyfinAPI.apiResponseQueue)
//            .sink(receiveCompletion: { completion in
//                print("Playlist response: \(completion)")
//            }, receiveValue: { response in
//                complete(response.items)
//            })
//            .store(in: &cancellables)
        
        self.get(url: "/Users/\(self.userId)/Items", params: [
            "parentId": self.playlistId
        ], completion: { data in
                               
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            print(json as Any)
            
            let playlistResult = try! self.decoder.decode(ResultSet<PlaylistResult>.self, from: data)
                                        
            complete(playlistResult)
        })
    }
    
    func retrievePlaylistImage(playlist: Playlist, complete: @escaping () -> Void) {
        ImageAPI.getItemImage(itemId: playlist.jellyfinId!, imageType: .primary)
            .sink(receiveCompletion: { result in
                print(result)
            }, receiveValue: { response in
                playlist.thumbnail = response
                complete()
            })
            .store(in: &cancellables)
    }

    func retrieveSongsFromPlaylist(playlistId: String, playlist: Playlist, complete: @escaping () -> Void) {
                
//        PlaylistsAPI.getPlaylistItems(playlistId: playlistId, userId: self.userId)
//            .sink(receiveCompletion: { complete in
//                print("Completed playlist song retrieval")
//            }, receiveValue: { response in
//                if response.items != nil {
//
//                    response.items!.map { (playlistItemDto) in
//                        var playlistSong = PlaylistSong(context: JellyfinService.context)
//
//                        playlistSong.jellyfinId = playlistItemDto.id!
//                        playlistSong.
//                    }
//                }
//            })
//            .store(in: &cancellables)
        
        self.get(url: "/Playlists/\(playlistId)/Items", params: [
            "UserId": self.userId
        ], completion: { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])

            print(json as Any)

            let songResults = try? self.decoder.decode(ResultSet<SongResult>.self, from: data)
            
            if songResults != nil {
                
                for songResult in songResults!.items {
                    
                    // Check if playlistSong already exists
                    if !self.playlistSongAlreadyExists(songResult: songResult) {
                        self.performPlaylistAssociation(playlist: playlist, songResult: songResult, songResults: songResults!, complete: complete)
                    }
                }
                
//                do {
//                    try managedObjectContext.save()
//                } catch {
//                    print(error)
//                }
            }})
    }
    
    func addToPlaylist(playlist: Playlist, song: Song, complete: @escaping () -> Void) -> Void {
        
        print("Adding \(song.name) to playlist \(playlist.name)")

        PlaylistsAPI.addToPlaylist(playlistId: playlist.jellyfinId!, ids: [song.jellyfinId!], userId: self.userId, apiResponseQueue: JellyfinAPI.apiResponseQueue)
            .sink(receiveCompletion: { completion in
                print("Call to add song to playlist complete: \(completion)")
            }, receiveValue: { response in
                print("Playlist addition response: \(response)")
                self.retrieveSongsFromPlaylist(playlistId: playlist.jellyfinId!, playlist: playlist, complete: {
                    print("Playlist addition and refresh")
                    complete()
                })
            })
            .store(in: &cancellables)
    }
    
    func deleteFromPlaylist(playlist: Playlist, playlistSong: PlaylistSong) -> Void {

        print("Removing \(playlistSong.song!.name!) - \(playlistSong.jellyfinId!) from playlist \(playlist.name!) - \(playlist.jellyfinId!)")
                
        PlaylistsAPI.removeFromPlaylist(playlistId: playlist.jellyfinId!, entryIds: [playlistSong.jellyfinId!], apiResponseQueue: JellyfinAPI.apiResponseQueue)
            .sink(receiveCompletion: { completion in
                print("Call to remove song from playlist complete: \(completion)")
            }, receiveValue: { response in

                print("Playlist removal response: \(response)")
                JellyfinService.context.delete(playlistSong)
                
                self.saveContext()
            })
            .store(in: &cancellables)
    }
        
    private func performPlaylistAssociation(playlist: Playlist, songResult: SongResult, songResults: ResultSet<SongResult>, complete: @escaping () -> Void) {
        
        
        
        // Associate it with the album
        self.albumService.retrieveAlbum(albumId: songResult.albumId, complete: { album in
                    
            let playlistSong = PlaylistSong(context: JellyfinService.context)
        
            playlistSong.jellyfinId = songResult.playlistItemId!
            playlistSong.indexNumber = Int16(songResults.items.firstIndex(of: songResult)!)
        
            let fetchRequest: NSFetchRequest<Song>
            fetchRequest = Song.fetchRequest()

            fetchRequest.predicate = NSPredicate(
                format: "jellyfinId == %@", songResult.id
            )
        
            do {
                
                // Can't save here otherwise no songs will be added to playlists
    //                            try managedObjectContext.save()

                let songs : [Song] = try JellyfinService.context.fetch(fetchRequest)
                
                let song = songs.first ?? Song(context: JellyfinService.context)
                                            
                // Check if we've already got this song stored in CoreData
                if song.jellyfinId == nil {
                                                             
                    self.artistService.retrieveArtist(artistId: songResult.artistItems.first!.name, complete: { artist in
                        
                        self.songHelper.associatePlaylistSongWithSong(song: song, songResult: songResult, playlistSong: playlistSong, playlist: playlist, album: album, artist: artist)
                        
                        if playlistSong.playlist == nil {
                            playlistSong.playlist = playlist
                        }
                        
                        if songResult == songResults.items.last {
                            self.saveContext()
                        }
                    })
                                                                                        
                } else {
                    playlistSong.song = song
                    
                    if playlistSong.playlist == nil {
                        playlistSong.playlist = playlist
                    }
                    
                    if songResult == songResults.items.last {
                        self.saveContext()
                        complete()
                    }
                }
            } catch {
                print(error)
            }
        })
    }
    
    private func playlistSongAlreadyExists(songResult: SongResult) -> Bool {
        let fetchRequest: NSFetchRequest<PlaylistSong>
        fetchRequest = PlaylistSong.fetchRequest()

        fetchRequest.predicate = NSPredicate(
            format: "song.jellyfinId == %@", songResult.id
        )
        
        do {
            return try JellyfinService.context.fetch(fetchRequest).first != nil
        } catch {
            print("Error fetching playlist song: \(error)")
            return false
        }
    }
}
