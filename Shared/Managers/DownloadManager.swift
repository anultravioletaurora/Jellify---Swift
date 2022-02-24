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
import SwiftAudioPlayer
import HLSion
import AVFoundation

public class DownloadManager {
    
    static let shared: DownloadManager = DownloadManager()
    let networkingManager : NetworkingManager = NetworkingManager.shared
    
    public func download(song: Song){
         withAnimation{
             song.downloading = true
         }
             print("Starting")
                
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
    
    public func downloadSong(song: Song) {
        let seshId = "\(Double.random(in: 0..<1496213367201))".replacingOccurrences(of: ".", with: "")
        
        song.downloading = true
        DispatchQueue.main.async {
            try! self.networkingManager.context.save()
        }

        SAPlayer.Downloader.downloadAudio(withRemoteUrl: AVPlayerItemId.getStream(songId: song.jellyfinId!, sessionId: seshId), completion: { url, error in
            
            if error == nil {
                song.downloadUrl = url
                song.downloaded = true
                song.downloading = false
            } else {
                song.downloaded = false
                song.downloading = false
            }
            
            DispatchQueue.main.async {
                try! self.networkingManager.context.save()
            }
        })
    }
    
    public func cancelSongDownload(song: Song) {
        
        if let url = song.downloadUrl {
            SAPlayer.Downloader.cancelDownload(withRemoteUrl: url)
            
            song.downloaded = false
            song.downloading = false
        }
    }
    
    public func delete(song: Song) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("\(song.jellyfinId!).m4a")
        
        try! fileManager.removeItem(at: soundURL!)
        
        song.downloaded = false
        
        song.downloading = false
        self.networkingManager.saveContext()

    }
}
