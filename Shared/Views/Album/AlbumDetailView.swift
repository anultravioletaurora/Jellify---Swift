//
//  AlbumDetailView.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 10/8/21.
//

import SwiftUI

struct AlbumDetailView: View {
    
    @Binding
    var album: AlbumResult
    
    @State
    var songs: [SongResult] = []
    
    var songService: SongService = SongService.shared
    
    var body: some View {
        
        
        HStack {
            
            // Album Image
//            Image("profile")
//                .resizable()
//                .frame(width: 64, height: 64, alignment: .leading)
//                .clipShape(Circle())
//                .padding()
            
            // Favorite Album Button
//            Button(action: {
//                // TODO: Make API call to favorite artist
//                print("Album favorited")
//                album.userData!.isFavorite.toggle()
//            }) {
//                HStack {
//
//                    if album.userData != nil && album.userData!.isFavorite {
//                        Image(systemName: "heart.fill")
//                        Text("Favorited")
//                    } else {
//                        Image(systemName: "heart")
//                        Text("Favorite")
//                    }
//                }
//                .tint(.accentColor)
//            }
//            .frame(maxWidth: .infinity)
//            .buttonStyle(.bordered)
                
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
        
        List(songs) { song in
            
            HStack(alignment: .center, spacing: 15, content: {
                
                Text(song.indexNumber != nil ? String(song.indexNumber!) : "")
                    .padding(.trailing, 5)

                VStack(alignment: .leading, spacing: 10) {
                    Text(song.name)
                }

                Spacer()
            })
                .onTapGesture(perform: {
                    print("Playing \(song.name)")
                })
        }
        .listStyle(PlainListStyle())
        .onAppear(perform: {
            
            songService.retrieveSongs(albumId: album.id, complete: { songs in
                self.songs = songs.items
            })
        })
        .navigationTitle(album.name)
    }
    
//    func getSongDuration(runTimeTicks: Int) {
//        TimeSpan duration = new TimeSpan(runTimeTicks)
//        double minutes = duration;
//    }
}
