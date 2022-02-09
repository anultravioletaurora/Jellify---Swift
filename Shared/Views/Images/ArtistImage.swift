//
//  ArtistImage.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 1/30/22.
//

import SwiftUI

struct ArtistImage: View {
    
    @ObservedObject
    var artist : FetchedResults<Artist>.Element
    
    var height = UIScreen.main.bounds.height / 5
    
    var body: some View {
        ItemThumbnail(thumbnail: artist.thumbnail, itemId: artist.jellyfinId!, frame: height, cornerRadius: 100)
    }
}
