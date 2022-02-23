//
//  PlaylistArtwork.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 2/22/22.
//

import SwiftUI

struct PlaylistArtwork: View {
    
    @ObservedObject
    var playlist: FetchedResults<Playlist>.Element
    
    var body: some View {
        HStack {
            Spacer()
            
            ItemThumbnail(thumbnail: playlist.thumbnail, itemId: playlist.jellyfinId!, frame: Globals.ARTWORK_FRAME, cornerRadius: 2)
            
            Spacer()
        }
    }
}
