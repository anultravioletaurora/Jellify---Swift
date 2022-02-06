//
//  ImageService.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 2/2/22.
//

import Foundation
import JellyfinAPI
import Combine

class ImageService : JellyfinService {
    static let shared = ImageService()
    
    override init() {
        super.init()
        
        JellyfinAPI.basePath = self.server
        setAuthHeader(with: self.accessToken)
    }
    
    func fetchPrimaryImage(itemId: String, imageType: ImageType, complete: @escaping (URL) -> URL) -> Void {
        ImageAPI.getItemImage(itemId: itemId, imageType: imageType)
            .subscribe(on: processingQueue)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                
            }, receiveValue: { primaryImage in
                complete(primaryImage)
            })
            .store(in: &self.cancellables)
    }
}
