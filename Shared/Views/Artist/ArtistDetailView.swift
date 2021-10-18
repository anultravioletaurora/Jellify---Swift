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
        
    var artist : Artist
                
    init(_ artist: Artist) {

        self.artist = artist
        self.fetchRequest = FetchRequest(
            entity: Album.entity(),
            sortDescriptors: [NSSortDescriptor(key: "productionYear", ascending: true)],
            predicate: NSPredicate(format: "ANY albumArtists == %@", artist)
        )
    }
    
    var body: some View {
                   
        VStack {
            
            HStack {
                // Favorite Artist Button
//                Button(action: {
//                    // TODO: Make API call to favorite artist
//                    print("Artist favorited")
//        //            artist.userData.isFavorite.toggle()
//                }) {
//                    
//                    Spacer()
//                    HStack {
//                        if true {
//                            Image(systemName: "heart.fill")
//                            Text("Favorited")
//                        } else {
//                            Image(systemName: "heart")
//                            Text("Favorite")
//                        }
//                    }
//                    .tint(.accentColor)
//                    
//                    Spacer()
//                }
//                .frame(maxWidth: .infinity)
//                .buttonStyle(.bordered)
                    
                // Play Artist Button
                Button(action: {
                    print("Playing artist")
                }) {
                    Spacer()
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play")
                    }
                    .tint(.accentColor)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
                
                Button(action: {
                    print("Shuffling artist")
                }) {
                    Spacer()
                    HStack {
                        Image(systemName: "shuffle")
                        Text("Shuffle")
                    }
                    .tint(.accentColor)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
            }

            
            List (albums) { album in
                NavigationLink(destination: AlbumDetailView(album: album, artist: artist)) {
                        
                    HStack {
                        // Album Image
                        CacheAsyncImage(
                            url: URL(string:artistService.getAlbumArt(id: album.jellyfinId!, maxSize: 1000))!
                        ) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(2)
                                
                            case .empty:
                                ProgressView()
                                    .frame(width: 60, height: 60)
                                
                            @unknown default:
                            Image(systemName: "opticaldisc")
                                    .resizable()
                                .frame(width: 60, height: 60)

                            }
                        }

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
            .padding(.bottom, 65)
            .listStyle(PlainListStyle())
//        .searchable(text: $search, prompt: "Search \(artist.name ?? "Unknown Artist") albums")
//        .onChange(of: search, perform: { newSearch in
//            albums.nsPredicate = newSearch.isEmpty ? nil : NSPredicate(format: "%K contains[c] %@", #keyPath(Album.name), newSearch)
//
//        })
        .navigationTitle(artist.name ?? "Unknown Artist")
        }
        .onAppear(perform: {
                       
            print(self.albums)
            
            if self.albums.isEmpty {
            
                print("No core data albums, fetching them from server")
                albumService.retrieveAlbums(artistId: artist.jellyfinId!, complete: { result in
                    self.albumResults = result.items
                    
                    for albumResult in result.items {
                        let album = Album(context: managedObjectContext)
                        
                        album.jellyfinId = albumResult.id
                        album.name = albumResult.name
                        album.productionYear = Int16(albumResult.productionYear ?? 0)
                        
                        album.addToAlbumArtists(artist)
                        
                        print("Fetching songs from service")
                        songService.retrieveSongs(parentId: album.jellyfinId!, complete: { songResult in
                                        
                            for songResult in songResult.items {
                                let song = Song(context: managedObjectContext)
                                
                                song.jellyfinId = songResult.id
                                song.name = songResult.name
                                song.indexNumber = Int16(songResult.indexNumber!)
                                
                                song.album = album
                                song.addToArtists(album.albumArtists!)
                            }
                        })

                    }
                })
                                
                print("Albums retrieved")
            }
                        
        })

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
