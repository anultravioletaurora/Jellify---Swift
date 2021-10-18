//
//  JellyfinService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import Foundation
import UIKit
import CoreData
import SwiftUI
import JellyfinAPI

class JellyfinService: ObservableObject {
        
    let urlSession = URLSession.shared
    
    let encoder = JSONEncoder()
    
    let decoder = JSONDecoder()
    
    static let sharedParent = JellyfinService()
        
    @FetchRequest(
        entity: User.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \User.userId, ascending: true)
        ])
    static var users : FetchedResults<User>
    
    static var context : NSManagedObjectContext = PersistenceController.shared.container.viewContext

//
//    static var accessToken = UserDefaults.standard.string(forKey: "AccessToken") {
//        didSet {
//            UserDefaults.standard.set(accessToken, forKey: "AccessToken")
//        }
//    }
//
//    static var userId = UserDefaults.standard.string(forKey: "UserId") {
//        didSet {
//            UserDefaults.standard.set(userId, forKey: "UserId")
//        }
//    }
//
//    static var libraryId = UserDefaults.standard.string(forKey: "LibraryId") {
//        didSet {
//            UserDefaults.standard.set(libraryId, forKey: "LibraryId")
//        }
//    }
//
//    static var playlistsId = UserDefaults.standard.string(forKey: "PlaylistsId") {
//        didSet {
//            UserDefaults.standard.set(playlistsId, forKey: "PlaylistsId")
//        }
//    }
//
//    static var quality: Double = UserDefaults.standard.double(forKey: "Quality") {
//        didSet{
//            UserDefaults.standard.set(quality, forKey: "Quality")
//        }
//    }
    
    var user: User? {
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        
        return try! JellyfinService.context.fetch(userRequest).first ?? nil
    }
    
    public var _server: String = ""
    
    public var server: String {
        if _server != ""{
            return _server
        }
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try JellyfinService.context.fetch(userRequest)
            if users.isEmpty{
                return ""
            }else{
                _server = users[0].server!
                return users[0].server!
            }
        }catch{
            return ""
        }
    }
    
    public var _accessToken: String = ""
    
    public var accessToken: String {
        if _accessToken != ""{
            return _accessToken
        }
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try JellyfinService.context.fetch(userRequest)
            if users.isEmpty{
                return ""
            }else{
                _accessToken = users[0].authToken!
                return users[0].authToken!
            }
        }catch{
            return ""
        }
    }
    
    public var _userId: String = ""
    public var userId: String {
        if _userId != "" {
            return _userId
        }
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try JellyfinService.context.fetch(userRequest)
            if users.isEmpty{
                return ""
            }else{
                _userId = users[0].userId!
                return users[0].userId!
            }
        }catch{
            return ""
        }
    }
    
    public var _libraryId: String = ""
    public var libraryId:String {
        if _libraryId != ""{
            return _libraryId
        }
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try JellyfinService.context.fetch(userRequest)
            if users.isEmpty{
                return ""
            }else{
                _libraryId = users[0].musicLibraryId ?? ""
                return users[0].musicLibraryId ?? ""
            }
        }catch{
            return ""
        }
    }
    
    public var _playlistId: String = ""
    public var playlistId: String {
        if _playlistId != ""{
            return _playlistId
        }
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try JellyfinService.context.fetch(userRequest)
            if users.isEmpty{
                return ""
            }else{
                _playlistId = users[0].playlistLibraryId ?? ""
                return users[0].playlistLibraryId ?? ""
            }
        }catch{
            return ""
        }
    }
    
    public func setAuthHeader(with accessToken: String) {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        var deviceName = UIDevice.current.name
        deviceName = deviceName.folding(options: .diacriticInsensitive, locale: .current)
        deviceName = String(deviceName.unicodeScalars.filter { CharacterSet.urlQueryAllowed.contains($0) })
        
        let platform: String
        #if os(tvOS)
        platform = "tvOS"
        #else
        platform = "iOS"
        #endif
        
        var header = "MediaBrowser "
        header.append("Client=\"Jellyfin \(platform)\", ")
        header.append("Device=\"\(deviceName)\", ")
        header.append("DeviceId=\"\(platform)_\(UIDevice.current.identifierForVendor!)_\(String(Date().timeIntervalSince1970))\", ")
        header.append("Version=\"\(appVersion ?? "0.0.1")\", ")
        header.append("Token=\"\(accessToken)\"")

        JellyfinAPI.customHeaders["X-Emby-Authorization"] = header
    }


        
    func get(url: String, params: Dictionary<String, String>, completion: @escaping (Data) -> Void) {
        
        var urlComponents = URLComponents(string: self.server + url)!
        
        urlComponents.queryItems = params.map { (key, value) in
            return URLQueryItem(name: key, value: value)
        }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = HttpMethod.get.rawValue
                
        request.setValue(self.accessToken, forHTTPHeaderField: "X-Emby-Token")
        
        let dataTask = urlSession.dataTask(with: request, completionHandler: { data, response, error in
                        
            // Check if the request succeeded
            if error == nil && data != nil {
                                                        
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
        
        var request : URLRequest = URLRequest(url: URL(string: "\(self.server)\(url))")!)
        
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
    
    public func deleteAllOfEntity(entityName: String)-> Void{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try JellyfinService.context.execute(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
            print(error)
        }
    }

}
                            
enum HttpMethod : String {
    case post = "POST"
    case get = "GET"
}
