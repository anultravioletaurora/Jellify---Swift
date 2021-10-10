//
//  LoginResult.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/10/21.
//

import Foundation

struct LoginResult: Codable {
    let user: UserResult
    let sessionInfo: SessionInfo
    let accessToken, serverID: String

    enum CodingKeys: String, CodingKey {
        case user = "User"
        case sessionInfo = "SessionInfo"
        case accessToken = "AccessToken"
        case serverID = "ServerId"
    }
}
