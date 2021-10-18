//
//  LibraryResult.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/10/21.
//

import Foundation

struct LibraryResult: Codable, Hashable, Identifiable {
    
    var id: String
    var name: String
    var collectionType: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case id = "Id"
        case collectionType = "CollectionType"
    }
}
