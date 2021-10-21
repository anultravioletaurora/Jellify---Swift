//
//  PlaylistService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/12/21.
//

import Foundation
import JellyfinAPI

class PlaylistService : JellyfinService {
    
    static let shared = PlaylistService()
    
    override init() {
        super.init()
        
        JellyfinAPI.basePath = self.server
        setAuthHeader(with: self.accessToken)
    }
    
    func retrievePlaylists(complete: @escaping (ResultSet<PlaylistResult>) -> Void) {
        print("Retrieving playlists, access token is: \(self.accessToken)")
        
        self.get(url: "/Users/\(self.userId)/Items", params: [
            "parentId": self.playlistId
        ], completion: { data in
                               
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            print(json as Any)
            
            let playlistResult = try! self.decoder.decode(ResultSet<PlaylistResult>.self, from: data)
                                        
            complete(playlistResult)
        })
    }

    func retrieveSongsFromPlaylist(playlistId: String, complete: @escaping (ResultSet<SongResult>) -> Void) {
        
        print("Retrieving songs from playlist, ID is \(playlistId)")
        
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

            let songResult = try! self.decoder.decode(ResultSet<SongResult>.self, from: data)

            complete(songResult)
        })
    }
    
    func addToPlaylist(playlist: Playlist, song: Song) -> Void {
        PlaylistsAPI.addToPlaylist(playlistId: playlist.jellyfinId!, ids: [song.jellyfinId!], userId: self.userId, apiResponseQueue: JellyfinAPI.apiResponseQueue)
            .sink(receiveCompletion: { completion in
                print("Call to add song to playlist complete: \(completion)")
            }, receiveValue: { response in
                print("Playlist addition response: \(response)")
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
            })
            .store(in: &cancellables)
    }
}
