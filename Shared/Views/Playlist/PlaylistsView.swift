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
    
    @StateObject
    var searchBar = SearchBarViewModel()
    
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
                            .listRowSeparator(playlists.last! == playlist ? .hidden : .visible)
                    }
                    .listStyle(PlainListStyle())
                    .searchable(text: $searchBar.search, prompt: "Search playlists")
                    .disableAutocorrection(true)
                    .onReceive(searchBar.$search.debounce(for: .seconds(1), scheduler: DispatchQueue.main))
                    {
                        guard !$0.isEmpty else {
                            playlists.nsPredicate = nil
                            return
                        }
                        playlists.nsPredicate = searchBar.search.isEmpty ? nil : NSPredicate(format: "%K contains[c] %@", #keyPath(Playlist.name), searchBar.search.trimmingCharacters(in: .whitespaces))
                    }
                    .navigationTitle("Playlists")
                    .toolbar(content: {
                        ToolbarItem(content: {
                            
                            SyncLibraryButton()

                        })
                    })
        }
    }
}
