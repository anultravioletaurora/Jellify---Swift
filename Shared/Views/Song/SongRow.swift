import SwiftUI

struct SongRow: View {
    
    @ObservedObject
    var song: Song
    
    @Binding
    var selectedSong: Song?
    
    var songs: [Song]
    
    @Binding
    var showPlaylistSheet: Bool
    
    @ObservedObject
    var player : Player = Player.shared
    
    var downloadManager : DownloadManager = DownloadManager.shared
    
    var type : SongRowType
    
    var body: some View {
        Button(action: {
            player.loadSongs(Array(songs), songId: song.jellyfinId!)
            player.isPlaying = true
        }, label: {
            HStack(alignment: .center, content: {
                
                if type == .album {
                    VStack(alignment: .center, spacing: 10, content: {
                        Text(String(song.indexNumber))
                            .font(.subheadline)
                            .padding(.trailing, 5)
                            .opacity(0.6)
                    }).frame(width: 40)
                } else {
                    
                    if song.album != nil {
                        AlbumThumbnail(album: song.album!)
                    }
                }
                                        
                VStack(alignment: .leading, spacing: 10) {
                    Text(song.name ?? "Unknown Song")
                                     
                    if song.artists!.count > 2 {
                        Text((song.artists?.allObjects as [Artist]).map { $0.name! }.joined(separator: ", "))
                            .font(.subheadline)
                            .opacity(0.6)
                    } else if song.artists!.count > 1 {
                        Text((song.artists?.allObjects as [Artist]).map { $0.name! }.joined(separator: " & "))
                            .font(.subheadline)
                            .opacity(0.6)
                    } else if type == .songs {
                        Text(song.album!.albumArtistName!)
                            .font(.subheadline)
                            .opacity(0.6)
                    }
                }
                
                Spacer()
                
                if song.downloaded {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.accentColor)
                        .animation(Animation.easeInOut)
                }
            })
        })
        .padding(.horizontal, 10)
        .buttonStyle(PlainButtonStyle())
        .swipeActions {
            Button(action: {
                print("Artist Swiped")
            }) {
                Image(systemName: "heart")
            }
            .tint(.purple)
            
            Button(action: {
                print("Add to playlist sheet activated")
                selectedSong = song
                
                print("Showing playlist sheet for: \(selectedSong!.name)")
                
                showPlaylistSheet.toggle()
                
                print(showPlaylistSheet ? "Showing Playlist Sheet" : "Hiding Playlist Sheet")
            }) {
                Image(systemName: "music.note.list")
            }
            .tint(.blue)
        }
        .contextMenu {
            Button(action: {
                player.appendSongsNext([song])
            }, label: {
                HStack {
                    Image(systemName: "text.insert")

                    Text("Play Next")
                }
            })
            Button(action: {
                
                selectedSong = song
                
                showPlaylistSheet.toggle()
            }, label: {
                HStack {
                    Image(systemName: "text.badge.plus")
                    
                    Text("Add to Playlist")
                }
            })
            
            if song.downloaded {
                Button(action: {
                    downloadManager.deleteDownload(song: song)
                }, label: {
                    Image(systemName: "trash.circle")
                    
                    Text("Remove Download")
                })
            } else if song.downloading {
                ProgressView()
            } else {
                Button(action: {
                    downloadManager.download(song: song)
                }, label: {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                        
                        Text("Download")
                    }
                })
            }
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
