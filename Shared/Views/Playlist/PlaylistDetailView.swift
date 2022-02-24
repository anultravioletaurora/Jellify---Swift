//
//  PlaylistDetailView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/15/21.
//

import SwiftUI

struct PlaylistDetailView: View {
    
    @ObservedObject
    var playlist : Playlist
        
    var fetchRequest: FetchRequest<PlaylistSong>
    
    var playlistSongs: FetchedResults<PlaylistSong>{
        fetchRequest.wrappedValue
    }
    
    let networkingManager : NetworkingManager = NetworkingManager.shared
    let downloadManager : DownloadManager = DownloadManager.shared
    
    @State
    var selectedSong: Song?
    
    @State
    var showPlaylistSheet: Bool = false
    
    @State
    var confirmDeleteDownload : Bool = false

    @EnvironmentObject
    var player : Player

    init(playlist: Playlist) {
        self.playlist = playlist
        
        self.fetchRequest = FetchRequest(
            entity: PlaylistSong.entity(),
            sortDescriptors: [NSSortDescriptor(key: #keyPath(PlaylistSong.indexNumber), ascending: true)],
            predicate: NSPredicate(format: "(playlist == %@)", playlist)
        )
    }
    
    var body: some View {
        List {
            
            PlaylistArtwork(playlist: playlist)
                .listRowSeparator(Visibility.hidden)
            
            HStack {
                
                Spacer()
                
                Text(playlist.name ?? "Unknown Playlist")
                    .font(.title3)
                    .semibold()
                
                Spacer()
            }
            .listRowSeparator(.hidden)
            
            HStack {
                Spacer()
                
                if playlist.downloaded {
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
                                downloadManager.delete(playlist: playlist)
                            }
                            
                            Button("Cancel", role: .cancel) {

                            }
                        } message: {
                            Text("You won't be able to play this offline")
                        }

                } else {
                    Button(action: {
                        downloadManager.download(playlist: playlist)
                    }, label: {
                        Image(systemName: "arrow.down.circle")
                            .font(.largeTitle)
                    })
                        .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
            .padding(.bottom, 15)
            
            
            ForEach(playlistSongs) { playlistSong in
                
                // Check that the song exists here, in the case of a user adding or removing a song to a playlist
                // while it's detail open, this check will prevent a crash
                if playlistSong.song != nil {
                    Button(action: {
                        player.loadSongs(playlistSongs.map { song in
                            return song.song!
                        }, songId: playlistSong.song!.jellyfinId!)
                        player.isPlaying = true
                    }, label: {
                        SongRow(song: playlistSong.song!, selectedSong: $selectedSong, songs: playlistSongs.map { $0.song! }, showPlaylistSheet: $showPlaylistSheet, type: .songs)
                    })
                    .onAppear(perform: {
                        if playlistSong.song != nil && playlistSong.song!.album != nil && playlistSong.song!.album!.thumbnail == nil {
                            networkingManager.loadAlbumArtwork(album: playlistSong.song!.album!)
                        }
                    })
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .onDelete { indexSet in
                networkingManager.deleteFromPlaylist(playlist: playlist, indexSet: indexSet)
            }
            .onMove { indexSet, index in
                networkingManager.moveInPlaylist(playlist: playlist, indexSet: indexSet, newIndex: index)
            }
        }
        
        .toolbar {
            EditButton()
        }
                
        // This overlay prevents list content from appearing behind the tab view when dismissing the player
        .overlay(content: {
            BlurView()
                .offset(y: UIScreen.main.bounds.height - 150)
        })
        .listStyle(PlainListStyle())
        .sheet(isPresented: $showPlaylistSheet, content: {
            PlaylistSelectionSheet(song: $selectedSong, showPlaylistSheet: $showPlaylistSheet)
        })
    }
}
