//
//  SessionInfo.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/10/21.
//

import Foundation

struct SessionInfo: Codable {
//    let playState: PlayState
//    let capabilities: Capabilities
    let remoteEndPoint, id, userID, userName: String
    let client, lastActivityDate, lastPlaybackCheckIn, deviceName: String
    let deviceID, applicationVersion: String
    let isActive, supportsMediaControl, supportsRemoteControl, hasCustomDeviceName: Bool
    let serverID: String

    enum CodingKeys: String, CodingKey {
//        case playState = "PlayState"
//        case capabilities = "Capabilities"
        case remoteEndPoint = "RemoteEndPoint"
        case id = "Id"
        case userID = "UserId"
        case userName = "UserName"
        case client = "Client"
        case lastActivityDate = "LastActivityDate"
        case lastPlaybackCheckIn = "LastPlaybackCheckIn"
        case deviceName = "DeviceName"
        case deviceID = "DeviceId"
        case applicationVersion = "ApplicationVersion"
        case isActive = "IsActive"
        case supportsMediaControl = "SupportsMediaControl"
        case supportsRemoteControl = "SupportsRemoteControl"
        case hasCustomDeviceName = "HasCustomDeviceName"
        case serverID = "ServerId"
    }
}
