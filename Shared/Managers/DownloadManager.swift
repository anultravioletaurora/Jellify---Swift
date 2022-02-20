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

public class DownloadManager {
    
    static let shared: DownloadManager = DownloadManager()
    let networkingManager : NetworkingManager = NetworkingManager.shared
    
    public func downloadSong(song: Song) {
        let seshId = "\(Double.random(in: 0..<1496213367201))".replacingOccurrences(of: ".", with: "")

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
    
    public func deleteSongDownload(song: Song) {
        SAPlayer.Downloader.deleteDownloaded(withSavedUrl: song.downloadUrl!)
        
        song.downloadUrl = nil
        song.downloaded = false
        song.downloading = false
        try! networkingManager.context.save()
    }
}
