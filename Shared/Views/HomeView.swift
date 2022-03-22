//
//  HomeView.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 3/4/22.
//

import SwiftUI

struct HomeView: View {
	
	var playlistFetchRequest: FetchRequest<Playlist>
	
	var playlists: FetchedResults<Playlist> {
		playlistFetchRequest.wrappedValue
	}
	
	var albumFetchRequest: FetchRequest<Album>
	
	var albums: FetchedResults<Album> {
		albumFetchRequest.wrappedValue
	}
	
	var artistFetchRequest: FetchRequest<Artist>
	
	var artists: FetchedResults<Artist> {
		artistFetchRequest.wrappedValue
	}
	
	@StateObject
	var player : Player = Player.shared
	
	@EnvironmentObject
	var viewControls : ViewControls
	
	@State
	var artistToView : Artist?
	
	@State
	var navigateAway : Bool = false
		
	init() {
				
		self.artistFetchRequest = FetchRequest(
			entity: Artist.entity(),
			sortDescriptors: [
				NSSortDescriptor(key: #keyPath(Artist.favorite), ascending: false),
				NSSortDescriptor(key: #keyPath(Artist.sortName), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
			],
			predicate: NSPredicate(format: "favorite == true")
		)
		
		self.playlistFetchRequest = FetchRequest(
			entity: Playlist.entity(),
			sortDescriptors: [
				NSSortDescriptor(key: #keyPath(Playlist.favorite), ascending: false),
				NSSortDescriptor(key: #keyPath(Playlist.sortName), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
			],
			predicate: NSPredicate(format: "favorite == true")
		)
				
		self.albumFetchRequest = FetchRequest(
			entity: Album.entity(),
			sortDescriptors: [
				NSSortDescriptor(key: #keyPath(Playlist.favorite), ascending: false),
				NSSortDescriptor(key: #keyPath(Playlist.sortName), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
			],
			predicate: NSPredicate(format: "favorite == true")
		)		
	}
	
    var body: some View {
		NavigationView {
			ScrollView {
				VStack(alignment: .leading) {
				
					if !playlists.isEmpty {
						
						Text("Playlists")
							.font(.headline)
						
						ScrollView(.horizontal, showsIndicators: false) {
							LazyHStack(alignment: .top) {
								ForEach(playlists) { playlist in
									
									NavigationLink(destination: PlaylistDetailView(playlist: playlist), label: {
										VStack {
											ItemThumbnail(itemId: playlist.jellyfinId!, frame: 150, cornerRadius: 10)
											
											Text(playlist.name ?? "Unknown Playlist")
												.font(.subheadline)
												.foregroundColor(.primary)
										}
										.frame(width: 150, height: 200)
									})
								}
							}
						}
						.padding(.bottom, 15)
					}
					
					
					if !artists.isEmpty {
						
						Text("Artists")
							.font(.headline)
						
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(alignment: .top) {
								ForEach(artists) { artist in
									
									NavigationLink(destination: ArtistDetailView(artist), label: {
										VStack {
											ItemThumbnail(itemId: artist.jellyfinId!, frame: 150, cornerRadius: 10)
											
											Text(artist.name ?? "Unknown Artist")
												.font(.subheadline)
												.foregroundColor(.primary)
										}
										.frame(width: 150, height: 200)
									})
								}
							}
						}
						.padding(.bottom, 15)
					}
									
					if !albums.isEmpty {
						
						Text("Albums")
							.font(.headline)
						
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(alignment: .top) {
								ForEach(albums) { album in
									
									NavigationLink(destination: AlbumDetailView(album: album), label: {
										VStack {
											ItemThumbnail(itemId: album.jellyfinId!, frame: 150, cornerRadius: 10)
											
											Text(album.name ?? "Unknown Album")
												.font(.subheadline)
												.foregroundColor(.primary)
											
											Text(album.albumArtistName ?? "Unknown Artist")
												.font(.subheadline)
												.opacity(Globals.componentOpacity)
												.foregroundColor(.primary)
										}
										.frame(width: 150, height: 200)
									})
								}
							}
						}
						.padding(.bottom, 15)
					}
				}
				.onAppear {
					self.viewControls.currentView = .Home
					self.viewControls.showArtistView = false
					self.navigateAway = false
					self.artistToView = nil
				}
				.onChange(of: self.viewControls.showArtistView, perform: { newValue in
					if newValue && self.viewControls.currentView == .Home {
						if let artist = player.currentArtist {
							
							self.artistToView = artist
							
							self.navigateAway = true
						}
					}
				})
				
				if self.artistToView != nil {
					NavigationLink(destination: NowPlayingArtistDetailView(artist: self.artistToView!), isActive: $navigateAway, label: {})
				}
			}
			.padding(.leading, 15)
			.navigationTitle("Home")
		}
		.navigationViewStyle(.stack)
    }
}
