//
//  ArtistDetailView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/6/21.
//

import SwiftUI

struct ArtistDetailView: View {
    
    let albumService : AlbumService = AlbumService.shared
    
    @State
    var albums : [AlbumResult] = []
        
    @Binding
    var artist : ArtistResult
                
    var body: some View {
                    
        HStack(alignment: .center, spacing: 5) {
                
            // Artist Image
//            Image("profile")
//                .resizable()
//                .frame(width: 64, height: 64, alignment: .leading)
//                .clipShape(Circle())
//                .padding()
            
            // Favorite Artist Button
            Button(action: {
                // TODO: Make API call to favorite artist
                print("Artist favorited")
                artist.userData.isFavorite.toggle()
            }) {
                HStack {
                    if artist.userData.isFavorite {
                        Image(systemName: "heart.fill")
                        Text("Favorited")
                    } else {
                        Image(systemName: "heart")
                        Text("Favorite")
                    }
                }
                .tint(.accentColor)
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.bordered)
                
            // Play Artist Button
            Button(action: {
                print("Playing artist")
            }) {
                
                HStack {
                    Image(systemName: "play.fill")
                    Text("Play")
                }
                .tint(.accentColor)
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.bordered)
            
            Button(action: {
                print("Shuffling artist")
            }) {
                
                HStack {
                    Image(systemName: "shuffle")
                    Text("Shuffle")
                }
                .tint(.accentColor)
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: true, vertical: true)
            
        List($albums) { $album in

            HStack {

                NavigationLink(destination: AlbumDetailView(album: $album)) {

                    HStack {
                        
                        // Album Image
//                        Image("profile")
//                            .resizable()
//                            .frame(width: 64, height: 64, alignment: .leading)
//                            .cornerRadius(5)

                        VStack(alignment: .leading) {

                            Text(album.name)
                                .font(.title3)

                            Text(album.productionYear != nil ? String(album.productionYear!) : "")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .swipeActions {
                Button(action: {
                    print("Artist album Swiped")
                }) {
                    Image(systemName: "heart")
                }
                .tint(.purple)
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(artist.name)
        .onAppear(perform: {
            // Fetch Albums
            albumService.retrieveAlbums(artistId: artist.id, complete: { result in
                self.albums = result.items
            })
        })
    }
}
