//
//  TabBar.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/6/21.
//

import SwiftUI
import LNPopupUI

struct TabBarView: View {
                           	
    var body: some View {
        
        print(Self._printChanges())

        return TabView {
            
			HomeView()
				.tabItem {
					Label("Home", systemImage: "music.note.house.fill")
				}
			
            // Artists Tab
            ArtistsView()
                    .tabItem {
                        Label("Artists", systemImage: "music.mic")
                    }

            
            // Albums Tab
            AlbumsView()
                .tabItem {
                    Label("Albums", systemImage: "square.stack.fill")
                }
			
			// Playlists Tab
			PlaylistsView()
				.tabItem {
					Label("Playlists", systemImage: "music.note.list")
				}
            
            // Songs Tab
            SongsView()
                .tabItem {
                    Label("Songs", systemImage: "music.note")
                }

            // Settings View
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
