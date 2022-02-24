//
//  NowPlayingThumbnail.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 2/14/22.
//

import SwiftUI

struct NowPlayingThumbnail: View {
    
    @EnvironmentObject
    var player : Player
    
    var body: some View {
        if player.currentSong != nil {
            AlbumThumbnail(album: player.currentSong!.song.album!)
        } else {
            ItemThumbnail(thumbnail: nil, itemId: "", frame: 60, cornerRadius: 2)
        }
    }
}
