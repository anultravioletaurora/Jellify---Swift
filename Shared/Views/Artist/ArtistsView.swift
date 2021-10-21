//
//  ArtistsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI

struct ArtistsView: View {
    
    let artistService = ArtistService.shared
    
    var artists: FetchedResults<Artist>{
        fetchRequest.wrappedValue
    }
    
    var fetchRequest: FetchRequest<Artist>
    
    @Environment(\.managedObjectContext)
    var managedObjectContext
        
    @State
    var search : String = ""
    
    @State
    var loading : Bool = true
    
    init() {
                
        self.fetchRequest = FetchRequest(
            entity: Artist.entity(),
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Artist.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))]
        )
    }
    
    func getSongCount(artist : Artist) -> Int{
        
        var songCount : Int = 0
        
        if (artist.albums != nil) {
            for album in artist.albums! {
                songCount += (album as! Album).songs!.count
            }
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
        
            // Display spinner if we're loading
            if loading {
                ProgressView("Loading Artists")
            }
            
            // Else display artists
            else {
                    
                    // Artists List
                List(artists) { artist in

                    NavigationLink(destination: ArtistDetailView(artist)) {
                        HStack {
                                                
                            
                            CacheAsyncImage(
                                url: URL(string:artistService.getAlbumArt(id: artist.jellyfinId!, maxSize: 250))!
                            ) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(10)
                                                                        
                                case .empty:
                                    ProgressView()
                                        .frame(width: 60, height: 60)
                                    
                                @unknown default:
                                Image(systemName: "music.mic")
                                        .resizable()
                                    .frame(width: 60, height: 60)

                                }
                            }

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

                }
                .padding(.bottom, 65)
                .searchable(text: $search, prompt: "Search artists")
                .onChange(of: search, perform: { newSearch in
                                                            
                    artists.nsPredicate = newSearch.isEmpty ? nil : NSPredicate(format: "%K contains[c] %@", #keyPath(Artist.name), newSearch)
                })
                .listStyle(PlainListStyle())
                .navigationTitle("Artists")
            }
        }
        .onAppear(perform: {
            
            if self.artists.isEmpty {
                
                loading = true

                artistService.retrieveArtists()
                
                loading = false
            } else {
                loading = false
            }
        })
    }
}
