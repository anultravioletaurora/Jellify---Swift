//
//  SongService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/11/21.
//

import Foundation

class SongService: JellyfinService {
    
    static let shared = SongService()
    
    func retrieveSongs(albumId: String?, complete: @escaping (ResultSet<SongResult>) -> Void) {
        print("Retrieving libraries, access token is: \(JellyfinService.accessToken!)")
        
        self.get(url: "/Users/\(getUserId())/Items", params: [
            "parentId": albumId!
        ], completion: { data in
                               
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            print(json)
            
            let songResult = try! self.decoder.decode(ResultSet<SongResult>.self, from: data)
                                        
            complete(songResult)
        })
    }

}
