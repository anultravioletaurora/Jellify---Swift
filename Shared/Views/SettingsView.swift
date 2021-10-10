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
            Button(action: {
                
                authenticationService.logOut()
            }, label: {
                Text("Log out")
            })
            .navigationTitle("Settings")
        }    }
}
