//
//  PlayerSheetView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/22/21.
//

import SwiftUI
import AVFAudio
import MediaPlayer

struct PlayerSheetView: View {
        
    @ObservedObject
    var player = Player.shared
                
    @State
    private var airPlayView = AirPlayView()
    
    @Binding
    var miniplayerExpanded : Bool
    
    @State
    private var viewingQueue = false
    
    var height = UIScreen.main.bounds.height / 2.5

    @Environment(\.colorScheme)
    var colorScheme: ColorScheme
    
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass : UserInterfaceSizeClass?

    var body: some View {
        
        VStack {
            
            if horizontalSizeClass == .compact {
                VStack(alignment: .center) {
                    PlayerViewBody(viewingQueue: $viewingQueue, miniplayerExpanded: $miniplayerExpanded)
                }
            } else {
                HStack(alignment: .center) {
                    PlayerViewBody(viewingQueue: $viewingQueue, miniplayerExpanded: $miniplayerExpanded)
                }
                .padding(.horizontal, 30)
            }
        }
            .onChange(of: self.miniplayerExpanded, perform: { _ in
                self.viewingQueue = false
            })
            // Blurred album artwork background
            .background(content: {
                
                if player.currentSong?.song.album!.artwork != nil {
                    AlbumBackdropImage(album: player.currentSong!.song.album!)
                }
            })
            .popupProgress(player.playProgress)
            .popupTitle(player.currentSong?.song.name ?? "Nothing Playing", subtitle: player.currentSong?.song.album!.albumArtistName ?? nil)
            .popupImage(player.currentSong != nil ? Image(data: player.currentSong!.song.album!.artwork).resizable() :  Image("placeholder").resizable())
            .popupBarItems({
                HStack {
                    // Play / Pause music
                    Button(action: {
                        player.isPlaying.toggle()
                    }) {
                        if player.isPlaying {
                            Image(systemName: "pause.fill")
                                .font(.largeTitle)
                                .frame(width: 30, height: 30)
                                .padding(.trailing, 15)
                        } else {
                            Image(systemName: "play.fill")

                                .font(.largeTitle)
                                .frame(width: 30, height: 30)
                                .padding(.trailing, 15)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Skip track
                    Button(action: {
                        player.next()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.largeTitle)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            })
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

struct PlayerViewBody : View {
    
    @Binding
    var viewingQueue : Bool
    
    @ObservedObject
    var player = Player.shared
                
    @State
    private var airPlayView = AirPlayView()
    
    @Binding
    var miniplayerExpanded : Bool
        
    var height = UIScreen.main.bounds.height / 2.5

    @Environment(\.colorScheme)
    var colorScheme: ColorScheme

    
    var body : some View {
        
        VStack {
            if viewingQueue {
                
                Text("Now Playing")
                    .font(Font.headline)
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
                                    .font(.headline)
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
                .frame(width: height, height: height + 20)
                .background(Color.clear)
                .listStyle(PlainListStyle())
                .animation(Animation.easeInOut)
            } else {
                // Album Artwork
                if player.currentSong?.song.album != nil {
                    AlbumPlayingImage(album: player.currentSong!.song.album!)
                        .padding(.top, 30)
                        .animation(Animation.easeInOut)
                } else {
                    Image("placeholder")
                        .resizable()
                        .frame(width: height, height: height)
                        .cornerRadius(10)
                        .padding(.top, 30)
                    
                }
                
                // Song name text
                Text(player.currentSong?.song.name ?? "Nothing Playing")
                    .font(.title3)
                    .bold()

                VStack {
                    if player.currentSong?.song.artists!.count ?? 0 > 1 {
                        Text((player.currentSong!.song.artists?.allObjects as [Artist]).map { $0.name! }.joined(separator: ", "))
                            .font(.body)
                    } else {
                        Text(player.currentSong?.song.album!.albumArtistName! ?? "")
                            .font(.body)
                            .transition(.opacity)
                    }

                        // Album name text
                        Text(player.currentSong?.song.album?.name ?? "")
                            .font(.body)
                            .transition(.opacity)
                            .foregroundColor(.accentColor)
                    }
                .frame(width: height)
                }
        }
               
        VStack {
            ScrubberBarView()
//                    ProgressBarView()
//                        .padding(.all)
            
            HStack {
                // Skip track
                Button(action: {
                    player.previous()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.largeTitle)
                        .padding(25)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 30)

                // Play / Pause music
                Button(action: {
                    player.isPlaying.toggle()
                }) {
                    if player.isPlaying {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 50))
                            .padding(25)
                    } else {
                        Image(systemName: "play.fill")
                            .font(.system(size: 50))
                            .padding(25)
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
                        .padding(25)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 30)
            }
            
//                VStack {
//                    VolumeSlider()
//
//                    HStack {
//                        Image(systemName: "speaker.wave.1")
//                        Spacer()
//                        Image(systemName: "speaker.wave.3")
//                    }
//                }
//                .padding(.horizontal, 30)
//                Spacer()
            
                    
            HStack {
                    
                Spacer()
                
                Button(action: {
                    withAnimation {
                        viewingQueue.toggle()
                    }
                }, label: {
                    Image(systemName: "list.number")
                        .font(.title)
                        .foregroundColor(viewingQueue ? .accentColor : .primary)
                        .padding(25)
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
                            .padding(25)
                    case .repeatOne:
                        Image(systemName: "repeat.1")
                            .font(.title)
                            .foregroundColor(.accentColor)
                            .padding(25)
                    case .none:
                        Image(systemName: "repeat")
                            .font(.title)
                            .padding(25)
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
                        .padding(25)
                })
                    .buttonStyle(PlainButtonStyle())
                
                Spacer()

                Button(action: {
                    airPlayView.showAirPlayMenu()
                }) {
                    Image(systemName: "airplayaudio")
                        .font(.title)
                        .foregroundColor(player.player?.isExternalPlaybackActive ?? false ? .accentColor : .primary)
                        .padding(25)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, 60)
        }
    }
}
