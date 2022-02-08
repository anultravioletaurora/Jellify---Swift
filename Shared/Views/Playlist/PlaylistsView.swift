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
    
    var playlists: FetchedResults<Playlist>{
        fetchRequest.wrappedValue
    }
    
    var fetchRequest: FetchRequest<Playlist>
    
    let playlistService = PlaylistService.shared
    
    let songService = SongService.shared
    
    let albumService = AlbumService.shared
    
    let artistService = ArtistService.shared
    
    let librarySelectionService = LibrarySelectionService.shared
    
    let playlistHelper = PlaylistHelper.shared
    
    let editing = true
    
    @State
    var loading : Bool = true
            
    init() {
        self.fetchRequest = FetchRequest(
            entity: Playlist.entity(),
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Playlist.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        )

    }
    
    var body: some View {
        NavigationView {
            

                    List(playlists) { playlist in
                        
                        NavigationLink(destination: {
                            PlaylistDetailView(playlist: playlist)
                        }, label: {
                            
                            HStack {
                                PlaylistThumbnail(playlist: playlist)
                                
                                Text(playlist.name ?? "Unknown Playlist")
                            }
                        })

                    }
                    .listStyle(PlainListStyle())
                    .padding(.bottom, 60)
                    .navigationTitle("Playlists")
//                    .refreshable {
//                        self.forceFetchPlaylists()
//                    }
                    .overlay(
                        PlayerView()
                    )
        }
//        .onAppear(perform: {
//            
//            self.fetchPlaylists()
//            })
    }
    
    func deletePlaylists() {
        
        for playlist in self.playlists {
            
            for song in playlist.songs! {
                managedObjectContext.delete(song as! NSManagedObject)
            }
            
            managedObjectContext.delete(playlist)
        }        
    }
    
    func fetchPlaylists() {
        if self.playlists.isEmpty && !self.playlistService.playlistId.isEmpty {
            forceFetchPlaylists()
        } else if self.playlistService.playlistId.isEmpty {
            fetchPlaylistLibrary()
        } else {
            loading = false
        }
    }
    
    func fetchPlaylistLibrary() {
        librarySelectionService.retrieveLibraries(complete: { result in
            forceFetchPlaylists()
        })
    }
    
    func forceFetchPlaylists() {
        
        loading = true
        
        deletePlaylists()
        
        // If playlistId doesn't exist, we need to fetch it
        if playlistService.playlistId == "" {
            
        } else {
            retrievePlaylists()
        }
    }
    
    func retrievePlaylists() {
        playlistService.retrievePlaylists(complete: { playlistsResult in
            
            for playlistResult in playlistsResult.items {
                let playlist = playlistHelper.createPlaylistFromResult(result: playlistResult)
                
                playlistService.retrievePlaylistImage(playlist: playlist, complete: {
                    playlistService.retrieveSongsFromPlaylist(playlistId: playlistResult.id, playlist: playlist, complete: {
                        
                        print("Playlist song retrieval complete")
                        if playlistResult == playlistsResult.items.last! {
                            loading = false
                        }
                    })
                })
            }
        })
    }
}
