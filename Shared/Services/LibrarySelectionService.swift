//
//  LibrarySelectionService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/10/21.
//

import Foundation
import SwiftUI

class LibrarySelectionService: JellyfinService {
    
    static let shared = LibrarySelectionService()
    
    let networkingManager = NetworkingManager.shared
                    
    @Published
    var selected : Bool = false
    
    override init() {

        super.init()
        
        selected = !self.libraryId.isEmpty
    }
    
    func isSelected() -> Bool {
        return UserDefaults.standard.string(forKey: "LibraryId") != nil
    }
    
    func retrieveLibraries(complete: @escaping (ResultSet<LibraryResult>) -> Void) {
        
        print(JellyfinService.users)
                
        self.get(url: "/Users/\(networkingManager.userId)/Items", params: [:], completion: { data in
                               
//            let json = try? JSONSerialization.jsonObject(with: data, options: [])
                        
            let libraryResult = try! self.decoder.decode(ResultSet<LibraryResult>.self, from: data)
            
            let musicLibraries = libraryResult.items.filter({ library in
                library.collectionType == "music"
            })
            
            let playlistLibrary = libraryResult.items.filter({ library in
                library.collectionType == "playlists"
            })
            
            if (musicLibraries.count == 1) {
                
                self.user!.musicLibraryId = musicLibraries[0].id
            }
            
            if playlistLibrary.count >= 1 {
                self.user!.playlistLibraryId = playlistLibrary[0].id
            }
            
            complete(libraryResult)
        })
    }
    
    func saveLibrary(selectedLibrary: LibraryResult) {
        
        self.user!.musicLibraryId = selectedLibrary.id
        
        try! JellyfinService.context.save()

        selected = true
    }
}
