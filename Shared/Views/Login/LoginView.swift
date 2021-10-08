//
//  LoginView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/8/21.
//

import SwiftUI

struct LoginView: View {
    
    @State
    var serverUrl: String = ""
    
    @State
    var username: String = ""
    
    @State
    var password: String = ""
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                Image("profile")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .padding()
                
                HStack {
                    Image(systemName: "server.rack")
                    TextField("serverUrl", text: $serverUrl, prompt: Text("Enter Jellyfin Server URL"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        ._tightPadding()
                        .keyboardType(.alphabet)
                }
                
                HStack {
                    Image(systemName: "person.fill")
                    TextField("username", text: $username, prompt: Text("Enter Username"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        ._tightPadding()
                }
                
                HStack {
                    Image(systemName: "key.fill")
                    SecureField("password", text: $password, prompt: Text("Enter Password"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        ._tightPadding()
                }
                
                Button(action: {
                    print("I'm in!")
                }) {
                    
                        Text("Let me in!")
                        .font(.headline)
                        .padding()
                        .frame(width: nil, height: 50, alignment: .center)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(15)
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(DefaultButtonStyle())
            }
            .padding()
            .navigationTitle(Text("Welcome to FinTune"))
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
