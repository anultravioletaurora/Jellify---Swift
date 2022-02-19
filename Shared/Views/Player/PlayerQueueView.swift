//
//  PlayerQueueView.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 2/13/22.
//

import SwiftUI

struct PlayerQueueView: View {
    
    @ObservedObject
    var player = Player.shared
    
    var height = UIScreen.main.bounds.height / 2.5
    
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme
    
    var body: some View {
            
            Text("Now Playing")
                .font(Font.title3)
                .bold()
                .padding(.top, 30)
            
            List(player.songs.suffix(from: player.songIndex)) { song in
                HStack {
                                                
                    if player.currentSong != nil && song == player.currentSong! {
                        ZStack {
                            
                            AlbumThumbnail(album: song.song.album!)
                                .brightness(colorScheme == .dark ? -0.3 : 0.3)
                            
                            Image(systemName: "speaker.wave.3")
                                .font(.title)
                        }
                    } else {
                        AlbumThumbnail(album: song.song.album!)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(song.song.name!)

                        if song.song.artists!.count ?? 0 > 1 {
                            Text((song.song.artists?.allObjects as [Artist]).map { $0.name! }.joined(separator: ", "))
                                .font(.subheadline)
                                .transition(.opacity)
                        } else {
                            Text(song.song.album!.albumArtistName! ?? "")
                                .font(Font.subheadline)
                                .transition(.opacity)
                        }

                    }
                }
                .listRowBackground(Color.clear)
                .onTapGesture(perform: {
                    player.next(song: song)
                })
            }
            .frame(width: height, height: height + 40)
            .background(Color.clear)
            .listStyle(PlainListStyle())
            .animation(Animation.easeInOut)
        }
}
