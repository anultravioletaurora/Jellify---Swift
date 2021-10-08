//
//  ContentView.swift
//  Shared
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI

struct ContentView: View {
        
    var body: some View {
        
        
        
        /**
        If the user is not yet auth'd, then we will prompt them to login
        */
        if true {
            LoginView()
        }
        
        /**
         Else render the app, since *hacker noise* they're in
         */
        else {
            TabBarView()
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
