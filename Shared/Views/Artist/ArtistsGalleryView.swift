//
//  ArtistsGalleryView.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/17/22.
//

import SwiftUI
import SwiftUIX

struct ArtistsGalleryView: View {
    
    var artists : FetchedResults<Artist>
    
    @StateObject
    var searchBar = SearchBarViewModel()
    
    var columns : [GridItem] = Array(repeating: .init(.flexible()), count: 3)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(artists, id: \.jellyfinId) { artist in
                    ArtistGalleryItem(artist: artist)
                }
            }
            .padding(.top, 5)
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

struct ArtistGalleryItem: View {
    @ObservedObject
    var artist : FetchedResults<Artist>.Element
    
    var body: some View {
        NavigationLink(destination: ArtistDetailView(artist), label: {
            VStack {
                ArtistImage(artist: artist)
                
                Text(artist.name ?? "Unknown Artist")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        })
    }
}
