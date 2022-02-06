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
    
    let height = UIScreen.main.bounds.height * 1.5
    
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme

    var body: some View {
        if album.artwork != nil {
            AsyncImage(url: album.artwork!) { image in
                
                ZStack {
                    image.resizable()
                        .frame(width: height, height: height)
                        .brightness(colorScheme == .dark ? -0.3 : 0.0)
                        .ignoresSafeArea()
                    
                    BlurView()
                }


            } placeholder: {
                Image("appIcon")
                    .frame(width: height, height: height)
            }
        } else {
            Image("appIcon")
                .frame(width: height, height: height)
        }
    }
}
