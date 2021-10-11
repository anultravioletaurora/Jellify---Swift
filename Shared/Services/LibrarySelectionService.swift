//
//  LibrarySelectionService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/10/21.
//

import Foundation

class LibrarySelectionService: JellyfinService {
    
    static let shared = LibrarySelectionService()
    
    @Published
    var selected : Bool = false
    
    override init() {
        super.init()
        selected = LibrarySelectionService.libraryId != nil
    }
    
    func isSelected() -> Bool {
        return UserDefaults.standard.string(forKey: "LibraryId") != nil
    }
    
    func retrieveLibraries(complete: @escaping (ResultSet<LibraryResult>) -> Void) {
        print("Retrieving libraries, access token is: \(LibrarySelectionService.accessToken!)")
        
        self.get(url: "/Users/\(getUserId())/Items", params: [:], completion: { data in
                               
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            print(json)
            
            let libraryResult = try! self.decoder.decode(ResultSet<LibraryResult>.self, from: data)
            
            let musicLibraries = libraryResult.items.filter({ library in
                library.collectionType == "music"
            })
            
            if (musicLibraries.count == 1) {
                
                JellyfinService.libraryId = musicLibraries[0].id
                UserDefaults.standard.set(musicLibraries[0].id, forKey: "LibraryId")
                self.selected = true
            }
            
            complete(libraryResult)
        })
    }
    
    func saveLibrary(selectedLibrary: LibraryResult) {
        
        JellyfinService.libraryId = selectedLibrary.id
        UserDefaults.standard.set(selectedLibrary.id, forKey: "LibraryId")
        selected = true
    }
}
