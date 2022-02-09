//
//  ItemThumbnail.swift
//  FinTune (iOS)
//
//  Created by Jack Caulfield on 10/24/21.
//

import SwiftUI

struct ItemThumbnail: View {
    
    var thumbnail : Data?
            
    let itemId : String
    
    let frame : CGFloat
    
    let cornerRadius : CGFloat
        
    var body: some View {
        if thumbnail != nil {
            Image(data: thumbnail!)
                .resizable()
                .frame(width: frame, height: frame)
                .cornerRadius(cornerRadius)
        } else {
            Image("placeholder")
                .resizable()
                .frame(width: frame, height: frame)
                .cornerRadius(cornerRadius)
        }

    }
    
    
}
