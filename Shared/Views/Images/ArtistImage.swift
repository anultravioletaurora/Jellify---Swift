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
        
    var body: some View {
        ItemThumbnail(thumbnail: artist.thumbnail, itemId: artist.jellyfinId!, frame: 100, cornerRadius: 100)
    }
}
