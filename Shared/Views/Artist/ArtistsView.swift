//
//  ArtistsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI

struct ArtistsView: View {
    
    let artistService = ArtistService.shared
    
    @Binding
    var artists : [ArtistResult]
    
    func getSongCount(artist : Artist) -> Int{
        
        var songCount : Int = 0
        
        for album in artist.albums {
            songCount += album.songs.count
        }
        
        return songCount
    }
    
//    func viewDidLoad() {
//        artistService.retrieveArtist(complete: { result in
//            storeArtists(items: result.items)
//        })
//    }
//
    var body: some View {
        NavigationView {

            List($artists) { $artist in
                
                NavigationLink(destination: ArtistDetailView(artist: $artist)) {
                    HStack {
                        
                        Image(systemName: "music.quarternote.3")
                            .resizable()
                            .frame(width: 48, height: 48, alignment: .leading)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(artist.name)
                                .font(.title3)

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
                
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Artists")
        }
    }
}
