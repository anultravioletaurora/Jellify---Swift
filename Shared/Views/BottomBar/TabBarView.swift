//
//  TabBar.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/6/21.
//

import SwiftUI

struct TabBarView: View {
        
    @Binding
    var artists : [ArtistResult]
    
    var artistService = ArtistService.shared
        
    var body: some View {
                
            TabView {
                
                // Artists Tab
                ArtistsView(artists: $artists)
                    .tabItem {
                        Image(systemName: "music.mic")
                        Text("Artists")
                    }
                
                // Albums Tab
                AlbumsView()
                    .tabItem {
                        Image(systemName: "square.stack.fill")
                        Text("Albums")
                    }
                
                // Songs Tab
                SongsView()
                    .tabItem {
                        Image(systemName: "music.note")
                        Text("Songs")
                    }
                
                // Playlists Tab
                PlaylistsView()
                    .tabItem {
                        Image(systemName: "music.note.list")
                        Text("Playlists")
                    }
                
                // Settings View
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
            }
        
    }
}
