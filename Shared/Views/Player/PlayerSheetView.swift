//
//  PlayerSheetView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/22/21.
//

import SwiftUI

struct PlayerSheetView: View {
    
    let artistService = ArtistService.shared
    
    @ObservedObject
    var player = Player.shared
    
    var height = UIScreen.main.bounds.height / 2.5
    
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme
    
    @Binding
    var showMediaPlayer : Bool
    
    var body: some View {

        VStack(alignment: .center) {

                        // Album Artwork
            if player.currentSong!.song.album != nil {
                AlbumPlayingImage(album: player.currentSong!.song.album!)
            }
            
                // Song name text
                Text(player.currentSong?.song.name ?? "Nothing Playing")
                    .font(.title3)
                    .bold()

                // Artist(s) name(s) text
                Text(getWrappedArtists(artists: (player.currentSong?.song.artists)))
                    .font(.body)
                    .transition(.opacity)

                // Album name text
                Text(player.currentSong?.song.album?.name ?? "Unknown Album")
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
                            
                // Dismiss player sheet button
                Button(action: {
                    showMediaPlayer.toggle()
                }, label: {
                    Image(systemName: "chevron.down")
                        .font(.largeTitle)
                })
                .buttonStyle(PlainButtonStyle())
            }
    
                // Blurred album artwork background
            .background(content: {
                
                if player.currentSong!.song.album!.artwork != nil {
                    AlbumBackdropImage(album: player.currentSong!.song.album!)
                }
//                        CacheAsyncImage(
//                            url: URL(string:artistService.getAlbumArt(id: player.currentSong!.song.album!.jellyfinId!, maxSize: 1000))!
//                        ) { phase in
//                            switch phase {
//                            case .success(let image):
//
//                                ZStack {
//
//                                    BlurView()
//
//                                    image
//                                        .resizable()
//                                        .frame(width: height * 3, height: height * 3)
//                                        .cornerRadius(10)
//                                        .blur(radius: 20, opaque: true)
//                                        .brightness(colorScheme == .dark ? -0.5 : 0.5).ignoresSafeArea()
//                                }
//
//                            case .empty:
//                                ProgressView()
//                                    .frame(width: 60, height: 60)
//
//                            @unknown default:
//                            Image(systemName: "music.mic")
//                                    .resizable()
//                                .frame(width: 60, height: 60)
//
//                            }
//                        }
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

            return artistNameArray.joined(separator: ",")
        }
    }
