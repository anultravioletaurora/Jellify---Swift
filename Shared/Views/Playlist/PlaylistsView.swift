//
//  PlaylistsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI
import CoreData

struct PlaylistsView: View {
        
    var playlists: FetchedResults<Playlist>{
        fetchRequest.wrappedValue
    }
    
    var fetchRequest: FetchRequest<Playlist>
            
    let librarySelectionService = LibrarySelectionService.shared
    
    let playlistHelper = PlaylistHelper.shared
    
    let editing = true
    
    @StateObject
    var searchBar = SearchBarViewModel()
	
	// ID for the list, this will get regenerated when the user searches so that we generate a new list, this is because there are rerendering issues with searching on large lists where list items overlap with the navigation header
	@State
	var listId = UUID()
        
    var networkingManager = NetworkingManager.shared
            
    init() {
        self.fetchRequest = FetchRequest(
            entity: Playlist.entity(),
            sortDescriptors: [
				 NSSortDescriptor(key: #keyPath(Playlist.favorite), ascending: false),
				NSSortDescriptor(key: #keyPath(Playlist.sortName), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
			]
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
						
						Spacer()
						
						if playlist.favorite {
							Image(systemName: "heart.fill")
								.foregroundColor(.accentColor)
						}
                    }
                })
                .swipeActions {
                    Button(action: {
                        networkingManager.deletePlaylist(playlist: playlist)
                    }) {
                        Text("Delete")
                    }
                    .tint(.red)
                }
            }
			.id(listId)
            // This overlay prevents list content from appearing behind the tab view when dismissing the player
            .overlay(content: {
                BlurView()
                    .offset(y: UIScreen.main.bounds.height - 150)
            })
            .listStyle(PlainListStyle())
            .searchable(text: $searchBar.search, prompt: "Search playlists")
            .disableAutocorrection(true)
            .onReceive(searchBar.$search.debounce(for: .seconds(1), scheduler: DispatchQueue.main))
            {
				listId = UUID()
				
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
