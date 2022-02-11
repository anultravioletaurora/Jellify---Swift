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
//                    .overlay(
//                        PlayerView()
//                    )
        }
//        .onAppear(perform: {
//            
//            self.fetchPlaylists()
//            })
    }
}
