//
//  ArtistService.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/10/21.
//

import Foundation
import JellyfinAPI
import Combine

class ArtistService : JellyfinService {

    static let shared = ArtistService()
    
    let albumService = AlbumService.shared
            
    @Published
    var items = [BaseItemDto]()
    
    override init() {
        super.init()
        
        JellyfinAPI.basePath = self.server
        setAuthHeader(with: self.accessToken)
    }
    
    func fetchArtistThumbnail(artist: Artist, complete: @escaping () -> Void) -> Void {
        // Get and set the artist's thumbnail image
        ImageAPI.getItemImage(itemId: artist.jellyfinId!, imageType: .primary, width: 250, height: 250, apiResponseQueue: JellyfinAPI.apiResponseQueue)
            .sink(receiveCompletion: { completion in
                print("Artist image result: \(completion)")
            }, receiveValue: { thumbnailResponse in
                artist.thumbnail = thumbnailResponse
                complete()
                
                // Execute the completion closure if this is the last one in the collection
//
            })
            .store(in: &self.cancellables)
    }
    
    func retrieveArtistFromCore(artistId: String) -> [Artist] {
        let fetchRequest = Artist.fetchRequest()

        // TODO: Fix this since it isn't retrieving the artist
        fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", artistId)
                
        do {
            return try JellyfinService.context.fetch(fetchRequest)
        } catch let error as NSError {
            // TODO: handle the error
            print(error)
            
            return []
        }
    }
    
    func retrieveArtist(artistId: String, complete: @escaping (Artist) -> Void) {
                
        print("Retrieving artist \(artistId)")
        
        let artistStoreResult : [Artist] = self.retrieveArtistFromCore(artistId: artistId);
                
        if artistStoreResult.isEmpty {
            ItemsAPI.getItems(userId: self.userId, ids: [artistId], apiResponseQueue: JellyfinAPI.apiResponseQueue)
                .subscribe(on: processingQueue)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { complete in
                    switch complete {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error retrieving artist: \(error)")
                    }
                }, receiveValue: { artistsResult in
                    
                    if (artistsResult.items != nil) {
                    
                        let artistResult = artistsResult.items!.first!
                        
                        let artist : Artist = Artist(context: JellyfinService.context)
                        
                        artist.jellyfinId = artistResult.id!
                        artist.name = artistResult.name ?? ""
                        artist.dateCreated = artistResult.dateCreated?.formatted() ?? ""
                        artist.overview = artistResult.overview
                        
                        // Get and set the artist's thumbnail image
                        ImageAPI.getItemImage(itemId: artistResult.id!, imageType: .primary, width: 250, height: 250, apiResponseQueue: JellyfinAPI.apiResponseQueue)
                            .sink(receiveCompletion: { completion in
                                print("Artist image result: \(completion)")
                            }, receiveValue: { thumbnailResponse in
                                artist.thumbnail = thumbnailResponse
                            })
                            .store(in: &self.cancellables)
                                                
                        complete(artist)
                    }
                })
                .store(in: &cancellables)
        } else {
            complete(artistStoreResult.first!)
        }
    }
    
    func retrieveArtists(complete: @escaping () -> Void) {
                   
        deleteAllEntities()
        
        ArtistsAPI.getAlbumArtists(minCommunityRating: nil, startIndex: nil, limit: nil, searchTerm: nil, parentId: nil, fields: [ItemFields.primaryImageAspectRatio, ItemFields.sortName, ItemFields.basicSyncInfo], excludeItemTypes: nil, includeItemTypes: nil, filters: nil, isFavorite: nil, mediaTypes: nil, genres: nil, genreIds: nil, officialRatings: nil, tags: nil, years: nil, enableUserData: true, imageTypeLimit: nil, enableImageTypes: nil, person: nil, personIds: nil, personTypes: nil, studios: nil, studioIds: nil, userId: self.userId, nameStartsWithOrGreater: nil, nameStartsWith: nil, nameLessThan: nil, enableImages: nil, enableTotalRecordCount: nil, apiResponseQueue: JellyfinAPI.apiResponseQueue)
            .sink(receiveCompletion: { error in
                print(error)
                
            }, receiveValue: { response in

                if response.items != nil {
                    
                    response.items!.forEach({ artistResult in
                        
                        let artist : Artist? = self.retrieveArtistFromCore(artistId: artistResult.id!).first
                            // Check if artist already exists in store
                        if artist == nil {
                            let artist = Artist(context: JellyfinService.context)
                            
                            artist.jellyfinId = artistResult.id!
                            artist.name = artistResult.name ?? ""
                            artist.dateCreated = artistResult.dateCreated?.formatted() ?? ""
                            artist.overview = artistResult.overview
                            
                            // Get and set the artist's thumbnail image
                            ImageAPI.getItemImage(itemId: artistResult.id!, imageType: .primary, width: 250, height: 250, apiResponseQueue: JellyfinAPI.apiResponseQueue)
                                .sink(receiveCompletion: { completion in
                                    print("Artist image result: \(completion)")
                                }, receiveValue: { thumbnailResponse in
                                    artist.thumbnail = thumbnailResponse
                                    
                                    // Execute the completion closure if this is the last one in the collection
    //
                                })
                                .store(in: &self.cancellables)
                            
//                            self.albumService.retrieveAlbums(artist: artist, complete: {
//                                if response.items!.last == artistResult {
//
//                                    self.saveContext()
//                                    complete()
//                                }
//                            })
                        }
                                                
                        // Retrieve the artists albums
                        self.albumService.retrieveAlbums(artist: artist, complete: {
                            
                            print("Retrieved albums for \(artist!.name)")
                            if response.items!.last == artistResult {

                                self.saveContext()
                                complete()
                            }
                        })
                    })
                }
            })
        .store(in: &cancellables)
                
//        self.get(url: "/Artists/AlbumArtists", params: [
//            "userId": self.userId,
//            "mediaType": "Audio",
//            "enableImages": "true"
//        ], completion: { data in
//
//            let artistResults = try! self.decoder.decode(ResultSet<ArtistResult>.self, from: data)
//
//            complete(artistResults)
//        })
    }
    
    private func artistExistsInCoreData(artistResult: BaseItemDto) -> Bool {
        print("Retrieving artist \(artistResult.id!)")
        
        let fetchRequest = Artist.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "jellyfinId = %@", artistResult.id! as CVarArg)
        
        var artistStoreResult : [Artist] = []
        
        do {
            
            try JellyfinService.context.save()
            
            artistStoreResult = try JellyfinService.context.fetch(fetchRequest)
            
            return !artistStoreResult.isEmpty
            
        } catch let error as NSError {
            // TODO: handle the error
            print(error)
            
            return false
        }
    }
}
