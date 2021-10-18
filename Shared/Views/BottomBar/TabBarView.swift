//
//  TabBar.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/6/21.
//

import SwiftUI

struct TabBarView: View {
    
    @State var uiTabarController: UITabBarController?

    @State private var isShowingSheet = false
    
    @State
    var showMediaPlayer = false
        
    @Namespace
    var animation
    
    @State
    var selectedTab : Int = 1
        
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            // Artists Tab
            ArtistsView()
                .tag(1)
                .tabItem {
                    Image(systemName: "music.mic")
                    Text("Artists")
                }
            
            // Albums Tab
            AlbumsView()
                .tag(2)
                .tabItem {
                    Image(systemName: "square.stack.fill")
                    Text("Albums")
                }
            
            // Songs Tab
            SongsView()
                .tag(3)
                .tabItem {
                    Image(systemName: "music.note")
                    Text("Songs")
                }
            
            // Playlists Tab
            PlaylistsView()
                .tag(4)
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Playlists")
                }

            // Settings View
            SettingsView()
                .tag(5)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .edgesIgnoringSafeArea(.top)

        .overlay(
            PlayerView(animation: animation)

//                .offset(y: showMediaPlayer ? 0 : UIScreen.main.bounds.height / 3 + 19)
        )
//        .introspectTabBarController(customize: { (UITabBarController) in
//            UITabBarController.back
//        })
    }
}
