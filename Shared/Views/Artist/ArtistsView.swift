//
//  ArtistsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI
import Combine

struct ArtistsView: View {
        
    var artists: FetchedResults<Artist>{
        fetchRequest.wrappedValue
    }
    
    var fetchRequest: FetchRequest<Artist>
    
    @Environment(\.managedObjectContext)
    var managedObjectContext
    
    @ObservedObject
    var networkingManager = NetworkingManager.shared
        
    @StateObject
    var searchBar = SearchBarViewModel()
        
    @FocusState
    var isSearchFocused : Bool
    
    init() {
                
        self.fetchRequest = FetchRequest(
            entity: Artist.entity(),
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Artist.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        )
    }
    
    var body: some View {
        NavigationView {
                                
            // Artists List
            // TODO: Turn this into a sectioned list with alphabetical seperators
            List(artists) { artist in
                ArtistRow(artist: artist)
                    .listRowSeparator(artists.last! == artist ? .hidden : .visible)
            }
            .id(UUID())
            .animation(nil, value: UUID())
            .searchable(text: $searchBar.search, prompt: "Search artists")
            .disableAutocorrection(true)
            .onReceive(
                searchBar.$search.debounce(for: .seconds(0.7), scheduler: DispatchQueue.main)
            ) {
                guard !$0.isEmpty else {
                    artists.nsPredicate = nil
                    return
                }
                
                artists.nsPredicate = searchBar.search.isEmpty ? nil : NSPredicate(format: "%K beginswith[c] %@", #keyPath(Artist.name), searchBar.search.trimmingCharacters(in: .whitespaces))
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Artists")
            .toolbar(content: {
                ToolbarItem(content: {
                    
                    if networkingManager.loadingPhase != nil {
                        ProgressView()
                    } else {
                        Button(action: {
                            print("syncing library")
                            networkingManager.syncLibrary()
                        }, label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        })
                            .buttonStyle(PlainButtonStyle())
                    }

                })
            })
        }
    }
}

class SearchBarViewModel : ObservableObject {
    @Published var search : String = ""
}
