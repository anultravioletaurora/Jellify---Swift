//
//  Login.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/9/21.
//

import Foundation

/**
 Model that represents the login credentials of a Jellyfin user
 */
struct Login: Encodable {
    
    let username: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case username = "Username"
        case password = "Pw"
    }
}
