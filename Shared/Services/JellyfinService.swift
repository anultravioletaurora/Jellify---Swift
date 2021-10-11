//
//  JellyfinService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import Foundation
import UIKit

class JellyfinService: ObservableObject {
    
    let urlSession = URLSession.shared
    
    let encoder = JSONEncoder()
    
    let decoder = JSONDecoder()
    
    static var server = UserDefaults.standard.string(forKey: "Server")
    
    static var accessToken = UserDefaults.standard.string(forKey: "AccessToken")
    
    static var userId = UserDefaults.standard.string(forKey: "UserId")
    
    static var libraryId = UserDefaults.standard.string(forKey: "LibraryId")
    
    func getUserId() -> String {
        return UserDefaults.standard.string(forKey: "UserId") ?? ""
    }
        
    func get(url: String, params: Dictionary<String, String>, completion: @escaping (Data) -> Void) {
        
        var url = URLComponents(string: JellyfinService.server! + url)!
        
        url.queryItems = params.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        
        var request = URLRequest(url: url.url!)
        request.httpMethod = HttpMethod.get.rawValue
        
        print("Setting token header: \(getUserId())")
        
        request.setValue(UserDefaults.standard.string(forKey: "AccessToken"), forHTTPHeaderField: "X-Emby-Token")
        
        let dataTask = urlSession.dataTask(with: request, completionHandler: { data, response, error in
                        
            // Check if the request succeeded
            if error == nil && data != nil {
                                        
                print("Get successful, data is : \(response!)")
                
                completion(data!)
//                let ArtistResponse : ArtistResponse = try! self.decoder.decode([ArtistResponse].self, from: data!)
            }
            
            // Else the request failed *sad trombone*
            else {
                
                print("Big sadge")
            }
        })
        
        dataTask.resume()

    }
    
    func post(url: String, params: Data?) {
        
        var request : URLRequest = URLRequest(url: URL(string: "\(String(describing: JellyfinService.server))\(url))")!)
        
        request.httpMethod = HttpMethod.post.rawValue
        
        request.setValue("MediaBrowser Client=\"jFin\", Device=\"\(UIDevice.current.name)\", DeviceId=\"\(UIDevice.current.model)\", Version=\"\(getAppCurrentVersionNumber())\"", forHTTPHeaderField: "X-Emby-Authorization")
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if params != nil {
            let jsonData = try? self.encoder.encode(params)
            request.httpBody = jsonData
        }
    }
    
    private func getAppCurrentVersionNumber() -> String {
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        return nsObject as! String
    }
}
                            
enum HttpMethod : String {
    case post = "POST"
    case get = "GET"
}
