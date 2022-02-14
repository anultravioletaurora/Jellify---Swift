//
//  AlbumsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI
import CoreData

struct AlbumsListView: View {
    
    @Environment(\.managedObjectContext)
    var managedObjectContext
        
    var fetchRequest: FetchRequest<Album>
    
    var albums: FetchedResults<Album>{
        fetchRequest.wrappedValue
    }
    
    @StateObject
    var searchBar = SearchBarViewModel()
    
    @Binding
    var limit: Int
    
    let PAGE_SIZE : Int = 1000

    init(limit: Binding<Int>) {
        
        self._limit = limit
        
        let request = NSFetchRequest<Album>(entityName: "Album")
        
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Album.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        
        request.fetchLimit = limit.wrappedValue
        
//        self.fetchRequest = FetchRequest(
//            entity: Album.entity(),
//            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
//        )
        
        self.fetchRequest = FetchRequest(fetchRequest: request, animation: nil)
    }
    
    var body: some View {
    
        List(albums) { album in
            NavigationLink(destination: LazyNavigationView(AlbumDetailView(album: album))) {
                HStack {
                    AlbumThumbnail(album: album)
                    
                    Text(album.name ?? "Unknown Album")
                }
            }
            .onAppear {
                if album == albums.last! && albums.count >= limit {
                    print("Last album of total: \(albums.count), increasing limit")
                    
                    self.limit += PAGE_SIZE
                    
                    print("New limit: \(self.limit)")

                } else if album == albums.last! {
                    print("Last album of total: \(albums.count)")
                }
            }
        }
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
    }
}
