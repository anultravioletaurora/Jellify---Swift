//
//  PlayerSheetView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/22/21.
//

import SwiftUI
import AVFAudio
import MediaPlayer

struct NowPlayingView: View {
        
    @EnvironmentObject
    var player : Player

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
                VStack {
                    PlayerViewBody(viewingQueue: $viewingQueue, miniplayerExpanded: $miniplayerExpanded)
                }
            } else {
                HStack {
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
                
				if player.currentSong?.song.album != nil && player.currentSong?.song.album!.artwork != nil {
                    AlbumBackdropImage(album: player.currentSong!.song.album!)
                }
            })
            .popupTitle(player.currentSong?.song.name ?? "Nothing Playing", subtitle: Builders.artistName(song: player.currentSong?.song) )
			.popupImage(player.currentSong != nil && player.currentSong!.song.album != nil ? Image(data: player.currentSong!.song.album!.artwork).resizable() :  Image("placeholder").resizable())
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
    
    @EnvironmentObject
    var player : Player

    @State
    private var airPlayView = AirPlayView()
    
    @Binding
    var miniplayerExpanded : Bool
        
    var height = UIScreen.main.bounds.height / 2.5

    @Environment(\.colorScheme)
    var colorScheme: ColorScheme

    var downloadManager : DownloadManager = DownloadManager.shared
    
    @State
    var showPlaylistSheet = false
    
    @State
    var selectedSong : Song?
    
    var body : some View {
        
        VStack {
            if viewingQueue {
                PlayerQueueView()
            } else {
                
                VStack(alignment: .leading) {

                    // Album Artwork
                    if player.currentSong?.song.album != nil {
                        AlbumPlayingImage(album: player.currentSong!.song.album!)
                            .padding(.top, 30)
                            .animation(.easeInOut)
                    } else {
                        Image("placeholder")
                            .resizable()
                            .frame(width: height, height: height)
                            .cornerRadius(10)
                            .padding(.top, 30)
                        
                    }

                    HStack {
                        VStack(alignment: .leading) {
                            // Song name text
                            Text(player.currentSong?.song.name ?? "Nothing Playing")
                                .font(.title2)

                            Text(Builders.artistName(song: player.currentSong?.song ?? nil))

                            // Album name text
                            Text(player.currentSong?.song.album?.name ?? "")
                                .font(.headline)
                                .transition(.opacity)
                                .foregroundColor(.accentColor)
                        }
                        
                        Spacer()
                        
                        if player.currentSong != nil {
                            PlayerSongMenu(showPlaylistSheet: $showPlaylistSheet, selectedSong: $selectedSong)
                        }
                    }
                }
                .frame(width: height)
            }
        }
               
        VStack {
            
            ScrubberBarView()
                .padding(.bottom, 25)
                        
            HStack {
                // Skip track
                Button(action: {
                    player.previous()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.largeTitle)
                        .padding(.leading, 25)
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
                        .padding(.trailing, 25)
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
            
//            HStack {
//                Spacer()
//                
//                RoundedRectangle(cornerRadius: 25, style: .continuous)
//
//                Spacer()
//            }
                    
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
            .sheet(isPresented: $showPlaylistSheet, content: {
                PlaylistSelectionSheet(song: $selectedSong, showPlaylistSheet: $showPlaylistSheet)
            })
        }
    }
}
