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
        NavigationLink(destination: AlbumDetailView(album: album)) {
                
            HStack {
                // Album Image
                AlbumThumbnail(album: album)

                VStack(alignment: .leading) {

                    Text(album.name ?? "Unknown Album")
                        .font(.body)

                    HStack {                        
                        Text(String(album.productionYear))
                            .font(.subheadline)
                            .opacity(0.6)
                    }
                }
				
				Spacer()
				
				if album.favorite {
					Image(systemName: "heart.fill")
						.foregroundColor(.accentColor)
				}
            }
            .contentShape(Rectangle())
        }
    }
}
