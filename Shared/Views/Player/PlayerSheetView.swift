//
//  PlayerSheetView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/22/21.
//

import SwiftUI
import AVFAudio

struct PlayerSheetView: View {
        
    @ObservedObject
    var player = Player.shared
    
    var height = UIScreen.main.bounds.height / 2.5
    
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme
    
    @Binding
    var showMediaPlayer : Bool
    
    @State
    private var airPlayView = AirPlayView()
        
    var body: some View {

        NavigationView {
            VStack(alignment: .center) {
                
                Button(action: {
                    showMediaPlayer.toggle()
                }, label: {
                    Capsule()
                        .fill(Color.primary)
                        .frame(width: 40, height: 5)
                        .opacity(0.6)
                        .padding(.all, 10)
                })

                // Album Artwork
                if player.currentSong!.song.album != nil {
                    AlbumPlayingImage(album: player.currentSong!.song.album!)

                }
                
                    // Song name text
                    Text(player.currentSong?.song.name ?? "Nothing Playing")
                        .font(.title3)
                        .bold()

                if player.currentSong!.song.artists!.count > 1 {
                    Text((player.currentSong!.song.artists?.allObjects as [Artist]).map { $0.name! }.joined(separator: ", "))
                        .font(.body)
                } else {
                    Text(player.currentSong!.song.album!.albumArtistName!)
                        .font(.body)
                        .transition(.opacity)
                }
                    // Artist(s) name(s) text

                    // Album name text
                    Text(player.currentSong?.song.album?.name ?? "Unknown Album")
                        .font(.body)
                        .transition(.opacity)
                        .foregroundColor(.accentColor)
                        
                    ProgressBarView()
                        .padding(.all)

                    HStack {
                        // Skip track
                        Button(action: {
                            player.previous()
                        }) {
                            Image(systemName: "backward.fill")
                                .font(.largeTitle)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 30)

                        // Play / Pause music
                        Button(action: {
                            player.isPlaying = !player.isPlaying
                        }) {
                            if player.isPlaying {
                                Image(systemName: "pause.fill")
                                    .font(.system(size: 50))
                            } else {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 50))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 45, height: 45, alignment: .center)
                        .padding(.horizontal, 30)

                        // Skip track
                        Button(action: {
                            player.next()
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.largeTitle)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 80)
                    .padding(.top, 20)
                                
                    HStack {
                            
                        Spacer()
                        
                        NavigationLink(destination: {
                            Text("Queue")
                        }, label: {
                            Image(systemName: "list.number")
                                .font(.title)
                        })
                        
                        Spacer()
                        
                        Button(action: {
                            player.repeatMode.toggle()
                        }, label: {
                            
                            switch player.repeatMode {
                            case .reapeatAll:
                                Image(systemName: "repeat")
                                    .font(.title)
                                    .foregroundColor(.accentColor)
                            case .repeatOne:
                                Image(systemName: "repeat.1")
                                    .font(.title)
                                    .foregroundColor(.accentColor)
                            case .none:
                                Image(systemName: "repeat")
                                    .font(.title)
                            }
                        })
                            .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        // Dismiss player sheet button
//                        Button(action: {
//                            showMediaPlayer.toggle()
//                        }, label: {
//                            Image(systemName: "chevron.down")
//                                .font(.largeTitle)
//                        })
//                        .buttonStyle(PlainButtonStyle())
//
//                        Spacer()
                        
                        Button(action: {
                            player.playmode.toggle()
                        }, label: {
                            Image(systemName: "shuffle")
                                .font(.title)
                                .foregroundColor(player.playmode == .random ? .accentColor : .primary)
                        })
                            .buttonStyle(PlainButtonStyle())
                        
                        Spacer()

                        Button(action: {
                            airPlayView.showAirPlayMenu()
                        }) {
                            Image(systemName: "airplayaudio")
                                .font(.title)
                                .foregroundColor(player.player!.isExternalPlaybackActive ? .accentColor : .primary)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                }
                .offset(y: -65)
            
                // Blurred album artwork background
                .background(content: {
                    
                    if player.currentSong!.song.album!.artwork != nil {
                        AlbumBackdropImage(album: player.currentSong!.song.album!)
                    }
                })
            }
        .navigationViewStyle(.stack)
        }
    }
    
    func getWrappedArtists(artists: NSSet?) -> String {
                            
        if artists == nil {
            return ""
        } else {
            var artistNameArray : [String] = []

            artists!.forEach({ artist in
                artistNameArray.append((artist as! Artist).name ?? "")
            })

            return artistNameArray.joined(separator: ", ")
        }
    }
