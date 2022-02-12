import SwiftUI

struct SongRow: View {
    
    var song: Song
    
    @Binding
    var selectedSong: Song?
    
    var songs: [Song]
    
    @Binding
    var showPlaylistSheet: Bool
    
    var type : SongRowType
    
    var body: some View{
        Button(action: {
            print("Playing \(song.name ?? "Unknown Song")")
            
            Player.shared.loadSongs(Array(songs), songId: song.jellyfinId!)
            Player.shared.isPlaying = true
                            
            print("Playing!")
        }, label: {
            HStack(alignment: .center, content: {
                
                if type == .album {
                    VStack(alignment: .center, spacing: 10, content: {
                        Text(String(song.indexNumber))
                            .font(.subheadline)
                            .padding(.trailing, 5)
                    }).frame(width: 20)
                } else {
                    
                    if song.album != nil {
                        AlbumThumbnail(album: song.album!)
                    }
                }
                                        
                VStack(alignment: .leading, spacing: 10) {
                    Text(song.name ?? "Unknown Song")
                        .padding(.leading, 5)
                                     
                    if song.artists!.count > 1 {
                        Text((song.artists?.allObjects as [Artist]).map { $0.name! }.joined(separator: ", "))
                            .font(.subheadline)
                            .opacity(0.6)
                    }
                }
                
                Spacer()
            })
        })
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
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
    }
}

enum SongRowType {
    case album
    case songs
}
