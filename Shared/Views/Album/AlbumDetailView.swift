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
        
    var fetchRequest: FetchRequest<Song>
    
    var songs: FetchedResults<Song>{
        fetchRequest.wrappedValue
    }

    @State
    var songResults: [SongResult] = []
            
    @State
    var showPlaylistSheet: Bool = false
        
    @State
    var selectedSong: Song?
        
    @State
    var player : AVPlayer = AVPlayer()
        
    let networkingManager : NetworkingManager = NetworkingManager.shared
            
    init(album: Album) {
        self.album = album
        
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
                    .listRowSeparator(Visibility.hidden)
                
                HStack {
                    Spacer()
                    Text(networkingManager.retrieveArtistByName(name: album.albumArtistName ?? "Unknown Artist")?.name ?? "Unknown Artist")
                        .opacity(0.6)
                    
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 5, height: 5)
                        .opacity(0.6)
                    
                    Text(String(album.productionYear)).font(.body)
                        .opacity(0.6)
                    Spacer()
                }
                
                ForEach(songs) { song in
                    SongButton(song: song, selectedSong: $selectedSong, songs: Array(songs), showPlaylistSheet: $showPlaylistSheet)
            }
                .sheet(isPresented: $showPlaylistSheet, content: {
                    PlaylistSelectionSheet(song: $selectedSong, showPlaylistSheet: $showPlaylistSheet)
                })
            }

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
                                         
                        if song.artists!.count > 1 {
                            Text((song.artists?.allObjects as [Artist]).map { $0.name! }.joined(separator: ", "))
                                .font(.subheadline)
                                .opacity(0.6)
                        }
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
                
        @Binding
        var showPlaylistSheet: Bool
        
        @State
        var showNewPlaylistAlert: Bool = false
        
        let networkingManager : NetworkingManager = NetworkingManager.shared
                
        @FetchRequest(
            entity: Playlist.entity(),
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
        var playlists: FetchedResults<Playlist>
        
        var body: some View {
            
            VStack {
            
                CreatePlaylistForm(showPlaylistSheet: $showPlaylistSheet, playlistSong: song!)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 30)
                
                List(playlists) { playlist in
                    Button(action: {
                        networkingManager.addToPlaylist(playlist: playlist, song: song!, complete: {
                            showPlaylistSheet = false
                        })
                    }, label: {
                        VStack(alignment: .leading) {
                            Text(playlist.name!)
                                .font(.body)
                            
                            Text("\(String(playlist.songs?.count ?? 0)) songs")
                                .font(.body)
                                .opacity(0.6)
                        }
                    })
                        .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    struct CreatePlaylistForm: View {
        
        @State
        var playlistName: String = ""
        
        @Binding
        var showPlaylistSheet : Bool
        
        var networkingManager : NetworkingManager = NetworkingManager.shared
        
        var playlistSong : Song
        
        var body: some View {
            HStack {
                TextField("Playlist Name", text: $playlistName)
                
                Spacer()
                
                Button(action: {
                    // Create Playlist
                    networkingManager.createPlaylist(name: playlistName, songs: [playlistSong], complete: {
                        showPlaylistSheet = false
                    })
                }, label: {
                    Text("Create")
                })
            }
        }
    }
}
