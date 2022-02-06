//
//  AlbumThumbnail.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 10/24/21.
//

import SwiftUI

struct AlbumThumbnail: View {
    
    @ObservedObject
    var album : FetchedResults<Album>.Element
    
    var body: some View {
        ItemThumbnail(thumbnail: album.thumbnail, itemId: album.jellyfinId!, frame: 60, cornerRadius: 2)
    }
}
