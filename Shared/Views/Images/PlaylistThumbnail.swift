//
//  PlaylistThumbnail.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 1/30/22.
//

import SwiftUI

struct PlaylistThumbnail: View {
    
    @ObservedObject
    var playlist: FetchedResults<Playlist>.Element
    
    var body: some View {
        ItemThumbnail(thumbnail: playlist.thumbnail, itemId: playlist.jellyfinId!, frame: 45, cornerRadius: 2)
    }
}
