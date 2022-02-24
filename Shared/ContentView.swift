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
    
    @EnvironmentObject
    var settings : Settings
        
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
            
            TabBarView()


            .onAppear(perform: {
                
                networkingManager.openSession()
                
                // Start up any downloads that haven't completed
                networkingManager.processDownloadQueue()
                
                // Sync library on app startup
                if settings.syncOnStartup {
                    networkingManager.syncLibrary()
                }
            })
            .transition(.opacity)
        }
    }
}
