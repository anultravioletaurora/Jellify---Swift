//
//  ArtistResult.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/10/21.
//

import Foundation

class ArtistResult: Codable, Identifiable {
    var name, serverID, id: String
    let dateCreated, overview, sortName: String?
    let genreItems: [GenreItem]?
    let imageTags: ImageTags
    let backdropImageTags: [String]
    var userData: UserDataResult

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case serverID = "ServerId"
        case id = "Id"
        case dateCreated = "DateCreated"
        case sortName = "SortName"
        case overview = "Overview"
        case genreItems = "GenreItems"
        case imageTags = "ImageTags"
        case backdropImageTags = "BackdropImageTags"
        case userData = "UserData"
    }
}
struct GenreItem: Codable {
    let name, id: String

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case id = "Id"
    }
}

struct ImageTags: Codable, Hashable {
    let primary, banner, logo: String?

    enum CodingKeys: String, CodingKey {
        case primary = "Primary"
        case banner = "Banner"
        case logo = "Logo"
    }
}

struct AlbumResult: Codable, Hashable, Identifiable {
    let name, serverID, id, albumArtist: String
    let runTimeTicks: Int64
    let productionYear: Int?
    let albumArtists: [GenericItem]
    let imageTags: ImageTags
    var userData: UserData?

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case serverID = "ServerId"
        case id = "Id"
        case runTimeTicks = "RunTimeTicks"
        case productionYear = "ProductionYear"
        case albumArtist = "AlbumArtist"
        case albumArtists = "AlbumArtists"
        case imageTags = "ImageTags"
    }
    
    static func == (lhs: AlbumResult, rhs: AlbumResult) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

struct Id: Codable, Hashable {
    let id: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
    }
}

struct GenericItem: Codable, Hashable, Identifiable {
    let name, id: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case id = "Id"
    }
    
    init() {
        name = ""
        id = UUID().uuidString
    }
}

struct PlaylistResult: Codable, Hashable{
    let name, id: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case id = "Id"
    }
}


struct PlaylistItem: Codable, Hashable, Identifiable {
    public var name, serverID, id, albumId, album: String
    let playlistItemId: String?
    let runTimeTicks: Double
    let productionYear, indexNumber, parentIndexNumber: Int?
    let artists: [String]
    let artistItems: [GenericItem]
    var userData: UserData?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case serverID = "ServerId"
        case id = "Id"
        case runTimeTicks = "RunTimeTicks"
        case productionYear = "ProductionYear"
        case indexNumber = "IndexNumber"
        case parentIndexNumber = "ParentIndexNumber"
        case artists = "Artists"
        case artistItems = "ArtistItems"
        case albumId = "AlbumId"
//        case userData = "UserData"
        case album = "Album"
        case playlistItemId = "PlaylistItemId"
    }
}

public struct SongResult: Codable, Hashable, Identifiable {
    
    public var name, serverID, id, albumId, album: String
    let playlistItemId: String?
    let runTimeTicks: Double
    let productionYear, indexNumber, parentIndexNumber: Int?
    let artists: [String]
    let artistItems: [GenericItem]
    var userData: UserData?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case serverID = "ServerId"
        case id = "Id"
        case runTimeTicks = "RunTimeTicks"
        case productionYear = "ProductionYear"
        case indexNumber = "IndexNumber"
        case parentIndexNumber = "ParentIndexNumber"
        case artists = "Artists"
        case artistItems = "ArtistItems"
        case albumId = "AlbumId"
//        case userData = "UserData"
        case album = "Album"
        case playlistItemId = "PlaylistItemId"
    }
}

enum ResultCustom<T> {
    case success(value: T)
    case failure(value: JellyFinError)
}

enum JellyFinError: Error {
    case unknown(error: Error? = nil)
    case loginFailed
    case notAuthenticated(error: String = "Make sure the user is authenticated")
}
