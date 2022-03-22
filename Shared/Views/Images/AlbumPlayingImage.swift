//
//  AlbumPlayingImage.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 10/24/21.
//

import SwiftUI

struct AlbumPlayingImage: View {
    
    @ObservedObject
    var album : FetchedResults<Album>.Element
    
    var height = UIScreen.main.bounds.height / 2.5

    var body: some View {
        ItemThumbnail(itemId: album.jellyfinId!, frame: height, cornerRadius: 10)
    }
}
