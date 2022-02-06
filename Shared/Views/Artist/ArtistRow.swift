//
//  ArtistRow.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/25/21.
//

import SwiftUI

struct ArtistRow: View {
    
    let artistService : ArtistService = ArtistService.shared
    
    @ObservedObject
    var artist : FetchedResults<Artist>.Element
    
    var body: some View {
        NavigationLink(destination: ArtistDetailView(artist)) {
            HStack {
                                    
                ArtistThumbnail(artist: artist)

                VStack(alignment: .leading) {
                    Text(artist.name ?? "Unknown Artist")
                        .font(.body)

//                            HStack {
//                                let albumCount = artist.albums.count
//
//                                let albumText : String = albumCount == 1 ? "album" : "albums"
//
//
//                                let songCount : Int = getSongCount(artist: artist)
//
//                                let songText : String = songCount == 1 ? "song" : "songs"
//
//                                Text("\(albumCount) \(albumText), \(songCount) \(songText)")
//                                    .font(.subheadline)
//                                    .fontWeight(.light)
//
//
//                            }
                }
            }
        }
        .swipeActions {
            Button(action: {
                print("Artist Swiped")
            }) {
                Image(systemName: "heart")
            }
            .tint(.purple)
        }
        .onAppear(perform: {
            if artist.thumbnail == nil {
                artistService.fetchArtistThumbnail(artist: artist, complete: {
                    print("yeet")
                })
            }
        })
    }
}
