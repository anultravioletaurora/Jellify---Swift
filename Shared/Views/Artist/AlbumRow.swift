//
//  AlbumRow.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/25/21.
//

import SwiftUI

struct AlbumRow: View {
    
    @ObservedObject
    var album : FetchedResults<Album>.Element
    
    let artist : FetchedResults<Artist>.Element
    
    var body: some View {
        NavigationLink(destination: AlbumDetailView(album: album, artist: artist)) {
                
            HStack {
                // Album Image
                AlbumThumbnail(album: album)

                VStack(alignment: .leading) {

                    Text(album.name ?? "Unknown Album")
                        .font(.body)

                    Text(String(album.productionYear))
                        .font(.body)
                        .opacity(0.6)
                }
            }
            .contentShape(Rectangle())
        }
    }
}
