//
//  AlbumsView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/5/21.
//

import SwiftUI
import simd

struct AlbumsView: View {
    
    @State
    var search: String = ""
    
    var columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    
                    // Search
                    HStack(spacing: 15) {
                        
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary)
                        
                        TextField("Search", text: $search)
                        
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(15)
                    
                    // Grid View of Albums
                    LazyVGrid(columns: columns, spacing: 20){
                        ForEach(1...10, id: \.self) { index in
                            
                            Image("profile")
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width - 100, height: 180, alignment: .center)
                                .aspectRatio(contentMode: .fill)
                                
                                .cornerRadius(15)
                            
                        }
                    }
                    
                }
                .padding()
                .padding(.bottom, 60)
            }.navigationTitle("Albums")
        }
    }
}
