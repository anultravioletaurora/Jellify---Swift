//
//  Song.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import Foundation

/**
 Model that represents a song in the music library
 */
struct Song : Hashable {
    
    /**
     Unique identifier for the song
     */
    var id: UUID = UUID()
    
    /**
     Index of where the song is in the album
     */
    var index : Int
    
    /**
     Name of the song
     */
    var name: String
}
