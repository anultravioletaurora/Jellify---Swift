//
//  AlbumThumbnail.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 10/24/21.
//

import SwiftUI

struct PlaylistItemThumbnail: View {
    
    @ObservedObject
    var playlistSong: FetchedResults<PlaylistSong>.Element
    
    var body: some View {
        ItemThumbnail(itemId: playlistSong.song!.album!.jellyfinId!, frame: 60, cornerRadius: 2)
    }
}
