//
//  ArtistDetailView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/6/21.
//

import SwiftUI

struct ArtistDetailView: View {
    
    @Environment(\.managedObjectContext)
    var managedObjectContext
    
    let albumService : AlbumService = AlbumService.shared
    
    let songService : SongService = SongService.shared
    
    let artistService : ArtistService = ArtistService.shared
    
    var fetchRequest: FetchRequest<Album>
    
    var albums: FetchedResults<Album>{
        fetchRequest.wrappedValue
    }

    @State
    var albumResults : [AlbumResult] = []
    
    @State
    var search : String = ""
    
    @State
    var loading : Bool = true
        
    var artist : Artist
                
    init(_ artist: Artist) {

        self.artist = artist
        self.fetchRequest = FetchRequest(
            entity: Album.entity(),
            sortDescriptors: [NSSortDescriptor(key: "productionYear", ascending: false)],
            predicate: NSPredicate(format: "albumArtist == %@", artist.jellyfinId!)
        )
    }
    
    var body: some View {
                   
        VStack {
            
                List(albums) { album in
                    AlbumRow(album: album, artist: artist)
                        .padding(.bottom, albums.last! == album ? 65 : 0)
                }
            .listStyle(PlainListStyle())
//        .searchable(text: $search, prompt: "Search \(artist.name ?? "Unknown Artist") albums")
//        .onChange(of: search, perform: { newSearch in
//            albums.nsPredicate = newSearch.isEmpty ? nil : NSPredicate(format: "%K contains[c] %@", #keyPath(Album.name), newSearch)
//
//        })
        }
        .navigationTitle(artist.name ?? "Unknown Artist")
//        .onAppear(perform: {
//                       
//            print(self.albums)
//            
//            if self.albums.isEmpty {
//            
//                print("No core data albums, fetching them from server")
//                albumService.retrieveAlbums(artist: artist, complete: {
//                    loading = false
//                })
//                                
//                print("Albums retrieved")
//            } else {
//                loading = false
//            }
//                        
//        })

//        ScrollView {
//            HStack(alignment: .center, spacing: 5) {
//
//                // Artist Image
//    //            Image("profile")
//    //                .resizable()
//    //                .frame(width: 64, height: 64, alignment: .leading)
//    //                .clipShape(Circle())
//    //                .padding()
//
//            }
//            .frame(maxWidth: .infinity)
//            .fixedSize(horizontal: true, vertical: true)
//
//            // List of albums
//            VStack(alignment: .leading, content: {
//                ForEach($albums) { $album in
//
//                    Divider()
//
//                    NavigationLink(destination: AlbumDetailView(album: $album)) {
//
//                        HStack {
//                            // Album Image
//                            Image(systemName: "questionmark.square")
//                                .resizable()
//                                .frame(width: 64, height: 64, alignment: .leading)
//                                .cornerRadius(5)
//
//                            VStack(alignment: .leading) {
//
//                                Text(album.name)
//                                    .font(.body)
//
//                                Text(album.productionYear != nil ? String(album.productionYear!) : "")
//                                    .font(.body)
//                                    .opacity(0.6)
//                            }
//
//                            Spacer()
//
//                            Image(systemName: "chevron.right")
//                        }
//                        .contentShape(Rectangle())
//                    }
//                }
//                .buttonStyle(PlainButtonStyle())
//                .padding(.horizontal)
//            })
//        }
    }
}
