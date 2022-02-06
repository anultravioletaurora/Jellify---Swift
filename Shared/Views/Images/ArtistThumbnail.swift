//
//  ArtistThumbnail.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 10/24/21.
//

import SwiftUI

struct ArtistThumbnail: View {
    
    @ObservedObject
    var artist : FetchedResults<Artist>.Element
    
    var body: some View {
        ItemThumbnail(thumbnail: artist.thumbnail, itemId: artist.jellyfinId!, frame: 60, cornerRadius: 100)
    }
}
