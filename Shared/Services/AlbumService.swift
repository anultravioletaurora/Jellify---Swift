//
//  AlbumService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/10/21.
//

import Foundation

class AlbumService : JellyfinService {
    
    static let shared = AlbumService()
    
    func retrieveAlbums(artistId: String?, complete: @escaping (ResultSet<AlbumResult>) -> Void) {
                
        print("Retrieving albums, access token is: \(AlbumService.accessToken!)")
        
        self.get(url: "/Users/\(getUserId())/Items", params: [
            "parentId": AlbumService.libraryId!,
            "artistIds": artistId!,
            "IncludeItemTypes": "MusicAlbum",
            "Recursive": "true"
            
        ], completion: { data in
                               
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            print(json)
            
            let albumResult = try! self.decoder.decode(ResultSet<AlbumResult>.self, from: data)
            
            print("Test Artist: \(albumResult.items[0].name)")
                       
            complete(albumResult)
        })
    }
}

