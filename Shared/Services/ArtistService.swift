//
//  ArtistService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/10/21.
//

import Foundation

class ArtistService : JellyfinService, ObservableObject {

    static let shared = ArtistService()
    
    var accessToken = UserDefaults.standard.string(forKey: "AccessToken")
    
    func retrieveArtists() {
        
    }
}
