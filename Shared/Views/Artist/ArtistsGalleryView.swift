//
//  ArtistsGalleryView.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/17/22.
//

import SwiftUI

struct ArtistsGalleryView: View {
    
    var artists : FetchedResults<Artist>
    
    @StateObject
    var searchBar = SearchBarViewModel()
    
    @State
    var columns : [GridItem] = Array(repeating: .init(.flexible()), count: 3)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(artists) { artist in
                    
                    NavigationLink(destination: ArtistDetailView(artist), label: {
                        VStack {
                            ArtistImage(artist: artist)
                            
                            Text(artist.name ?? "Unknown Artist")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        .frame(height: 150)
                    })
                }
            }
        }
        .searchable(text: $searchBar.search, prompt: "Search artists")
        .disableAutocorrection(true)
        .onReceive(
            searchBar.$search.debounce(for: .seconds(Globals.debounceDuration), scheduler: RunLoop.main)
        ) {            
            guard !$0.isEmpty else {
                artists.nsPredicate = nil
                return
            }
            
            artists.nsPredicate = searchBar.search.isEmpty ? nil : NSPredicate(format: "%K beginswith[c] %@", #keyPath(Artist.name), searchBar.search.trimmingCharacters(in: .whitespaces))
        }
    }
}
