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
        
    @State
    var confirmDeleteDownload : Bool = false
    
    let downloadManager : DownloadManager = DownloadManager.shared

    init(album: Album) {
        self.album = album
        
        self.fetchRequest = FetchRequest(
            entity: Song.entity(),
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Song.diskNumber), ascending: true), NSSortDescriptor(key: #keyPath(Song.indexNumber), ascending: true)],
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
                
                VStack(alignment: .center) {
                    HStack {
                        
                        Spacer()
                        
                        Text(album.name ?? "Unknown Album")
                        .font(.title3)
                        .bold()
                        
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        
                        Text(networkingManager.retrieveArtistByName(name: album.albumArtistName ?? "Unknown Artist")?.name ?? "Unknown Artist")
                            .foregroundColor(.accentColor)

                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        
                        Text(String(album.productionYear)).font(.caption)
                            .opacity(0.6)

                        Spacer()
                    }
                }
                .listRowSeparator(.hidden)

                HStack {
                    Spacer()
                    
                    if album.downloaded {
                        Button(action: {
                            confirmDeleteDownload = true
                        }, label: {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.accentColor)
                        })
                            .buttonStyle(PlainButtonStyle())
                            .confirmationDialog("Remove from Downloads?", isPresented: $confirmDeleteDownload, titleVisibility: Visibility.visible) {
                                Button("Remove", role: .destructive) {
                                    downloadManager.delete(album: album)
                                }
                                
                                Button("Cancel", role: .cancel) {

                                }
                            } message: {
                                Text("You won't be able to play this offline")
                            }

                    } else {
                        Button(action: {
                            downloadManager.download(album: album)
                        }, label: {
                            Image(systemName: "arrow.down.circle")
                                .font(.largeTitle)
                        })
                            .buttonStyle(PlainButtonStyle())
                    }
                                        
                    Button(action: {
                        if album.favorite {
                            networkingManager.unfavorite(jellyfinId: album.jellyfinId!, originalValue: album.favorite, complete: { result in
                                album.favorite = result
                            })
                        } else {
                            networkingManager.favoriteItem(jellyfinId: album.jellyfinId!, originalValue: album.favorite, complete: { result in
                                album.favorite = result
                            })
                        }
                    }, label: {
                        if album.favorite {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.accentColor)
                                .font(.largeTitle)
                        } else {
                            Image(systemName: "heart")
                                .font(.largeTitle)
                        }
                    })
                        .buttonStyle(PlainButtonStyle())

                    
                    Spacer()
                }
                .padding(.bottom, 15)
                
                ForEach(songs) { song in
                    SongRow(song: song, selectedSong: $selectedSong, songs: Array(songs), showPlaylistSheet: $showPlaylistSheet, type: .album)
                }
                
                .sheet(isPresented: $showPlaylistSheet, content: {
                    PlaylistSelectionSheet(song: $selectedSong, showPlaylistSheet: $showPlaylistSheet)
                })
        }

        .listStyle(PlainListStyle())
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
}
    struct AlbumArtwork: View {
        
        var album: Album
                        
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
                                .opacity(Globals.componentOpacity)
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
                .disabled(playlistName.isEmpty)
            }
        }
    }
