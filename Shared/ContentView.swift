//
//  ContentView.swift
//  Shared
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI

struct ContentView: View {
        
    @ObservedObject
    var authenticationService = AuthenticationService.shared
    
    @ObservedObject
    var librarySelectionService = LibrarySelectionService.shared
    
    @StateObject
    var networkingManager = NetworkingManager.shared
    
    init() {
        
        // Because of reasons I don't know, this is needed so that the tab bar doesn't
        // become transparent when returning to a previous navigation view with a list
        UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance.init(idiom: .unspecified)
    }

    var body: some View {
        
        
        
        // Prompt the user to login if they haven't already
        // TODO: Fix this
        if !networkingManager.userIsLoggedIn {
            LoginView()
                .transition(.slide)
        }
        
        // Else if a library hasn't been selected yet, tell them to select a library
        else if !librarySelectionService.selected {
            LibrarySelectionView()
                .transition(.slide)
        }
        
        // Else have them start listening
        else {
            
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
                

                if networkingManager.libraryIsPopulated {
                    TabBarView()
                } else {
                    switch networkingManager.loadingPhase {
                        case .artists:
                            ProgressView("Loading Artists")
                        case .albums:
                            ProgressView("Loading Albums")
                        case .songs:
                            ProgressView("Loading Songs")
                        case .playlists:
                            ProgressView("Loading Playlists")
                        case .artwork:
                            ProgressView("Loading Artwork")
                        default:
                            ProgressView("Tuning in")
                    }
                }
            })
            .onAppear(perform: {
                
                // Sync library on app startup
                networkingManager.syncLibrary()
            })
            .transition(.opacity)
        }
    }
}
