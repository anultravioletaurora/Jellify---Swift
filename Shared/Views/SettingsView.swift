//
//  SettingsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI

struct SettingsView: View {
    
    let networkingManager = NetworkingManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Current User")) {
                    HStack {
                        Text("User ID")
                        Spacer()
                        Text(networkingManager.userId)
                    }
                    
                    HStack {
                        Text("Access Token")
                        Spacer()
                        Text(networkingManager.accessToken)
                    }
                }
                
                Section(header: Text("Libraries")) {
                    HStack {
                        Text("Music Library ID")
                        Spacer()
                        Text(networkingManager.libraryId)
                    }
                    
                    HStack {
                        Text("Playlist Library ID")
                        Spacer()
                        Text(networkingManager.playlistId)
                    }
                }
                
                Section {
                    Button(action: {
                        networkingManager.logOut()
                    }, label: {
                        Text("Log out")
                    })
                        .buttonStyle(PlainButtonStyle())
                }
            }
//            .overlay(PlayerView())
            .navigationTitle("Settings")
        }
    }
}
