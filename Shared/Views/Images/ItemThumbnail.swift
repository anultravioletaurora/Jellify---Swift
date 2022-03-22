//
//  ItemThumbnail.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 10/24/21.
//

import SwiftUI

struct ItemThumbnail: View {
                
	@State
	var thumbnail : Data?
	
    var itemId : String
    
    let frame : CGFloat
    
    let cornerRadius : CGFloat
	
	let imageManager = ImageManager.shared
        
    var body: some View {
        if thumbnail != nil {
            Image(data: thumbnail!)
                .resizable()
                .frame(width: frame, height: frame)
                .cornerRadius(cornerRadius)
				.onChange(of: itemId, perform: { newValue in
					if let image = imageManager.imageFor(itemId: newValue) {
						self.thumbnail = image
						return
					} else {
						imageManager.download(itemId: newValue, complete: { image in
							self.thumbnail = image
							return image
						})
					}
					
					self.thumbnail = nil
				})
        } else {
            Image("placeholder")
                .resizable()
                .frame(width: frame, height: frame)
                .cornerRadius(cornerRadius)
				.onAppear(perform: {
					
					if let image = imageManager.imageFor(itemId: self.itemId) {
						self.thumbnail = image
						return
					} else {
						imageManager.download(itemId: self.itemId, complete: { image in
							self.thumbnail = image
							return image
						})
					}
				})
				.onChange(of: itemId, perform: { newValue in
					if let image = imageManager.imageFor(itemId: newValue) {
						self.thumbnail = image
						return
					} else {
						imageManager.download(itemId: newValue, complete: { image in
							self.thumbnail = image
							return image
						})
					}
					
					self.thumbnail = nil
				})
        }

    }
    
    
}
