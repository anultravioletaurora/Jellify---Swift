//
//  PlaylistHelper.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 1/29/22.
//

import Foundation

class PlaylistHelper {
    
    static let shared = PlaylistHelper()
    
    func createPlaylistFromResult(result: PlaylistResult) -> Playlist {
        let playlist = Playlist(context: JellyfinService.context)
        
        playlist.jellyfinId = result.id
        playlist.name = result.name
        
        return playlist
    }
}
