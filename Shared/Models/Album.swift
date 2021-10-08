//
//  Album.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/6/21.
//

import Foundation

/**
 Model that represents an album in the library
 */
struct Album : Hashable, Identifiable {
    
    /**
     Unique identifier for the album
     */
    var id : UUID = UUID()
    
    /**
     Name of the album
     */
    var name : String
    
    /**
     Year the album was released
     */
    var year : String
    
    /**
     Whether the album is favorited
     */
    var favorite : Bool
    
    /**
     The song(s) that comprise the album
     */
    var songs : [Song]
}
