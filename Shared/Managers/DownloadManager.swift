//
//  DownloadManager.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/19/22.
//

import Foundation
import CoreData
import SwiftUI
import JellyfinAPI
import AVFoundation

public class DownloadManager {
    
    static let shared: DownloadManager = DownloadManager()
    let networkingManager : NetworkingManager = NetworkingManager.shared
    
    public func download(album: Album) -> Void {
        
        album.downloaded = true
        networkingManager.saveContext()
        
        if let songs = album.songs?.allObjects as? [Song] {
            songs.filter({ !$0.downloaded }).forEach({ song in
                self.download(song: song)
            })
        }
    }
    
    public func download(playlist: Playlist) -> Void {
        
        playlist.downloaded = true
        networkingManager.saveContext()
        
        if let songs = playlist.songs?.allObjects as? [PlaylistSong] {
            songs.map { $0.song }.filter { $0 != nil && !$0!.downloaded }.forEach({ song in
                self.download(song: song!)
            })
        }
    }
    
    public func download(song: Song) -> Void {
                
        song.downloading = true
        
        LibraryAPI.getDownload(itemId: song.jellyfinId!)
            .sink(receiveCompletion: { completion in
                
                
            }, receiveValue: { audioUrl in
                
                let fileManager = FileManager.default
                let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
                let documentDirectory = urls[0] as NSURL
                let soundURL = documentDirectory.appendingPathComponent("\(song.jellyfinId!).m4a")
                
                let audio = try! Data(contentsOf: audioUrl)
                                
                try! audio.write(to: soundURL!)
                
                if soundURL!.isFileURL && AVURLAsset(url: soundURL!).isPlayable {
                    song.downloadUrl = soundURL
                    song.downloaded = true
                } else {
                    song.downloaded = false
                }
                
                song.downloading = false
                self.networkingManager.saveContext()
            })
            .store(in: &networkingManager.cancellables)
    }
    
    public func delete(album: Album) {
        
        if let songs = album.songs?.allObjects as? [Song] {
            songs.forEach({ song in
                
                // If this song is downloaded in a playlist elsewhere, we won't remove it
                if let playlistSongs = song.playlists?.allObjects as? [PlaylistSong] {
                    
                    // Get all of the playlists this album's song is associated with
                    let playlists : [Playlist] = playlistSongs.map({ $0.playlist! })
                    
                    // Find out if any of them are downloaded
                    let downloadedPlaylists = playlists.filter({ $0.downloaded })
                    
                    if downloadedPlaylists.isEmpty {
                        self.delete(song: song)
                    }
                }
            })
        }
        
        album.downloaded = false
        networkingManager.saveContext()
    }
    
    public func delete(playlist: Playlist) {
        
        if let songs = playlist.songs?.allObjects as? [PlaylistSong] {
            songs.map { $0.song }.filter { $0 != nil && $0!.downloaded }.forEach({ song in
                
                // If this song's album is still downloaded, then we'll keep the track
                if song!.album == nil || !song!.album!.downloaded {
                    self.delete(song: song!)
                }
            })
        }
        
        playlist.downloaded = false
        networkingManager.saveContext()
    }
    
    public func delete(song: Song) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("\(song.jellyfinId!).m4a")
        
        do {
            try fileManager.removeItem(at: soundURL!)
        } catch {
            print("Unable to delete song, marking as deleted")
        }
        
        // Check if this song was the last one downloaded for an album or playlist, if it was,
        // then we'll mark those as not downloaded
        if let album = song.album {
            if let albumSongs = album.songs?.allObjects as? [Song] {
                
                if albumSongs.filter({ $0 != song && $0.downloaded }).isEmpty {
                    album.downloaded = false
                }
            }
        }
        
        if let playlistSongs = song.playlists?.allObjects as? [PlaylistSong] {
            playlistSongs.map({ $0.playlist }).forEach({ playlist in
                
                if let songs = playlist!.songs?.allObjects as? [PlaylistSong] {
                    
                    if songs.filter({ $0.song! != song && $0.song!.downloaded }).isEmpty {
                        playlist?.downloaded = false
                    }
                }
            })
        }
        
        song.downloaded = false
        song.downloading = false
        self.networkingManager.saveContext()
    }
}
