//
//  AuthenticationService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/9/21.
//

import Foundation
import UIKit

class AuthenticationService : JellyfinService {
    
    static let shared = AuthenticationService()
    
    @Published
    var authenticated : Bool = false
    
    override init() {
        super.init()
        self.authenticated = AuthenticationService.accessToken != nil
    }
            
    func authenticate(server: String, username: String, password: String, completion: @escaping (Bool) -> Void) {

        login(username: username, password: password, server: server){ result in
                switch result {
                case true:
                    
                    UserDefaults.standard.set(username, forKey: "Username")
                    UserDefaults.standard.set(server, forKey: "Server")
                    self.authenticated = true
                    completion(true)
                    
                    print("Authenticated successfully")

                case false:
                    self.authenticated = false
                    completion(false)
                    
                    print("Authentication failed")

                }
            }
        }
    
    private func getAppCurrentVersionNumber() -> String {
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        return nsObject as! String
    }
    
    private func login(username: String, password: String, server: String, completion: @escaping (_ result: Bool) -> Void){

        print("Attempting to login user \(username)")
        print("Device name: \(UIDevice.current.name)")
        print("Device model: \(UIDevice.current.model)")
        print("App Version: \(getAppCurrentVersionNumber())")
        
        let login = Login(username: username, password: password)
            
        let jsonData = try? self.encoder.encode(login)
        
        var request : URLRequest = URLRequest(url: URL(string: "\(server)/Users/AuthenticateByName")!)
        
        request.httpMethod = HttpMethod.post.rawValue
        request.httpBody = jsonData
        
        let deviceName : String = UIDevice.current.name
        print("Device Name: \(deviceName)")
        
        let deviceName2 : String = "Jack's iPhone"
        print("Device Name 2: \(deviceName2)")
        
        print("Device Names equal: \(deviceName == deviceName2)")
        
        request.setValue("MediaBrowser Client=\"FinTune\", Device=\"\(deviceName2)\", DeviceId=\"\(UIDevice.current.model)\", Version=\"\(getAppCurrentVersionNumber())\"", forHTTPHeaderField: "X-Emby-Authorization")
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("REQUEST BODY")
        print(jsonData)
        
        print("REQUEST HEADERS")
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
              print("\(key): \(value)")
           }

        let dataTask = urlSession.dataTask(with: request, completionHandler: { data, response, error in
                        
            if let httpResponse = response as? HTTPURLResponse {
                
                print("HTTP Response: \(httpResponse)")
            
            // Check if the request succeeded
                if error == nil && httpResponse.statusCode < 300{
                                    
                    print("User \(username) authenticated")
                    
                    print("DATA IS EMPTY: \(data == nil)")
                    
                    let received = String(data: data!, encoding: String.Encoding.utf8)

                    print(received)
                    
                    let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]

                    print(jsonData)
                    
                    let loginResult : LoginResult = try! self.decoder.decode(LoginResult.self, from: data!)
                    
                    debugPrint("Decoded Login Result: \(loginResult)")
                                    
                    self.setAccessDetails(loginResult: loginResult)
                    completion(true)
                }
                
                // Else the request failed *sad trombone*
                else {
                    
                    print("Big sadge")
                    completion(false)
                }
            }
        })
        
        dataTask.resume()
    }
    
    func logOut() {
        UserDefaults.standard.removeObject(forKey: "AccessToken")
        UserDefaults.standard.removeObject(forKey: "UserId")
        UserDefaults.standard.removeObject(forKey: "LibraryId")
        
        authenticated = false
    }
    
    private func setAccessDetails(loginResult : LoginResult) -> Void {
        
        JellyfinService.accessToken = loginResult.accessToken
        UserDefaults.standard.set(loginResult.accessToken, forKey: "AccessToken")
        
        JellyfinService.userId = loginResult.user.id
        UserDefaults.standard.set(loginResult.user.id, forKey: "UserId")        
    }
}
