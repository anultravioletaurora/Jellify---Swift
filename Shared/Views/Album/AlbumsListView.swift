//
//  AlbumsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI
import CoreData

struct AlbumsListView: View {
            
    var fetchRequest: FetchRequest<Album>
    
    var albums: FetchedResults<Album>{
        fetchRequest.wrappedValue
    }
    
    @StateObject
    var searchBar = SearchBarViewModel()
	
	@EnvironmentObject
	var viewControls : ViewControls
	
	@EnvironmentObject
	var player : Player
    
    @Binding
    var limit: Int
        
    @State
    var listId = UUID()
	
	@State
	var artist : Artist?
	
	@State
	var artistToView : Artist?
	
	@State
	var navigateAway : Bool = false

    init(limit: Binding<Int>) {
        
        self._limit = limit
        
        let request = NSFetchRequest<Album>(entityName: "Album")
        
        request.sortDescriptors = [
			NSSortDescriptor(key: #keyPath(Album.favorite), ascending: false),
			NSSortDescriptor(key: #keyPath(Album.sortName), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        
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
                    
					VStack(alignment: .leading, spacing: 10) {
						Text(album.name ?? "Unknown Album")
						
						Text(album.albumArtistName ?? "Unknown Artist")
							.opacity(Globals.componentOpacity)
							.font(.subheadline)
					}
					
					Spacer()
					
					if album.favorite {
						Image(systemName: "heart.fill")
							.foregroundColor(.accentColor)
					}
                }
            }
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
        .id(listId)
        .searchable(text: $searchBar.search, prompt: "Search albums")
        .disableAutocorrection(true)
        .onReceive(searchBar.$search.debounce(for: .seconds(Globals.debounceDuration), scheduler: DispatchQueue.main))
        {
            listId = UUID()
            
            guard !$0.isEmpty else {
                albums.nsPredicate = nil
                return
            }
            albums.nsPredicate = searchBar.search.isEmpty ? nil : NSPredicate(format: "%K contains[c] %@", #keyPath(Album.name), searchBar.search.trimmingCharacters(in: .whitespaces))
        }

        .listStyle(PlainListStyle())
		.onAppear {
			self.viewControls.currentView = .Album
		}
		.onChange(of: self.viewControls.showArtistView, perform: { newValue in
			if newValue && self.viewControls.currentView == .Album {
				if let artist = player.currentArtist {
					
					self.artistToView = artist
					
					self.navigateAway = true
				}
			}
		})
		
		if self.artistToView != nil {
			NavigationLink(destination: NowPlayingArtistDetailView(artist: self.artistToView!), isActive: $navigateAway, label: {})
				.isDetailLink(false)
		}
    }
}
