//
//  Artist.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/6/21.
//

import Foundation

/**
 Model for a musical artist
 */
struct Artist : Identifiable {
    
    /**
     Unique identifier for the artist
     */
    var id : UUID = UUID()
    
    /**
     Name of the artist
     */
    var name : String;
    
    /**
     Collection of albums recorded by the artist
     */
    var albums : [Album]
    
    /**
     Whether the artist has been favorited by the user
     */
    var favorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"

        case name = "Name"
    }
}
