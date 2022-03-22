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

				VStack(alignment: .leading, spacing: 10) {

                    Text(album.name ?? "Unknown Album")

					Text(String(album.productionYear))
						.font(.subheadline)
						.opacity(Globals.componentOpacity)
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
