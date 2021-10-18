//
//  PlaylistsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI

struct PlaylistsView: View {
    
    @Environment(\.managedObjectContext)
    var managedObjectContext
    
    var playlists: FetchedResults<Playlist>{
        fetchRequest.wrappedValue
    }
    
    var fetchRequest: FetchRequest<Playlist>

    let playlistService = PlaylistService.shared
    
    let songService = SongService.shared
    
    let albumService = AlbumService.shared
    
    let editing = true
        
    init() {
        self.fetchRequest = FetchRequest(
            entity: Playlist.entity(),
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
        )
    }
    
    var body: some View {
        NavigationView {
            
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
    }
    
    func forceFetchPlaylists() {
        
        deletePlaylists()
        
        playlistService.retrievePlaylists(complete: { playlistsResult in
            
            for playlistResult in playlistsResult.items {
                let playlist = Playlist(context: managedObjectContext)
                
                playlist.jellyfinId = playlistResult.id
                playlist.name = playlistResult.name
                
                var index = 0
                
                playlistService.retrieveSongsFromPlaylist(playlistId: playlistResult.id, complete: { songResults in
                    
                    for songResult in songResults.items {
                    
                        let song = Song(context: managedObjectContext)
                        
                        song.jellyfinId = songResult.id
                        song.name = songResult.name
                        
                        index += 1
                        song.indexNumber = Int16(index)
                        
                        albumService.retrieveAlbum(albumId: songResult.albumId, complete: { album in
                            song.album = album
                        })
                        
                        playlist.addToSongs(song)
                    }
                })                
            }
        })
    }
}
