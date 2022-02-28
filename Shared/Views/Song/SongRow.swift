import SwiftUI

struct SongRow: View {
    
    @ObservedObject
    var song: FetchedResults<Song>.Element
    
    @Binding
    var selectedSong: Song?
    
    var songs: [Song]
    
    @Binding
    var showPlaylistSheet: Bool
    
    @EnvironmentObject
    var player : Player

    var downloadManager : DownloadManager = DownloadManager.shared
    
    var networkingManager : NetworkingManager = NetworkingManager.shared
        
    var type : SongRowType
    
    var body: some View {
        Button(action: {
            player.loadSongs(Array(songs), songId: song.jellyfinId!)
            player.isPlaying = true
        }, label: {
            HStack(alignment: .center, content: {
                
                if type == .album {
                    
                    if player.currentSong?.song == song {
                        NowPlayingIndicator()
                            .padding(.horizontal, 10)

                    } else {
                        VStack(alignment: .center, spacing: 10, content: {
                            Text(String(song.indexNumber))
                                .font(.subheadline)
                                .padding(.trailing, 5)
                                .opacity(Globals.componentOpacity)
                        }).frame(width: 50)
                    }
                } else {
                    
                    if song.album != nil {
                        
                        if player.currentSong?.song == song {
                            ZStack {
                                
                                AlbumThumbnail(album: song.album!)
                                    .brightness(-0.3)
                                
//                                SwimplyPlayIndicator(state: $player.audioState, count: 3, color: .accentColor, style: .legacy)
                                NowPlayingIndicator()
                            }
                        } else {
                            AlbumThumbnail(album: song.album!)
                        }
                    } else {
                        if player.currentSong?.song == song {
//                            SwimplyPlayIndicator(state: $player.audioState, count: 3, color: .accentColor, style: .legacy)
                            NowPlayingIndicator()
                        }
                    }
                }
                                        
                VStack(alignment: .leading, spacing: 10) {
                    
                    if player.currentSong?.song == song {
                        Text(song.name ?? "Unknown Song").foregroundColor(.accentColor)
                    } else {
                        Text(song.name ?? "Unknown Song")
                    }
                                     
                    if (type == .songs || (type == .album && song.artists?.count ?? 0 > 1)) {
                        Text(Builders.artistName(song: song))
                            .font(.subheadline)
                            .opacity(Globals.componentOpacity)
                    }
                }
                
                Spacer()
                
                if song.favorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.accentColor)
                }
                
                if song.downloaded {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.accentColor)
                        .animation(Animation.easeInOut)
                } else if song.downloading {
                    ProgressView()
                }
            })
        })
            .id(UUID())
        .padding(.horizontal, 10)
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: {
                if song.favorite {
                    networkingManager.unfavorite(jellyfinId: song.jellyfinId!, originalValue: song.favorite, complete: { result in
                        song.favorite = result
                    })
                } else {
                    networkingManager.favoriteItem(jellyfinId: song.jellyfinId!, originalValue: song.favorite, complete: { result in
                        song.favorite = result
                    })
                }
            }, label: {
                if song.favorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.accentColor)
                        .font(.largeTitle)
                    
                    Text("Favorited")
                } else {
                    Image(systemName: "heart")
                        .font(.largeTitle)
                    
                    Text("Favorite")
                }
            })
            
            Button(action: {
                player.appendSongsNext([song])
            }, label: {
                HStack {
                    Image(systemName: "text.insert")

                    Text("Play Next")
                }
            })
            
            Button(action: {
                player.appendSongsEnd([song])
            }, label: {
                HStack {
                    Image(systemName: "text.badge.plus")
                    
                    Text("Add to Queue")
                }
            })
            
            Button(action: {
                
                selectedSong = song
                
                showPlaylistSheet.toggle()
            }, label: {
                HStack {
                    Image(systemName: "plus.rectangle.on.rectangle")
                    
                    Text("Add to Playlist")
                }
            })
            
            Button(action: {
                
                if song.downloaded {
                    downloadManager.delete(song: song)
                } else {
                    downloadManager.download(song: song)
                }
            }, label: {
                
                if song.downloaded {
                    HStack {
                        Image(systemName: "trash.circle")
                        
                        Text("Remove Download")
                    }
                } else {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                        
                        Text("Download")
                    }
                }
            })
        }
    }
    
    private func playNext() {
        player.appendSongsNext([song])
    }
}

enum SongRowType {
    case album
    case songs
}
