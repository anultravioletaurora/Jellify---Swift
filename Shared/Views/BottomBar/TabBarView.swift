//
//  TabBar.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/6/21.
//

import SwiftUI
import LNPopupUI

struct TabBarView: View {
                    
    @State
    var selectedTab : Int = 1
                    
    var body: some View {
        
        print(Self._printChanges())

        return TabView(selection: $selectedTab) {
            
            // Artists Tab
            ArtistsView()
                    .tag(1)
                    .tabItem {
                        Label("Artists", systemImage: "music.mic")
                    }

            
            // Albums Tab
            AlbumsView()
                .tag(2)
                .tabItem {
                    Label("Albums", systemImage: "square.stack.fill")
                }
            
            // Songs Tab
            SongsView()
                .tag(3)
                .tabItem {
                    Label("Songs", systemImage: "music.note")
                }
            
            // Playlists Tab
            PlaylistsView()
                .tag(4)
                .tabItem {
                    Label("Playlists", systemImage: "music.note.list")
                }

            // Settings View
            SettingsView()
                .tag(5)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
