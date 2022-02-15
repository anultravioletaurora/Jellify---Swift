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
    
    @State
    var miniplayerPresented = true
    
    @State
    var miniplayerExpanded = false
    
//    @EnvironmentObject
//    var player : Player
            
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
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
        .popup(isBarPresented: $miniplayerPresented, isPopupOpen: $miniplayerExpanded, popupContent: {
            PlayerSheetView(miniplayerExpanded: $miniplayerExpanded)
        })
        .popupBarProgressViewStyle(.top)
        .popupBarMarqueeScrollEnabled(true)
        .popupBarContextMenu {
            Button(action: {
                print("yeet")
            }) {
                Text("Yeet")
                Image(systemName: "globe")
            }
        }
        .onAppear {
            print("yeet")
        }
    }
}
