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
    
    var columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
    init() {
        self.fetchRequest = FetchRequest(
            entity: Album.entity(),
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
        )
    }
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    
                    // Search
                    HStack(spacing: 15) {
                        
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary)
                        
                        TextField("Search", text: $search)
                        
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(15)
                    
                    // Grid View of Albums
                    LazyVGrid(columns: columns){
                        ForEach(albums) { album in
                            
                            HStack {
                                Image("profile")
                                    .resizable()
                                    .frame(width: height, height: height, alignment: .center)
                                    .cornerRadius(15)
                                
                                Text(album.name ?? "Unknown Album")
                            }
                            
                        }
                    }
                    
                }
                .padding()
                .padding(.bottom, 60)
            }.navigationTitle("Albums")
        }
        .onAppear(perform: {
            
        })
    }
}
