//
//  UserResponse.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/9/21.
//

import Foundation

struct UserResponse : Decodable {
    
    var id : UUID
            
    var serverId : String
    
    var serverName : String
    
    var accessToken : String
    
    enum CodingKeys: String, CodingKey {
        
        case id = "Id"
        case serverName = "ServerName"
        case serverId = "ServerId"
        case accessToken = "AccessToken"

    }
}
