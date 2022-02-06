//
//  AlbumsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI
import simd

struct AlbumsView: View {
    
    @Environment(\.managedObjectContext)
    var managedObjectContext
    
    var albumService = AlbumService.shared
    
    var fetchRequest: FetchRequest<Album>
    
    var albums: FetchedResults<Album>{
        fetchRequest.wrappedValue
    }

    @State
    var albumResults : [AlbumResult] = []

    @State
    var search: String = ""
    
    let height = UIScreen.main.bounds.height / 5
    
    @State
    var loading : Bool = false
    
    var columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
    init() {
        self.fetchRequest = FetchRequest(
            entity: Album.entity(),
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
        )
    }
    
    var body: some View {
        
        NavigationView {
            
            List(albums) { album in
                HStack {
                    AlbumThumbnail(album: album)
                    
                    Text(album.name ?? "Unknown Album")
                }
            }
            .padding()
            .padding(.bottom, 60)
            .navigationTitle("Albums")
        }
        .onAppear(perform: {
            if self.albums.isEmpty {
                
                loading = true

                albumService.retrieveAlbums(artist: nil, complete: {
                    loading = false
                })
            } else {
                loading = false
            }

        })
    }
}
