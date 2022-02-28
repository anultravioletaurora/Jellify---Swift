//
//  PlayerSongMenu.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/19/22.
//

import SwiftUI

struct PlayerSongMenu: View {
    
    @EnvironmentObject
    var player : Player

    var downloadManager = DownloadManager.shared
    
    var networkingManager = NetworkingManager.shared
    
    @Binding
    var showPlaylistSheet: Bool
    
    @Binding
    var selectedSong: Song?
    
    var body: some View {
        Menu(content: {

            if player.currentSong!.song.downloaded {
                Button(action: {
                    downloadManager.delete(song: player.currentSong!.song)
                }, label: {
                    Image(systemName: "trash.circle")
                    
                    Text("Remove Download")
                })
            } else if player.currentSong!.song.downloading {
                
                Button(action: {
                    
                }, label: {
                    HStack {
                        Text("Downloading")
                        
                        ProgressView()
                    }
                })
            } else {
                Button(action: {
                    downloadManager.download(song: player.currentSong!.song)
                }, label: {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                        
                        Text("Download")
                    }
                })
            }
            
            Button(action: {
                
                selectedSong = player.currentSong!.song
                
                showPlaylistSheet.toggle()
            }, label: {
                Image(systemName: "text.badge.plus")
                
                Text("Add to Playlist")
            })
            
            Button(action: {
                if player.currentSong!.song.favorite {
                    networkingManager.unfavorite(jellyfinId: player.currentSong!.song.jellyfinId!, originalValue: player.currentSong!.song.favorite, complete: { result in
                        player.currentSong!.song.favorite = result
                    })
                } else {
                    networkingManager.favoriteItem(jellyfinId: player.currentSong!.song.jellyfinId!, originalValue: player.currentSong!.song.favorite, complete: { result in
                        player.currentSong!.song.favorite = result
                    })
                }
            }, label: {
                if player.currentSong!.song.favorite {
                                        
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

        }, label: {
            Image(systemName: "ellipsis.circle")
                .font(.largeTitle)
                .foregroundColor(.primary)
        })
            .buttonStyle(PlainButtonStyle())

    }
}
