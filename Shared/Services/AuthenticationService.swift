//
//  AuthenticationService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/9/21.
//

import Foundation
import UIKit

class AuthenticationService : JellyfinService, ObservableObject {
    
    static let shared = AuthenticationService()
    
    @Published
    var accessToken = UserDefaults.standard.string(forKey: "AccessToken")
        
    func authenticate(server: String, username: String, password: String, completion: @escaping (Bool) -> Void) {

        login(username: username, password: password, server: server){ result in
                switch result {
                case true:
                    
                    UserDefaults.standard.set(username, forKey: "Username")
                    UserDefaults.standard.set(server, forKey: "Server")
                    completion(true)
                    
                    print("Authenticated successfully")

                case false:
                    
                    completion(false)
                    
                    print("Authentication failed")

                }
            }
        }
    
    func authenticated() -> Bool {
        return self.accessToken != nil
    }
    
    private func getAppCurrentVersionNumber() -> String {
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        return nsObject as! String
    }
    
    private func login(username: String, password: String, server: String, completion: @escaping (_ result: Bool) -> Void){

        print("Attempting to login user \(username)")
        
        let login = Login(username: username, password: password)
            
        let jsonData = try? self.encoder.encode(login)
        
        var request : URLRequest = URLRequest(url: URL(string: "\(server)/emby/Users/AuthenticateByName")!)
        
        request.httpMethod = HttpMethod.post.rawValue
        request.httpBody = jsonData
        
        request.setValue("MediaBrowser Client=\"jFin\", Device=\"\(UIDevice.current.name)\", DeviceId=\"\(UIDevice.current.model)\", Version=\"\(getAppCurrentVersionNumber())\"", forHTTPHeaderField: "X-Emby-Authorization")
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dataTask = urlSession.dataTask(with: request, completionHandler: { data, response, error in
                        
            // Check if the request succeeded
            if error == nil {
                                
                print("User \(username) authenticated")
                
                if let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                            print(jsonResult)
                        }
                
                let loginResult : LoginResult = try! self.decoder.decode(LoginResult.self, from: data!)
                
                debugPrint("Decoded Login Result: \(loginResult)")
                                
                self.setAccessToken(accessToken: loginResult.accessToken)
                completion(true)
            }
            
            // Else the request failed *sad trombone*
            else {
                
                print("Big sadge")
                completion(false)
            }
        })
        
        dataTask.resume()
    }
    
    func logOut() {
        UserDefaults.standard.removeObject(forKey: "AccessToken")
        self.accessToken = nil
    }
    
    private func setAccessToken(accessToken : String) -> Void {
        UserDefaults.standard.set(accessToken, forKey: "AccessToken")
        self.accessToken = accessToken
    }
}
