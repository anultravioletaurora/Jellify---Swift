//
//  SongService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/11/21.
//

import Foundation

class SongService: JellyfinService {
    
    static let shared = SongService()
    
    func getSongUrl(songId: String) -> URL {
        
        print("Building stream URL: \(JellyfinService.users.first!.server!)/Audio/\(songId)/stream.aac")
        
        return URL(string: "\(self.server)/Audio/\(songId)/stream.aac")!
    }
    
    func retrieveSongs(parentId: String?, complete: @escaping (ResultSet<SongResult>) -> Void) {
        print("Retrieving songs, access token is: \(self.accessToken)")
        
        self.get(url: "/Users/\(self.userId)/Items", params: [
            "parentId": parentId ?? ""
        ], completion: { data in
                               
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            print(json as Any)
            
            let songResult = try! self.decoder.decode(ResultSet<SongResult>.self, from: data)
                                        
            complete(songResult)
        })
    }
    
    func retrieveSongsFromPlaylist(playlistId: String, complete: @escaping (ResultSet<SongResult>) -> Void) {
        
        print("Retrieving songs from playlist, ID is \(playlistId)")
        
        self.get(url: "/Playlists/\(playlistId)/Items", params: [
            "userId": self.userId
        ], completion: { data in
            let songResult = try! self.decoder.decode(ResultSet<SongResult>.self, from: data)
                                        
            complete(songResult)
        })
    }
}
