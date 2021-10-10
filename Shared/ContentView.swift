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
    
    var body: some View {
        
        
        
        /**
        If the user is not yet auth'd, then we will prompt them to login
        */
        if !authenticationService.authenticated() {
            LoginView()
                .transition(.slide)
        }
        
        /**
         Else render the app, since *hacker noise* they're in
         */
        else {
            TabBarView().transition(.slide)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
