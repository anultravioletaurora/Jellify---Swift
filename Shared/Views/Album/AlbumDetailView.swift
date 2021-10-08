//
//  AlbumDetailView.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 10/8/21.
//

import SwiftUI

struct AlbumDetailView: View {
    
    @Binding
    var album: Album
    
    var body: some View {
        
        
        HStack {
            
            // Album Image
//            Image("profile")
//                .resizable()
//                .frame(width: 64, height: 64, alignment: .leading)
//                .clipShape(Circle())
//                .padding()
            
            // Favorite Artist Button
            Button(action: {
                // TODO: Make API call to favorite artist
                print("Artist favorited")
                album.favorite.toggle()
            }) {
                HStack {

                    if album.favorite {
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
            .navigationTitle(album.name)
    }
}
