//
//  TabBar.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/6/21.
//

import SwiftUI

struct TabBarView: View {
    
    @State
    var showMediaPlayer = false
    
    @Namespace
    var animation
    
    var body: some View {
        
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
        
            TabView {
                
                // Artists Tab
                NowPlayingBar(content: ArtistsView(), showMediaPlayer: $showMediaPlayer, animation: animation)
                    .tabItem {
                        Image(systemName: "music.mic")
                        Text("Artists")
                    }
                
                // Albums Tab
                NowPlayingBar(content: AlbumsView(), showMediaPlayer: $showMediaPlayer, animation: animation)
                    .tabItem {
                        Image(systemName: "square.stack.fill")
                        Text("Albums")
                    }
                
                // Songs Tab
                NowPlayingBar(content: SongsView(), showMediaPlayer: $showMediaPlayer, animation: animation)
                    .tabItem {
                        Image(systemName: "music.note")
                        Text("Songs")
                    }
                
                // Playlists Tab
                NowPlayingBar(content: PlaylistsView(), showMediaPlayer: $showMediaPlayer, animation: animation)
                    .tabItem {
                        Image(systemName: "music.note.list")
                        Text("Playlists")
                    }
                
                // Settings View
                NowPlayingBar(content: SettingsView(), showMediaPlayer: $showMediaPlayer, animation: animation)
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
            }
        })
    }
}
