//
//  PlaylistService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/12/21.
//

import Foundation

class PlaylistService : JellyfinService {
    
    static let shared = PlaylistService()
    
    func retrievePlaylists(complete: @escaping (ResultSet<PlaylistResult>) -> Void) {
        print("Retrieving playlists, access token is: \(self.accessToken)")
        
        self.get(url: "/Users/\(self.userId)/Items", params: [
            "parentId": self.playlistId
        ], completion: { data in
                               
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            print(json as Any)
            
            let playlistResult = try! self.decoder.decode(ResultSet<PlaylistResult>.self, from: data)
                                        
            complete(playlistResult)
        })
    }

    func retrieveSongsFromPlaylist(playlistId: String, complete: @escaping (ResultSet<SongResult>) -> Void) {
        
        print("Retrieving songs from playlist, ID is \(playlistId)")
        
        self.get(url: "/Playlists/\(playlistId)/Items", params: [
            "UserId": self.userId
        ], completion: { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            print(json as Any)

            let songResult = try! self.decoder.decode(ResultSet<SongResult>.self, from: data)
                                        
            complete(songResult)
        })
    }
}
