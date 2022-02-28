//
//  AlbumsGalleryView.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 2/18/22.
//

import SwiftUI
import CoreData

struct AlbumsGalleryView: View {
    
    var fetchRequest: FetchRequest<Album>

    var albums: FetchedResults<Album>{
        fetchRequest.wrappedValue
    }
    
    @StateObject
    var searchBar = SearchBarViewModel()
    
    var columns : [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    @Binding
    var limit: Int
    
    init(limit: Binding<Int>) {
        
        self._limit = limit
        
        let request = NSFetchRequest<Album>(entityName: "Album")
        
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Album.sortName), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        
        request.fetchLimit = limit.wrappedValue
        
//        self.fetchRequest = FetchRequest(
//            entity: Album.entity(),
//            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]
//        )
        
        self.fetchRequest = FetchRequest(fetchRequest: request, animation: nil)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(albums) { album in
                    AlbumGalleryItem(album: album)
                        .onAppear {
                            if album == albums.last! && albums.count >= limit {
                                print("Last album of total: \(albums.count), increasing limit")
                                
                                self.limit += Globals.VIEW_FETCH_PAGE_SIZE
                                
                                print("New limit: \(self.limit)")

                            } else if album == albums.last! {
                                print("Last album of total: \(albums.count)")
                            }
                        }
                }
            }
            .searchable(text: $searchBar.search, prompt: "Search albums")
        }
        .disableAutocorrection(true)
        .onReceive(searchBar.$search.debounce(for: .seconds(Globals.debounceDuration), scheduler: DispatchQueue.main))
        {
            guard !$0.isEmpty else {
                albums.nsPredicate = nil
                return
            }
            
            var searches = [searchBar.search.trimmingCharacters(in: .whitespaces)]
            
            if searchBar.search.contains("and") {
                searches.append(searchBar.search.replacingOccurrences(of: "and", with: "&").trimmingCharacters(in: .whitespaces))
            }
            
            let predicates = searches.map { search in
                NSPredicate(format: "%K beginswith[c] %@", #keyPath(Album.name), search)
            }
            
            albums.nsPredicate = searchBar.search.isEmpty ? nil : NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        }
    }
}

struct AlbumGalleryItem: View {
    @ObservedObject
    var album : FetchedResults<Album>.Element
    
    var body: some View {
        NavigationLink(destination: LazyNavigationView(AlbumDetailView(album: album)), label: {
            VStack {
                AlbumImage(album: album, height: 100)
                
                Text(album.name ?? "Unknown Album")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        })
    }
}
