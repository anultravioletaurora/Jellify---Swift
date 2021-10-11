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
            
            VStack {
                
                HStack {
                    Text("User ID: \(UserDefaults.standard.string(forKey: "UserId") ?? "")")
                }
                
                HStack {
                    Text("Access Token: \(UserDefaults.standard.string(forKey: "AccessToken") ?? "")")
                }

                HStack {
                    Text("Music Library ID: \(UserDefaults.standard.string(forKey: "LibraryId") ?? "")")
                }
                
                Button(action: {
                    
                    authenticationService.logOut()
                }, label: {
                    Text("Log out")
                })
            }
            .navigationTitle("Settings")
        }    }
}
