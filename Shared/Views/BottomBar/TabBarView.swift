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
    var miniplayerExpanded : Bool = false
    
    @State
    var miniplayerPresented : Bool = true
            
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
            PlayerSheetView()
        })
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

//        TabView(selection: $selectedTab) {
//
//            // Artists Tab
//            PlayerView(content: ArtistsView())
//                    .tag(1)
//                    .tabItem {
//                        Label("Artists", systemImage: "music.mic")
//                    }
//
//
//            // Albums Tab
//            PlayerView(content: AlbumsView())
//                .tag(2)
//                .tabItem {
//                    Label("Albums", systemImage: "square.stack.fill")
//                }
//
//            // Songs Tab
//            PlayerView(content: SongsView())
//                .tag(3)
//                .tabItem {
//                    Label("Songs", systemImage: "music.note")
//                }
//
//            // Playlists Tab
//            PlayerView(content: PlaylistsView())
//                .tag(4)
//                .tabItem {
//                    Label("Playlists", systemImage: "music.note.list")
//                }
//
//            // Settings View
//            PlayerView(content: SettingsView())
//                .tag(5)
//                .tabItem {
//                    Label("Settings", systemImage: "gear")
//                }
//        }
    }
}
