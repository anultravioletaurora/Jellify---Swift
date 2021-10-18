//
//  AlbumService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/10/21.
//

import Foundation
import CoreData

class AlbumService : JellyfinService {
    
    static let shared = AlbumService()
        
    func retrieveAlbums(artistId: String?, complete: @escaping (ResultSet<AlbumResult>) -> Void) {
                        
        self.get(url: "/Users/\(self.userId)/Items", params: [
//            "parentId": self.libraryId,
            "artistIds": artistId!,
            "includeItemTypes": "MusicAlbum",
            "recursive": "true"
            
        ], completion: { data in
                               
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            print(json!)
            
            let albumResult = try! self.decoder.decode(ResultSet<AlbumResult>.self, from: data)
                                   
            complete(albumResult)
        })
    }
    
    func retrieveAlbum(albumId: String, complete: @escaping (Album) -> Void) {
        
        print("Retrieving album \(albumId)")
        
        let fetchRequest = Album.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "jellyfinId = %@", albumId)
        
        var albumStoreResult : [Album] = []
        
        do {
            albumStoreResult = try JellyfinService.context.fetch(fetchRequest)
            
        } catch let error as NSError {
            // TODO: handle the error
            print(error)
        }
        
        if !albumStoreResult.isEmpty {
            
            print("Album found in Core Data \(albumId)")

            print("Returning album \(albumId)")
            
            complete(albumStoreResult[0])
        } else {
            
            print("Item not found in Core Data, retrieving from API \(albumId)")

            self.get(url: "/Users/\(self.userId)/Items/\(albumId)", params: [
                "includeItemTypes": "MusicAlbum",
                "recursive": "true"
                
            ], completion: { data in
                                   
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                print(json!)
                
                let albumResult = try? self.decoder.decode(AlbumResult.self, from: data)
                                       
                if albumResult != nil {
                    
                    let album : Album = Album(context: JellyfinService.context)
                                        
                    album.jellyfinId = albumResult!.id
                    album.name = albumResult!.name
                    album.productionYear = Int16(albumResult!.productionYear ?? 0)
                    
                    print("Returning album \(albumId)")
                    
                    complete(album)
                }
            })

        }
    }
}

