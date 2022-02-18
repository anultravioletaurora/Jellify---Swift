//
//  ArtistsListView.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/17/22.
//

import SwiftUI

struct ArtistsListView: View {
    
    var artists : FetchedResults<Artist>
    
    @StateObject
    var searchBar = SearchBarViewModel()
    
    // ID for the list, this will get regenerated when the user searches so that we generate a new list, this is because there are rerendering issues with searching on large lists where list items overlap with the navigation header
    @State
    var listId = UUID()
    
    var body: some View {
        // Artists List
        // TODO: Turn this into a sectioned list with alphabetical seperators
        List(artists) { artist in
            ArtistRow(artist: artist)
                .listRowSeparator(artists.last! == artist ? .hidden : .visible)
        }
        .id(listId)
        .animation(nil, value: UUID())
        .searchable(text: $searchBar.search, prompt: "Search artists")
        .disableAutocorrection(true)
        .onReceive(
            searchBar.$search.debounce(for: .seconds(Globals.debounceDuration), scheduler: RunLoop.main)
        ) {
            listId = UUID()
            
            guard !$0.isEmpty else {
                artists.nsPredicate = nil
                return
            }
            
            artists.nsPredicate = searchBar.search.isEmpty ? nil : NSPredicate(format: "%K beginswith[c] %@", #keyPath(Artist.name), searchBar.search.trimmingCharacters(in: .whitespaces))
        }
        .listStyle(PlainListStyle())
    }
}
