//
//  PlaylistsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI
import CoreData

struct PlaylistsView: View {
    
    @Environment(\.managedObjectContext)
    var managedObjectContext
    
    @FetchRequest(
        entity: Playlist.entity(),
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
    )
    var playlists: FetchedResults<Playlist>
    
    let playlistService = PlaylistService.shared
    
    let songService = SongService.shared
    
    let albumService = AlbumService.shared
    
    let editing = true
    
    @State
    var loading : Bool = true
        
    init() {

    }
    
    var body: some View {
        NavigationView {
            
            if loading {
                ProgressView()
            } else {
                
                List(playlists) { playlist in
                    
                    NavigationLink(destination: {
                        PlaylistDetailView(playlist: playlist)
                    }, label: {
                        Text(playlist.name ?? "Unknown Playlist")
                    })

                }
                .listStyle(PlainListStyle())
                .padding(.bottom, 60)
                .navigationTitle("Playlists")
                .refreshable {
                    self.forceFetchPlaylists()
                }
            }
        }
        .onAppear(perform: {
            
            self.fetchPlaylists()
            })
    }
    
    func deletePlaylists() {

        for playlist in self.playlists {
            managedObjectContext.delete(playlist)
        }
    }
    
    func fetchPlaylists() {
        if self.playlists.isEmpty {
            forceFetchPlaylists()
        }
        
        loading = false
    }
    
    func forceFetchPlaylists() {
        
        loading = true
        
        deletePlaylists()
        
        playlistService.retrievePlaylists(complete: { playlistsResult in
            
            for playlistResult in playlistsResult.items {
                let playlist = Playlist(context: managedObjectContext)
                
                playlist.jellyfinId = playlistResult.id
                playlist.name = playlistResult.name
                                
                playlistService.retrieveSongsFromPlaylist(playlistId: playlistResult.id, complete: { songResults in
                    
                    var index = 1
                    
                    for songResult in songResults.items {
                        
                        // Associate it with the album
                        albumService.retrieveAlbum(albumId: songResult.albumId, complete: { album in

                    
                        print("Adding to playlist: \(index) - \(songResult.name) - \(album.name) - \(playlist.name!)")
                        
                        let playlistSong = PlaylistSong(context: managedObjectContext)
                        
                        playlistSong.jellyfinId = songResult.playlistItemId!
                        playlistSong.indexNumber = Int16(index)
                        
                        let fetchRequest: NSFetchRequest<Song>
                        fetchRequest = Song.fetchRequest()

                        fetchRequest.predicate = NSPredicate(
                            format: "jellyfinId == %@", songResult.id
                        )
                        
                        do {
                            let songs : [Song] = try managedObjectContext.fetch(fetchRequest)
                            
                            let song = songs.first ?? Song(context: managedObjectContext)
                                                        
                            // Check if we've already got this song stored in CoreData
                            if song.jellyfinId == nil {
                                      
                                print("Fetching playlist item song from API")
                                       
                                buildSongFromResult(song: song, songResult: songResult, playlistSong: playlistSong, playlist: playlist, album: album)
                                
                                    print("Added to playlist: \(index) - \(playlistSong.song!.name) - \(playlistSong.song!.album!.name) - \(playlist.name!)")
                                                                    
                                // TODO: Associate it with the album artist
                            } else {
                                print("Playlist item already had song in CoreData, yay!")
                                
                                playlistSong.song = song
                                
                                playlistSong.playlist = playlist
                                
//                                print("Added to playlist: \(index) - \(playlistSong.song!.name) - \(playlistSong.song!.album!.name) - \(playlist.name!)")
                                
//                                try managedObjectContext.save()

                            }

                        } catch {
                            print(error)
                        }
                            
                            print(playlist.songs!)
                                                        
                        index += 1
                        })
                    }
                    
                    do {
                        try managedObjectContext.save()
                    } catch {
                        print(error)
                    }
                    
                    loading = false
                })
            }
        })
    }
    
    func buildSongFromResult(song: Song, songResult: SongResult, playlistSong: PlaylistSong, playlist: Playlist, album: Album) -> PlaylistSong {
        // Create the song and store it
        song.jellyfinId = songResult.id
        song.name = songResult.name
        playlistSong.song = song
        
        // TODO: Make album optional on song so that we can save here
//                                try! managedObjectContext.save()
        
            song.album = album
            
            playlistSong.song = song
            
            playlistSong.playlist = playlist
        
        if playlistSong.song == nil || playlistSong.song!.album == nil {
            print("WTF")
        }

        return playlistSong
    }
}
