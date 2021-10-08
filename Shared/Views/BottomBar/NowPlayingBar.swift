//
//  Player.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/7/21.
//

import SwiftUI

/**
 Component for the now playing bar that morphs into the full player UI
 */
struct NowPlayingBar<Content: View>: View {
    
    var content: Content
    
    @Binding
    var showMediaPlayer: Bool
    
    var animation: Namespace.ID
        
    @ViewBuilder
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // View Content
            content
            
            // Now Playing Bar
            ZStack {
                Rectangle().foregroundColor(Color.white.opacity(0.0)).frame(width: UIScreen.main.bounds.size.width, height: 65).background(BlurView())
                HStack {
                    Button(action: {
                        showMediaPlayer.toggle()
                    }) {
                        HStack {
                            Image("profile")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .cornerRadius(5)
                                .shadow(radius: 6, x: 0, y: 3)
                                .padding(.leading)
                            
                            Text("Viva La Vida")
                                .padding(.leading, 10)
                            Spacer()
                        }
                    }.buttonStyle(PlainButtonStyle())
                    Button(action: {
                        // Play / Pause music
                        
                    }) {
                        Image(systemName: "play.fill").font(.title3)
                    }.buttonStyle(PlainButtonStyle()).padding(.horizontal)
                    Button(action: {
                        // Skip track
                        
                    }) {
                        Image(systemName: "forward.fill").font(.title3)
                    }.buttonStyle(PlainButtonStyle()).padding(.trailing, 30)
                }
            }
            
            Divider()
        }
    }
}
