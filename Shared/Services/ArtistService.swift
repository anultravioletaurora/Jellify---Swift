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
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var items = [BaseItemDto]()
    
    override init() {
        super.init()
        
        JellyfinAPI.basePath = self.server
        setAuthHeader(with: self.accessToken)
    }
    
    func getAlbumArt(id: String, maxSize: Int? = nil) ->String{
        return "\(server)/Items/\(id)/Images/Primary\(maxSize != nil ? "?maxHeight=\(maxSize ?? 0)&maxWidth=\(maxSize ?? 0)&quality=250" : "")"
    }
    
    func retrieveArtists(complete: @escaping (ResultSet<ArtistResult>) -> Void) {
                   
        ArtistsAPI.getAlbumArtists(minCommunityRating: nil, startIndex: nil, limit: nil, searchTerm: nil, parentId: nil, fields: [ItemFields.primaryImageAspectRatio, ItemFields.sortName, ItemFields.basicSyncInfo], excludeItemTypes: nil, includeItemTypes: nil, filters: nil, isFavorite: nil, mediaTypes: nil, genres: nil, genreIds: nil, officialRatings: nil, tags: nil, years: nil, enableUserData: true, imageTypeLimit: nil, enableImageTypes: nil, person: nil, personIds: nil, personTypes: nil, studios: nil, studioIds: nil, userId: self.userId, nameStartsWithOrGreater: nil, nameStartsWith: nil, nameLessThan: nil, enableImages: nil, enableTotalRecordCount: nil, apiResponseQueue: JellyfinAPI.apiResponseQueue)
            .sink(receiveCompletion: { error in
                print(error)
                
            }, receiveValue: { response in

                print("Printing response: \(response.items?[0].name ?? "")")
            })
        .store(in: &cancellables)
                
        self.get(url: "/Artists/AlbumArtists", params: [
            "userId": self.userId,
            "mediaType": "Audio",
            "enableImages": "true"
        ], completion: { data in
                                           
            let artistResults = try! self.decoder.decode(ResultSet<ArtistResult>.self, from: data)
                                               
            complete(artistResults)
        })
    }
}
