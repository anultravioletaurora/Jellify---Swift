//
//  AlbumBackdropImage.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/24/21.
//

import SwiftUI

struct AlbumBackdropImage: View {
    
    @ObservedObject
    var album : FetchedResults<Album>.Element
    
	@State
	var artwork : Data?
	
    let height = UIScreen.main.bounds.height * 1.5
    
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme

    var body: some View {
		ZStack {
			if artwork != nil {
				ZStack {
					Image(data: artwork)
						.resizable()
							.frame(width: height, height: height)
							.brightness(colorScheme == .dark ? -0.1 : 0.0)
							.ignoresSafeArea()
					
					BlurView()
				}
			} else {
				Image("placeholder")
					.frame(width: height, height: height)
					.brightness(colorScheme == .dark ? -0.3 : 0.0)
					.ignoresSafeArea()
			}
			
			BlurView()
		}
		.onAppear(perform: {
			if let image = ImageManager.shared.imageFor(itemId: album.jellyfinId!) {
				artwork = image
				return
			} else {
				ImageManager.shared.download(itemId: album.jellyfinId!, complete: { image in
					artwork = image
					return image
				})
			}
			
			artwork = nil
		})
		.onChange(of: album, perform: { newValue in
			
			if let image = ImageManager.shared.imageFor(itemId: newValue.jellyfinId!) {
				artwork = image
				return
			} else {
				ImageManager.shared.download(itemId: newValue.jellyfinId!, complete: { image in
					artwork = image
					return image
				})
			}
			
			artwork = nil
		})

    }
}
