//
//  ArtistDetailView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/6/21.
//

import SwiftUI

struct NowPlayingArtistDetailView: View {
            
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
			
	@StateObject
	var player : Player = Player.shared
	
	@EnvironmentObject
	var viewControls : ViewControls
	
	@State
	var navigateAway : Bool = false
		    
    @ObservedObject
    var networkingManager : NetworkingManager = NetworkingManager.shared
	
	var artist : Artist
	
	@State
	var newArtist : Artist?
                
	init(artist: Artist) {
				
		self.artist = artist
		
        self.fetchRequest = FetchRequest(
            entity: Album.entity(),
			sortDescriptors: [
				NSSortDescriptor(key: #keyPath(Album.favorite), ascending: false),
				NSSortDescriptor(key: #keyPath(Album.productionYear), ascending: false)
			],
			predicate: NSPredicate(format: "albumArtistName == %@", self.artist.name!)
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
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        if artist.favorite {
                            networkingManager.unfavorite(jellyfinId: artist.jellyfinId!, originalValue: artist.favorite, complete: { result in
                                artist.favorite = result
                            })
                        } else {
                            networkingManager.favoriteItem(jellyfinId: artist.jellyfinId!, originalValue: artist.favorite, complete: { result in
                                artist.favorite = result
                            })
                        }
                    }, label: {
                        if artist.favorite {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.accentColor)
                                .font(.largeTitle)
                        } else {
                            Image(systemName: "heart")
                                .font(.largeTitle)
                        }
                    })
                        .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding(.bottom, 15)

                ForEach(albums) { album in
                    AlbumRow(album: album, artist: artist)
                        .listRowSeparator(albums.last! == album ? .hidden : .visible)
                }
            }
            .listStyle(PlainListStyle())
			.onAppear {
				self.viewControls.showArtistView = false
				self.viewControls.currentView = .NowPlayingArtistDetail
				self.navigateAway = false
				self.newArtist = nil
			}
			.onChange(of: self.viewControls.showArtistView, perform: { newValue in
				if newValue && viewControls.currentView == .NowPlayingArtistDetail{
					
					if newArtist == nil {
						if let currentArtist = player.currentArtist {
							
							self.newArtist = currentArtist
															
							self.navigateAway = true
						}
					}
				}
			})
			
			if self.newArtist != nil {
				NavigationLink(destination: NowPlayingArtistDetailView(artist: newArtist!), isActive: $navigateAway, label: {})
					.isDetailLink(false)
			}
        }
        .navigationTitle(artist.name ?? "Unknown Artist")
    }
}
