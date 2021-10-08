//
//  ArtistsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI

struct ArtistsView: View {
    
    @State
    var artists : [Artist] = [
        Artist(name: "Coldplay", albums: [
            Album(name: "Viva la Vida", year: "2008", favorite: true,
                  songs: [Song(index: 1, name: "Viva la Vida")]
                 )
        ],
               favorite: true
               ),
        Artist(name: "Coldplay 2", albums: [
            Album(name: "Viva la Vida", year: "2008", favorite: false,
                  songs: [Song(index: 1, name: "Viva la Vida")]
                 )
        ],
               favorite: false
               ),
        Artist(name: "Coldplay 3", albums: [
            Album(name: "Viva la Vida", year: "2008", favorite: false,
                  songs: [Song(index: 1, name: "Viva la Vida")]
                 )
        ],
               favorite: false
               ),
        Artist(name: "Coldplay 4", albums: [
            Album(name: "Viva la Vida", year: "2008", favorite: false,
                  songs: [Song(index: 1, name: "Viva la Vida")]
                 )
        ],
               favorite: false
               ),
        Artist(name: "Coldplay 5", albums: [
            Album(name: "Viva la Vida", year: "2008", favorite: false,
                  songs: [Song(index: 1, name: "Viva la Vida")]
                 )
        ],
               favorite: false
               )
    ]
    
    func getSongCount(artist : Artist) -> Int{
        
        var songCount : Int = 0
        
        for album in artist.albums {
            songCount += album.songs.count
        }
        
        return songCount
    }
    
    var body: some View {
        NavigationView {
            List($artists) { $artist in
                NavigationLink(destination: ArtistDetailView(artist: $artist)) {
                    HStack {
                        
                        Image("profile")
                            .resizable()
                            .frame(width: 48, height: 48, alignment: .leading)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(artist.name)
                                .font(.title3)

                            HStack {
                                let albumCount = artist.albums.count
                                
                                let albumText : String = albumCount == 1 ? "album" : "albums"
                                
                                
                                let songCount : Int = getSongCount(artist: artist)
                                
                                let songText : String = songCount == 1 ? "song" : "songs"
                            
                                Text("\(albumCount) \(albumText), \(songCount) \(songText)")
                                    .font(.subheadline)
                                    .fontWeight(.light)

                                
                            }
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
