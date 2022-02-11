//
//  Player.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/7/21.
//

import SwiftUI
import MediaPlayer
import Marquee

/**
 Component for the now playing bar that morphs into the full player UI
 */
struct PlayerView<Content: View>: View {
        
    var content : Content
    
    @ObservedObject
    var player: Player = Player.shared
    
    @State
    var showMediaPlayer: Bool = false
    
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme
    
    @State
    var seekPos = 0.0
        
    var height = UIScreen.main.bounds.height / 2.5
        
    @State
    var offset : CGFloat = 0
                
    @ViewBuilder
    var body: some View {
        ZStack(alignment: .bottom) {
            
            content
                        
            ZStack(alignment: .bottom) {
                HStack {
                    Button(action: {
                        
                        if (player.currentSong != nil) {
                            showMediaPlayer.toggle()
                        }
                    }) {
                        
                        HStack {
                            
                            if player.currentSong != nil {
                                
                                AlbumThumbnail(album: player.currentSong!.song.album!)
                                    .padding(.trailing, 5)
                            }
                            
                            else {
                                
                                Image("placeholder")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(2)
                                        .padding(.trailing, 5)

                            }
                                          
                            Marquee {
                                Text(player.currentSong?.song.name ?? "Nothing Playing")
                                    .bold()
                                    .foregroundColor(player.currentSong == nil ? .gray : nil)
                            }.marqueeWhenNotFit(true)
                                .marqueeDuration(10.0)
                        }
                        .transition(.opacity)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // Play / Pause music
                    Button(action: {
                        player.isPlaying.toggle()
                    }) {
                        if player.isPlaying {
                            Image(systemName: "pause.fill")
                                .font(.largeTitle)
                        } else {
                            Image(systemName: "play.fill")

                                .font(.largeTitle)
                                .frame(width: 30, height: 30)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)

                    // Skip track
                    Button(action: {
                        player.next()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.largeTitle)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 30)
                }
                .frame(width: UIScreen.main.bounds.size.width, height: 66)
                .background(BlurView())

                // Divider()
            }
            .onTapGesture {
                if (player.currentSong != nil) {
                    showMediaPlayer.toggle()
                }
            }
        }
        // Fullscreen player sheet
        .sheet(isPresented: $showMediaPlayer, onDismiss: {}, content: {
            PlayerSheetView(showMediaPlayer: $showMediaPlayer)
        })
    }
    
    func getWrappedArtists(artists: NSSet?) -> String {
                            
        if artists == nil {
            return ""
        } else {
            var artistNameArray : [String] = []

            artists!.forEach({ artist in
                artistNameArray.append((artist as! Artist).name ?? "")
            })

            return artistNameArray.joined(separator: ",")
        }
    }
}
