//
//  AlbumImage.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 10/24/21.
//

import SwiftUI

struct AlbumImage: View {
    
    @ObservedObject
    var album : FetchedResults<Album>.Element
    
    let networkingManager = NetworkingManager.shared
    
    var height = UIScreen.main.bounds.height / 4

    var body: some View {
        ItemThumbnail(itemId: album.jellyfinId!, frame: height, cornerRadius: 2)
    }
}
