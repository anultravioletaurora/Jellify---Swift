//
//  AlbumsView.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 2/13/22.
//

import SwiftUI

struct AlbumsView: View {
    
    @State
    var limit = Globals.FETCH_PAGE_SIZE
    
    @State
    var galleryView : Bool = UserDefaults.standard.bool(forKey: "artistGalleryView")

    var body: some View {
        NavigationView {
            
            VStack {
                if galleryView {
                    AlbumsGalleryView(limit: $limit)
                } else {
                    AlbumsListView(limit: $limit)
                }
            }
            // This overlay prevents list content from appearing behind the tab view when dismissing the player
            .overlay(content: {
                BlurView()
                    .offset(y: UIScreen.main.bounds.height - 150)
            })
            .navigationTitle("Albums")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            galleryView.toggle()
                            UserDefaults.standard.set(self.galleryView, forKey: "artistGalleryView")
                        }
                    }, label: {
                        if galleryView {
                            Image(systemName: "list.bullet")
                        } else {
                            Image(systemName: "circle.grid.2x2")
                        }
                    })
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    SyncLibraryButton()
                }
            }
        }
    }
}
