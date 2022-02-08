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
    
    @ObservedObject
    var networkingManager = NetworkingManager.shared
    
    init() {
        
        // Because of reasons I don't know, this is needed so that the tab bar doesn't
        // become transparent when returning to a previous navigation view with a list
        UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance.init(idiom: .unspecified)
    }

    var body: some View {
        
        
        
        /**
        If the user is not yet auth'd, then we will prompt them to login
        */
        if !authenticationService.authenticated {
            LoginView()
                .transition(.slide)
        }
        
        else if !librarySelectionService.selected {
            LibrarySelectionView()
        }
        
        /**
         Else render the app, since *hacker noise* they're in
         */
        else {
            
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
                

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
                        TabBarView()
                }
            })
            .onAppear(perform: {
                networkingManager.syncLibrary()
            })
        }
    }
}
