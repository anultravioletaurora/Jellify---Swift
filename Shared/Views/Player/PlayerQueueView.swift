//
//  PlayerQueueView.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 2/13/22.
//

import SwiftUI

struct PlayerQueueView: View {
    
    @EnvironmentObject
    var player : Player

    var height = UIScreen.main.bounds.height / 2.5
        
    @Environment(\.editMode)
    var editMode
    
    var body: some View {
            
        HStack {
            Text("Now Playing")
                .font(Font.title3)
                .bold()
            
            Spacer()
            
            EditButton()
        }
        .padding(.top, 30)
        .frame(width: height)
            
        List {
            
            ForEach(player.songs.suffix(from: player.songIndex)) { song in
                HStack {
                            
                    if player.currentSong != nil && song == player.currentSong! {
                        ZStack {
                            
                            AlbumThumbnail(album: song.song.album!)
                                .brightness(-0.3)
                            
                            NowPlayingIndicator()
                        }
                    } else {
                        AlbumThumbnail(album: song.song.album!)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(song.song.name!)

                        Text(Builders.artistName(song: song.song))
                            .font(.subheadline)
                    }
                }
                .listRowBackground(Color.clear)
                .onTapGesture(perform: {
                    player.next(song: song)
                })
            }
            .onDelete { indexSet in
                player.songs.remove(atOffsets: indexSet)
            }
            .onMove { indexSet, index in
                player.songs.move(fromOffsets: indexSet, toOffset: index)
            }
        }
        .frame(width: height, height: height + 40)
        .background(Color.clear)
        .listStyle(PlainListStyle())
        .animation(Animation.easeInOut)
    }
}
