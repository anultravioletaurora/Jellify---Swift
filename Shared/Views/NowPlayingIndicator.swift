//
//  NowPlayingIndicator.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/23/22.
//

import SwiftUI

struct NowPlayingIndicator: View {
    
    @ObservedObject
    var player = Player.shared
    
    @Environment(\.colorScheme)
    var colorScheme
    
    var body: some View {
                
        ZStack {
            Circle().fill(Color.accentColor).frame(width: 30, height: 30)
            
            Image(systemName: "speaker.wave.3")
                .font(.body)
                .foregroundColor(colorScheme == .dark ? .black : .white)
        }
    }
}
