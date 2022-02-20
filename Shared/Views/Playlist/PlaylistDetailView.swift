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
    
    @State
    var selectedSong: Song?
    
    @State
    var showPlaylistSheet: Bool = false

    
    init(playlist: Playlist) {
        self.playlist = playlist
        
        self.fetchRequest = FetchRequest(
            entity: PlaylistSong.entity(),
            sortDescriptors: [NSSortDescriptor(key: #keyPath(PlaylistSong.indexNumber), ascending: true)],
            predicate: NSPredicate(format: "(playlist == %@)", playlist)
        )
    }
    
    var body: some View {
        List(playlistSongs) { (playlistSong : PlaylistSong) in
                
                Button(action: {
                    Player.shared.loadSongs(playlistSongs.map { song in
                        return song.song!
                    }, songId: playlistSong.song!.jellyfinId!)
                    Player.shared.isPlaying = true
                }, label: {
                    SongRow(song: playlistSong.song!, selectedSong: $selectedSong, songs: playlistSongs.map { $0.song! }, showPlaylistSheet: $showPlaylistSheet, type: .songs)
                })
                .onAppear(perform: {
                    if playlistSong.song!.album != nil && playlistSong.song!.album!.thumbnail == nil {
                        networkingManager.loadAlbumArtwork(album: playlistSong.song!.album!)
                    }
                })
                .swipeActions(allowsFullSwipe: true, content: {
                    Button(action: {
                        print("Playlist Item Swiped to delete")
                        
                        networkingManager.deleteFromPlaylist(playlist: playlist, playlistSong: playlistSong)
                    }) {
                        Image(systemName: "trash")
                            .background(.red)
                    }
                    .tint(.red)

                })
                .buttonStyle(PlainButtonStyle())
        }
        
        // Give this list an ID, because if the user adds a song to this playlist and navigates back to this view,
        // it'll cause a crash
        .id(UUID())
        
        // This overlay prevents list content from appearing behind the tab view when dismissing the player
        .overlay(content: {
            BlurView()
                .offset(y: UIScreen.main.bounds.height - 150)
        })
        .listStyle(PlainListStyle())
        .navigationTitle(playlist.name ?? "Unknown Playlist")
        .navigationBarTitleDisplayMode(.inline)

    }
}
