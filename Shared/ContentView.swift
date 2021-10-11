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
    var artistService = ArtistService.shared
    
    @ObservedObject
    var librarySelectionService = LibrarySelectionService.shared
    
    @State
    var artists : [ArtistResult] = []
    
    @State
    var albums : [AlbumResult] = []
    

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
            TabBarView(artists: $artists)
                .onAppear(perform: {
                    artistService.retrieveArtists(complete: { result in
                        self.artists = result.items
                    })
                })
        }
    }
}
