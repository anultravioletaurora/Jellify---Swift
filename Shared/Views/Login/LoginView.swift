//
//  LoginView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/8/21.
//

import SwiftUI

struct LoginView: View {
    
    @State
    var serverUrl: String = "https://"
    
    @State
    var username: String = ""
    
    @State
    var password: String = ""
    
    @State
    var loggingIn: Bool = false
    
    var authenticationService = AuthenticationService.shared
    
    var networkingManager = NetworkingManager.shared
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                // Splash Image
                Image("AppIcon")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .padding()
                
                // Server URL Input
                    
                HStack {
                    Image(systemName: "server.rack")
                    TextField("serverUrl", text: $serverUrl, prompt: Text("Enter Jellyfin Server URL"))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.alphabet)
                        ._tightPadding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                }
                                    
                // Username Input
                HStack {
                    Image(systemName: "person.fill")
                    TextField("username", text: $username, prompt: Text("Enter Username"))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        ._tightPadding()
                }
                
                // Password Input
                HStack {
                    Image(systemName: "key.fill")
                    TextField("password", text: $password, prompt: Text("Enter Password"))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        ._tightPadding()
                }
                
                // Submit Button
                Button(action: {
                    networkingManager.login(serverUrl: serverUrl, userId: username, password: password, complete: {
                        
                    })
                }) {
                    
                        Text("Let me in!")
                        .font(.headline)
                        .padding()
                        .frame(width: nil, height: 50, alignment: .center)
                        .foregroundColor(.white)
                        .background(Color.accentColor.opacity(loggingIn ? 0.3 : 1))
                        .cornerRadius(15)
                }
                .disabled(loggingIn)
                .frame(maxWidth: .infinity)
                .buttonStyle(DefaultButtonStyle())
            }
            .padding()
            .navigationTitle(Text("Sign In"))
        }
    }
}
