//
//  AlbumsView.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 2/13/22.
//

import SwiftUI

struct AlbumsView: View {
    
    @State
    var limit = Globals.VIEW_FETCH_PAGE_SIZE
    
    @EnvironmentObject
    var settings : Settings

    var body: some View {
        NavigationView {
            
            VStack {
                if settings.displayAsGallery {
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
                            settings.displayAsGallery.toggle()
                        }
                    }, label: {
                        if settings.displayAsGallery {
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
		.navigationViewStyle(.stack) 
    }
}
