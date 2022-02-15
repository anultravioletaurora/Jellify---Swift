//
//  ArtistModel.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/15/22.
//

import Foundation

class ArtistModel : Identifiable, ObservableObject {
    var dateCreated : String?
    var jellyfinId : String?
    var name : String?
    var overview : String?
    var serverId : String?
    var thumbnail : Data?
    
    init(artist : Artist) {
        self.dateCreated = artist.dateCreated
        self.jellyfinId = artist.jellyfinId
        self.name = artist.name
        self.overview = artist.overview
        self.serverId = artist.serverId
        self.thumbnail = artist.thumbnail
    }
}
