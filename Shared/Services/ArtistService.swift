//
//  ArtistService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/10/21.
//

import Foundation

class ArtistService : JellyfinService {

    static let shared = ArtistService()
        
    func retrieveArtists(complete: @escaping (ResultSet<ArtistResult>) -> Void) {
                
        print("Retrieving artists, access token is: \(ArtistService.accessToken!)")
        
        self.get(url: "/Artists", params: [
            "userId": UserDefaults.standard.string(forKey: "UserId")!,
            "mediaType": "Audio",
            "enableImages": "true"
        ], completion: { data in
                               
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            print(json)
            
            let artistResult = try! self.decoder.decode(ResultSet<ArtistResult>.self, from: data)
            
            print("Test Artist: \(try! self.encoder.encode(artistResult.items[0]))")
                       
            complete(artistResult)
        })
    }
}
