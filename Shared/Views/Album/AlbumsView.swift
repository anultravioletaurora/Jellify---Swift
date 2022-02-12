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
        
    var fetchRequest: FetchRequest<Album>
    
    var albums: FetchedResults<Album>{
        fetchRequest.wrappedValue
    }

    @State
    var albumResults : [AlbumResult] = []

    @State
    var search: String = ""
    
    @StateObject
    var searchBar = SearchBarViewModel()
    
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
                NavigationLink(destination: AlbumDetailView(album: album)) {
                    HStack {
                        AlbumThumbnail(album: album)
                        
                        Text(album.name ?? "Unknown Album")
                    }
                }
            }
            .padding(.bottom, 66)
            .searchable(text: $searchBar.search, prompt: "Search albums")
            .disableAutocorrection(true)
            .onReceive(searchBar.$search.debounce(for: .seconds(0.5), scheduler: DispatchQueue.main))
            {
                guard !$0.isEmpty else {
                    albums.nsPredicate = nil
                    return
                }
                albums.nsPredicate = searchBar.search.isEmpty ? nil : NSPredicate(format: "%K contains[c] %@", #keyPath(Album.name), searchBar.search.trimmingCharacters(in: .whitespaces))
            }

            .listStyle(PlainListStyle())
            .navigationTitle("Albums")
            .toolbar(content: {
                ToolbarItem(content: {
                    Button(action: {
                        print("syncing library")
                    }, label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    })
                        .buttonStyle(PlainButtonStyle())

                })
            })
        }
    }
}
