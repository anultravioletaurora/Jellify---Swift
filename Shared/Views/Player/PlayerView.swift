//
//  Player.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/7/21.
//

import SwiftUI
import MediaPlayer

/**
 Component for the now playing bar that morphs into the full player UI
 */
struct PlayerView: View {
        
    @ObservedObject
    var player: Player = Player.shared
    
    @State
    var showMediaPlayer: Bool = false
    
    @State
    var seekPos = 0.0
    
    var animation: Namespace.ID
    
    var height = UIScreen.main.bounds.height / 2.5
    
    var artistService = ArtistService.shared
    
    var albumService = AlbumService.shared
    
    @State
    var offset : CGFloat = 0
                
    @ViewBuilder
    var body: some View {
        ZStack(alignment: .bottom) {
                        
            ZStack(alignment: .bottom) {
                HStack {
                    Button(action: {
                        
                        if (player.currentSong != nil) {
                            showMediaPlayer.toggle()
                        }
                    }) {
                        
                        HStack {
                            
                            if player.currentSong != nil {
                                CacheAsyncImage(
                                    url: URL(string:artistService.getAlbumArt(id: player.currentSong!.song.album!.jellyfinId!, maxSize: 1000))!
                                ) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .frame(width: 45, height: 45)
                                            .cornerRadius(5)
                                            .shadow(radius: 6, x: 0, y: 3)
                                            .padding(.leading)

                                    case .empty:
                                        ProgressView()
                                            .frame(width: 60, height: 60)
                                        
                                    @unknown default:
                                    Image(systemName: "music.mic")
                                            .resizable()
                                        .frame(width: 60, height: 60)
                                    }
                                }
                            }
                            
                            else {
                                Image(systemName: "opticaldisc")
                                        .resizable()
                                        .frame(width: 45, height: 45)
                                        .cornerRadius(5)
                                        .shadow(radius: 6, x: 0, y: 3)
                                        .padding(.leading)

                            }
                            
                            Text(player.currentSong?.song.name ?? "Nothing Playing")
                                .foregroundColor(player.currentSong == nil ? .gray : nil)
                                .bold()
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

                Divider()
            }
        }
//        .fullScreenCover(isPresented: $showMediaPlayer, onDismiss: {}, content: {
//            ZStack {
//
//                            Capsule()
//                                .fill(Color.gray)
//                                .frame(width: showMediaPlayer ? 60 : 0, height: showMediaPlayer ? 4 : 0)
//                                .offset(y: -height * 1.25)
//                                .opacity(showMediaPlayer ? 1 : 0)
//
//                            HStack {
//                                Button(action: {
//
//                                        if (!showMediaPlayer) {
//                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.87, blendDuration: 0.1)) {
//                                            showMediaPlayer.toggle()
//                                        }
//                                    }
//                                }) {
//
//                                    HStack {
//                                        // If the media player isn't expanded, then we'll display cover art and song info side-by-side
//                                        Image("profile")
//                                            .resizable()
//                                            .frame(width: showMediaPlayer ? height : 45, height: showMediaPlayer ? height: 45)
//                                            .cornerRadius(5)
//                                            .shadow(radius: 6, x: 0, y: 3)
//                                            .padding(showMediaPlayer ? .all : .leading)
//                                            .offset(y: showMediaPlayer ? -175 : 0)
//
//
//                                        if !showMediaPlayer {
//                                            Text(player.currentSong?.song.name ?? "Nothing Playing")
//                                                .bold()
//            //                                    .lineLimit(1)
//                                                .matchedGeometryEffect(id: "SongName", in: animation)
//                                        }
//                                    }
//                                }
//                                .buttonStyle(PlainButtonStyle())
//
//
//                                if !showMediaPlayer {
//
//                                    Spacer()
//
//                                    HStack {
//                                        // Play / Pause music
//                                        Button(action: {
//                                            player.isPlaying = !player.isPlaying
//                                        }) {
//                                            if player.isPlaying {
//                                                Image(systemName: "pause.fill")
//                                                    .font(.largeTitle)
//                                            } else {
//                                                Image(systemName: "play.fill")
//                                                    .font(.largeTitle)
//                                                    .frame(width: 30, height: 30)
//                                            }
//                                        }
//                                        .buttonStyle(PlainButtonStyle())
//                                        .padding(.horizontal)
//
//                                        // Skip track
//                                        Button(action: {
//                                            player.next()
//                                        }) {
//                                            Image(systemName: "forward.fill")
//                                                .font(.largeTitle)
//                                        }
//                                        .buttonStyle(PlainButtonStyle())
//                                        .padding(.trailing, 30)
//                                    }
//                                    .matchedGeometryEffect(id: "MusicControls", in: animation)
//                                }
//
//                            }
//
//                            if showMediaPlayer {
//                                VStack {
//
//                                    Text(player.currentSong?.song.name ?? "Nothing Playing")
//                                        .font(.title3)
//                                        .bold()
//                                        .matchedGeometryEffect(id: "SongName", in: animation)
//
//                                    Text(player.currentSong?.song.album?.name ?? "")
//                                        .font(.body)
//                                        .transition(.opacity)
//
//
//                                    Text(getWrappedArtists(artists: (player.currentSong?.song.artists)))
//                                        .font(.body)
//                                        .transition(.opacity)
//
//                                    ProgressBarView()
//                                        .padding(.all)
//
//                                    HStack {
//                                        // Skip track
//                                        Button(action: {
//                                            player.previous()
//                                        }) {
//                                            Image(systemName: "backward.fill")
//                                                .font(.title)
//                                        }
//                                        .buttonStyle(PlainButtonStyle())
//                                        .padding(.leading, 30)
//                                        .offset(x: -25)
//
//                                        // Play / Pause music
//                                        Button(action: {
//                                            player.isPlaying = !player.isPlaying
//                                        }) {
//                                            if player.isPlaying {
//                                                Image(systemName: "pause.fill")
//                                                    .font(.largeTitle)
//                                            } else {
//                                                Image(systemName: "play.fill")
//                                                    .font(.largeTitle)
//                                            }
//                                        }
//                                        .frame(width: 30, height: 30)
//                                        .buttonStyle(PlainButtonStyle())
//                                        .padding(.horizontal)
//
//                                        // Skip track
//                                        Button(action: {
//                                            player.next()
//                                        }) {
//                                            Image(systemName: "forward.fill")
//                                                .font(.largeTitle)
//                                        }
//                                        .buttonStyle(PlainButtonStyle())
//                                        .padding(.trailing, 30)
//                                        .offset(x: 25)
//                                    }
//            //                        .padding(.vertical)
//                                    .matchedGeometryEffect(id: "MusicControls", in: animation)
//                                }
//                                .frame(width: showMediaPlayer ? nil : 0, height: showMediaPlayer ? nil : 0)
//                                .offset(y: showMediaPlayer ? 125 : 0)
//                            }
//                        }
//                        .frame(width: UIScreen.main.bounds.size.width, height: showMediaPlayer ? UIScreen.main.bounds.size.height : 66)
//                        .padding(.vertical)
//                        .background(BlurView())
//                        .frame(maxHeight: showMediaPlayer ? .infinity : 66)
//                        .cornerRadius(showMediaPlayer ? 20 : 0)
//                        .offset(y: offset)
//                        .gesture(DragGesture()
//                                    .onEnded(onEnded(value:))
//                                    .onChanged(onChanged(value:)))
//
//                        .ignoresSafeArea()
//
//                        if !showMediaPlayer {
//                            Divider().transition(.opacity)
//                        }
//        })
        .offset(y: UIScreen.main.bounds.height / 3 + 19)
        .sheet(isPresented: $showMediaPlayer, onDismiss: {}, content: {

                        VStack {

                            CacheAsyncImage(
                                url: URL(string:artistService.getAlbumArt(id: player.currentSong!.song.album!.jellyfinId!, maxSize: 1000))!
                            ) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: height, height: height)
                                        .cornerRadius(10)
                                        .shadow(radius: 10, x: 0, y: 3)
                                    
                                case .empty:
                                    ProgressView()
                                        .frame(width: 60, height: 60)
                                    
                                @unknown default:
                                Image(systemName: "music.mic")
                                        .resizable()
                                    .frame(width: 60, height: 60)

                                }
                            }

                                    Text(player.currentSong?.song.name ?? "Nothing Playing")
                                        .font(.title3)
                                        .bold()
                                        .matchedGeometryEffect(id: "SongName", in: animation)

                                    Text(player.currentSong?.song.album?.name ?? "")
                                        .font(.body)
                                        .transition(.opacity)


                                    Text(getWrappedArtists(artists: (player.currentSong?.song.artists)))
                                        .font(.body)
                                        .transition(.opacity)

                                    ProgressBarView()
                                        .padding(.all)

                                    HStack {
                                        // Skip track
                                        Button(action: {
                                            player.previous()
                                        }) {
                                            Image(systemName: "backward.fill")
                                                .font(.title)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.leading, 30)
                                        .offset(x: -25)

                                        // Play / Pause music
                                        Button(action: {
                                            player.isPlaying = !player.isPlaying
                                        }) {
                                            if player.isPlaying {
                                                Image(systemName: "pause.fill")
                                                    .font(.largeTitle)
                                            } else {
                                                Image(systemName: "play.fill")
                                                    .font(.largeTitle)
                                            }
                                        }
                                        .frame(width: 30, height: 30)
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
                                        .offset(x: 25)
                                    }
                        }
                        .background(content: {
                            CacheAsyncImage(
                                url: URL(string:artistService.getAlbumArt(id: player.currentSong!.song.album!.jellyfinId!, maxSize: 1000))!
                            ) { phase in
                                switch phase {
                                case .success(let image):
                                    
                                    ZStack {
                                        
                                        BlurView()
                                        
                                        image
                                            .resizable()
                                            .frame(width: height * 3, height: height * 3)
                                            .cornerRadius(10)
                                            .blur(radius: 20, opaque: true)
                                            .brightness(-0.5).ignoresSafeArea()
                                    }
                                    
                                case .empty:
                                    ProgressView()
                                        .frame(width: 60, height: 60)
                                    
                                @unknown default:
                                Image(systemName: "music.mic")
                                        .resizable()
                                    .frame(width: 60, height: 60)

                                }
                            }
                        })
        })
        .padding()
    }
    
    func onChanged(value: DragGesture.Value) {
        if value.translation.height > 0 && showMediaPlayer {
            offset = value.translation.height
        }
    }
    
    func onEnded(value: DragGesture.Value) {
        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.87, blendDuration: 0)) {
            
            // Dismiss the fullscreen player if the user swipes down a little bit down the screen
            if value.translation.height > UIScreen.main.bounds.height / 5 {
                
                showMediaPlayer = false
            }
            
            offset = 0
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

            return artistNameArray.joined(separator: ",")
        }
    }
}
