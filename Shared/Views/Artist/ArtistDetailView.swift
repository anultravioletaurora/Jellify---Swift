//
//  ArtistDetailView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/6/21.
//

import SwiftUI

struct ArtistDetailView: View {
    
    @Environment(\.managedObjectContext)
    var managedObjectContext
        
    var fetchRequest: FetchRequest<Album>
    
    var albums: FetchedResults<Album>{
        fetchRequest.wrappedValue
    }

    @State
    var albumResults : [AlbumResult] = []
    
    @State
    var search : String = ""
    
    @State
    var loading : Bool = true
        
    var artist : Artist
                
    init(_ artist: Artist) {

        self.artist = artist
        self.fetchRequest = FetchRequest(
            entity: Album.entity(),
            sortDescriptors: [NSSortDescriptor(key: "productionYear", ascending: false)],
            predicate: NSPredicate(format: "albumArtistName == %@", artist.name!)
        )
    }
    
    var body: some View {
                   
        VStack {
            
            List {
                
                HStack {
                    Spacer()
                    ArtistImage(artist: artist)
                    Spacer()
                }
                .listRowSeparator(.hidden)

                ForEach(albums) { album in
                    AlbumRow(album: album, artist: artist)
                        .padding(.bottom, albums.last! == album ? 65 : 0)
                        .listRowSeparator(albums.last! == album ? .hidden : .visible)

                }
            }
            .listStyle(PlainListStyle())
//        .searchable(text: $search, prompt: "Search \(artist.name ?? "Unknown Artist") albums")
//        .onChange(of: search, perform: { newSearch in
//            albums.nsPredicate = newSearch.isEmpty ? nil : NSPredicate(format: "%K contains[c] %@", #keyPath(Album.name), newSearch)
//
//        })
        }
        .navigationTitle(artist.name ?? "Unknown Artist")
    }
}
