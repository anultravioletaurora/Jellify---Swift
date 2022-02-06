//
//  AlbumDetailView.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 10/8/21.
//

import SwiftUI
import AVFoundation

struct AlbumDetailView: View {
    
    var album: Album
    
    var artist: Artist
    
    @Environment(\.managedObjectContext)
    var managedObjectContext

    var fetchRequest: FetchRequest<Song>
    
    var songs: FetchedResults<Song>{
        fetchRequest.wrappedValue
    }

    @State
    var songResults: [SongResult] = []
        
    var songService: SongService = SongService.shared
    
    var artistService: ArtistService = ArtistService.shared
    
    var playlistService: PlaylistService = PlaylistService.shared
    
    @State
    var showPlaylistSheet: Bool = false
        
    @State
    var selectedSong: Song?
        
    @State
    var player : AVPlayer = AVPlayer()
    
    @State
    var loading : Bool = true
            
    init(album: Album, artist: Artist) {
        self.album = album
        self.artist = artist
        
        self.fetchRequest = FetchRequest(
            entity: Song.entity(),
            sortDescriptors: [NSSortDescriptor(key: "indexNumber", ascending: true)],
            predicate: NSPredicate(format: "(album == %@)", album)
        )
    }
    
    var body: some View {
//        HStack {
//
//            // Play Album Button
//            Button(action: {
//                print("Playing artist")
//
//                Player.shared.loadSongs(Array(songs))
//                Player.shared.isPlaying = true
//            }) {
//
//                Spacer()
//                HStack {
//                    Image(systemName: "play.fill")
//                    Text("Play")
//                }
//                .tint(.accentColor)
//
//                Spacer()
//            }
//            .frame(minWidth: 100, maxWidth: .infinity)
//            .buttonStyle(.bordered)
//
//            // Shuffle Album Button
//            Button(action: {
//                print("Shuffling album")
//            }) {
//
//                Spacer()
//                HStack {
//                    Image(systemName: "shuffle")
//                    Text("Shuffle")
//                }
//                .tint(.accentColor)
//                Spacer()
//            }
//            .frame(minWidth: 100, maxWidth: .infinity)
//            .buttonStyle(.bordered)
//        }
//        .padding(.horizontal)
                    
        VStack(alignment: .center) {
                        
            List {
                                        
                AlbumArtwork(album: album)
                    .listRowSeparator(.hidden)
                
                ForEach(songs) { song in
                    SongButton(song: song, selectedSong: $selectedSong, songs: Array(songs), showPlaylistSheet: $showPlaylistSheet)
            }
            .sheet(isPresented: $showPlaylistSheet, content: {
                PlaylistSelectionSheet(song: $selectedSong, showPlaylistSheet: $showPlaylistSheet)
            })

        }
            .padding(.bottom, 60)

            .listStyle(PlainListStyle())
        .navigationTitle(album.name ?? "Unknown Album")
    }
    }
    
    func getRuntime(runTimeTicks: Int) -> String{
        let reference = Date();
        let myDate = Date(timeInterval: (Double(runTimeTicks)/10000000.0),
                            since: reference);
        
        let difference = Calendar.current.dateComponents([.hour, .minute], from: reference, to: myDate)
        var runtimeString: [String] = []
        if difference.hour ?? 0 > 0{
            runtimeString.append(difference.hour! > 1 ? "\(difference.hour!) hours" : "\(difference.hour!) hour")
        }
        if difference.minute ?? 0 > 0{
            runtimeString.append(difference.minute! > 1 ? "\(difference.minute!) minutes" : "\(difference.minute!) minute")
        }
//        let formattedString = String(format: "%02ld%02ld", difference.hour!, difference.minute!)
        
        return runtimeString.joined(separator: " ")
    }
    
    struct SongButton: View {
        
        var song: Song
        
        @Binding
        var selectedSong: Song?
        
        var songs: [Song]
        
        @Binding
        var showPlaylistSheet: Bool
        
        var body: some View{
            Button(action: {
                print("Playing \(song.name ?? "Unknown Song")")
                
                Player.shared.loadSongs(Array(songs), songId: song.jellyfinId!)
                Player.shared.isPlaying = true
                                
                print("Playing!")
            }, label: {
                HStack(alignment: .center, content: {
                    
                    VStack(alignment: .center, spacing: 10, content: {
                        Text(String(song.indexNumber))
                            .font(.subheadline)
                            .padding(.trailing, 5)
                    }).padding(.trailing, 5)
                                            
                    VStack(alignment: .leading, spacing: 10) {
                        Text(song.name ?? "Unknown Song")
                            .padding(.leading, 5)
                    }
                    
                    Spacer()
                })
            })
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .buttonStyle(PlainButtonStyle())
            .swipeActions {
                Button(action: {
                    print("Artist Swiped")
                }) {
                    Image(systemName: "heart")
                }
                .tint(.purple)
                
                Button(action: {
                    print("Add to playlist sheet activated")
                    selectedSong = song
                    
                    print("Showing playlist sheet for: \(selectedSong!.name)")
                    
                    showPlaylistSheet.toggle()
                    
                    print(showPlaylistSheet ? "Showing Playlist Sheet" : "Hiding Playlist Sheet")
                }) {
                    Image(systemName: "music.note.list")
                }
                .tint(.blue)
            }
        }
    }
    
    struct AlbumArtwork: View {
        
        var album: Album
        
        var artistService: ArtistService = ArtistService.shared
        
        var height = UIScreen.main.bounds.height / 4
        
        var body: some View {
            
            HStack {
                
                Spacer()
                
                // Album Image
                AlbumImage(album: album)
                
                Spacer()
            }
        }
    }
    
    struct PlaylistSelectionSheet: View {
        
        @Binding
        var song: Song?
        
        @State
        var playlistName: String = ""
        
        @Binding
        var showPlaylistSheet: Bool
        
        @State
        var showNewPlaylistAlert: Bool = false
        
        var playlistService: PlaylistService = PlaylistService.shared
        
        @FetchRequest(
            entity: Playlist.entity(),
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
        var playlists: FetchedResults<Playlist>
        
        var body: some View {
            
            VStack {
            
                HStack {
                    Spacer()
                    
                    Button(action: {
                        
                    }, label: {
                        Text("New Playlist")
                    })
                }
                .padding(.trailing, 15)
                .padding(.top, 15)
                
                List(playlists) { playlist in
                    Button(action: {
                        playlistService.addToPlaylist(playlist: playlist, song: self.song!, complete: {
                            showPlaylistSheet = false
                        })
                    }, label: {
                        Text(playlist.name!)
                    })
                }
            }
        }
    }
    
    struct CreatePlaylistForm: View {
        
        @Binding
        var playlistName: String
        
        var body: some View {
            TextField("Playlist Name", text: $playlistName)
        }
    }
}
