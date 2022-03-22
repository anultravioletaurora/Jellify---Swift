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
	
	@EnvironmentObject
	var viewControls : ViewControls
	
	@EnvironmentObject
	var player : Player
	
	@State
	var artist : Artist?
	
	@State
	var artistToView : Artist?
	
	@State
	var navigateAway : Bool = false
    
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
//                artists.nsPredicate = NSPredicate(format: "albums.@count != 0")
				artists.nsPredicate = nil
                return
            }
            
            var searches = [searchBar.search.trimmingCharacters(in: .whitespaces)]
            
            if searchBar.search.contains("and") {
                searches.append(searchBar.search.replacingOccurrences(of: "and", with: "&").trimmingCharacters(in: .whitespaces))
            }
            
            var predicates = searches.map { search in
                NSPredicate(format: "%K contains[c] %@", #keyPath(Artist.name), search)
            }
			
//			predicates.append(NSPredicate(format: "albums.@count != 0"))
			
            artists.nsPredicate = searchBar.search.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        .listStyle(PlainListStyle())
		
		.onAppear {
			self.viewControls.currentView = .Artist
			self.viewControls.showArtistView = false
		}
		.onChange(of: self.viewControls.showArtistView, perform: { newValue in
			if newValue && self.viewControls.currentView == .Artist {
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
