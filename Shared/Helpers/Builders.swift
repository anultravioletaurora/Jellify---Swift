//
//  Builders.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/19/22.
//

import Foundation
import UIKit

class Builders {
    
    static let networkingManager = NetworkingManager.shared
    
    static func artistName(song: Song?) -> String {
        
        guard song != nil else {
            return ""
        }
        
        // Check that we've actually got artists
        if let artists = song!.artists?.allObjects as? [Artist] {
            
            // If there are no artists
            if artists.count == 0 {
                
                if let album = song!.album {
                    return album.albumArtistName ?? ""
                } else {
                    return ""
                }
            }
            
            // If the song has only one artist, then we will return that
            else if artists.count == 1 {
                return artists.first?.name ?? ""
            }
            
            // If the song has two artists, we'll join them with an ampersand
            // and list the album artist first, else in alphabetical order
            else if artists.count == 2 {
                
                if artists.map({ $0.name! }).contains(where: { name in
                    name.contains("&")
                }) {
                    return artists.filter { $0.name != nil }.map { $0.name! }.sorted(by: { $0 == song!.album!.albumArtistName || $0 > $1 }).joined(separator: ", ")
                }
                
                return artists.filter { $0.name != nil }.map { $0.name! }.sorted(by: { $0 == song!.album!.albumArtistName || $0 < $1 }).joined(separator: " & ")
            }
            // Else if we have more than 2, line them up, album artist first, and
            // join them with an Oxford Comma (Vampire Weekend)
            else {
                return artists.filter { $0.name != nil }.map { $0.name! }.sorted(by: { $0 == song!.album?.albumArtistName ?? "" || $0 > $1 }).joined(separator: ", ")
            }
        }
        
        // If not, we'll check the album
        else {
            guard song!.album != nil && song!.album!.albumArtistName != nil else {
                return ""
            }
            
            return song!.album!.albumArtistName!
        }
    }
    
    static func streamUrl(song: Song) -> URL {
        let container = "opus,mp3,aac,m4a,flac,webma,webm,wav,ogg,mpa,wma"
        
        let transcodingContainer = "m4a"
        
        let sessionId = "\(Double.random(in: 0..<1496213367201))".replacingOccurrences(of: ".", with: "")

        var streamEndpointComponents = URLComponents()
        
        streamEndpointComponents.scheme = "https"
        streamEndpointComponents.host = NetworkingManager.shared.server.replacingOccurrences(of: "https://", with: "")
        streamEndpointComponents.path = "/Audio/\(song.jellyfinId!)/universal"
        streamEndpointComponents.queryItems = [
            URLQueryItem(name: "UserId", value: NetworkingManager.shared.userId),
            URLQueryItem(name: "DeviceId", value: UIDevice.current.identifierForVendor!.uuidString),
            URLQueryItem(name: "Container", value: container),
            URLQueryItem(name: "TranscodingContainer", value: transcodingContainer),
            URLQueryItem(name: "TranscodingProtocol", value: "hls"),
            URLQueryItem(name: "api_key", value: NetworkingManager.shared.accessToken),
            URLQueryItem(name: "StartTimeTicks", value: "0"),
            URLQueryItem(name: "EnableRedirection", value: "true"),
            URLQueryItem(name: "EnableRemoteMedia", value: "true"),
            URLQueryItem(name: "PlaySessionId", value: sessionId)
        ]
        
        print(streamEndpointComponents.url!)
        
        return streamEndpointComponents.url!
    }
}
