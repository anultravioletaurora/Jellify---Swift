//
//  PlayerSongMenu.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/19/22.
//

import SwiftUI

struct PlayerSongMenu: View {
    
    @ObservedObject
    var player = Player.shared
    
    var downloadManager = DownloadManager.shared
    
    @Binding
    var showPlaylistSheet: Bool
    
    @Binding
    var selectedSong: Song?
    
    var body: some View {
        Menu(content: {
            Button(action: {
                
                selectedSong = player.currentSong!.song
                
                showPlaylistSheet.toggle()
            }, label: {
                Image(systemName: "text.badge.plus")
                
                Text("Add to Playlist")
            })
            
            if player.currentSong!.song.downloaded {
                Button(action: {
                    downloadManager.deleteSongDownload(song: player.currentSong!.song)
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
                    downloadManager.downloadSong(song: player.currentSong!.song)
                }, label: {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                        
                        Text("Download")
                    }
                })
            }

        }, label: {
            Image(systemName: "ellipsis.circle")
                .font(.largeTitle)
                .foregroundColor(.primary)
        })
            .buttonStyle(PlainButtonStyle())

    }
}
