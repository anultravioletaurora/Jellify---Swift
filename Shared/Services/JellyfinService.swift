//
//  JellyfinService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import Foundation
import UIKit

class JellyfinService {
    
    let urlSession = URLSession.shared
    
    let encoder = JSONEncoder()
    
    let decoder = JSONDecoder()
    
    let server = UserDefaults.standard.string(forKey: "Server")
        
    func get(url: String, params: Dictionary<String, String>) {
        
        var url = URLComponents(string: server! + url)!
        
        url.queryItems = params.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        
        var request = URLRequest(url: url.url!)
        request.httpMethod = HttpMethod.get.rawValue

        
        let dataTask = urlSession.dataTask(with: request, completionHandler: { data, response, error in
                        
            // Check if the request succeeded
            if error == nil {
                                                                                    
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
        
        var request : URLRequest = URLRequest(url: URL(string: "\(String(describing: server))\(url))")!)
        
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
