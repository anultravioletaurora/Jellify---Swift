//
//  SettingsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject
    var authenticationService = AuthenticationService.shared
    
    var body: some View {
        NavigationView {
            
            List {
                
                HStack {
                    
                    Text("User ID")
                    
                    Text(authenticationService.userId)
                }
                
                HStack {
                    Text("Access Token")
                    
                    Text(authenticationService.accessToken)
                }

                HStack {
                    Text("Music Library")
                    
                    Text(authenticationService.libraryId)
                }
                
                HStack {
                    Text("Playlist Library")
                    
                    Text(authenticationService.playlistId)
                }
                
                Button(action: {
                    authenticationService.deleteAllEntities()
                }, label: {
                    Text("Clear Data")
                })
                    .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    
                    authenticationService.logOut()
                }, label: {
                    Text("Log out")
                })
                    .buttonStyle(PlainButtonStyle())
            }
//            .overlay(PlayerView())
            .navigationTitle("Settings")
        }
                    }
}
