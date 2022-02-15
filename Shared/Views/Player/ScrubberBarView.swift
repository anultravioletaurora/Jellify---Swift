//
//  ScrubberBarView.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 2/14/22.
//

import SwiftUI
import AVFoundation
import MediaPlayer


struct ScrubberBarView: View {
    
    @ObservedObject
    var player = Player.shared
    
    let refreshRateHelper = RefreshRateHelper.shared
        
    var body: some View {
        
        VStack {
            Slider(value: $player.playProgressAhead, onEditingChanged: { (scrubStarted) in
                
                if scrubStarted {
                    self.player.seeking = true
                } else {
                    guard let item = self.player.player?.currentItem else {
                        return
                    }
                    
                    self.player.seek(progress: Double(player.playProgressAhead))
                }
            })

            HStack {
                Text(player.timeElasped)
                    .font(.subheadline)
                
                Spacer()
                
                Text(player.timeRemaining)
                    .font(.subheadline)
            }
        }
        .padding(.horizontal, 25)
        .onAppear(perform: {
            refreshRateHelper.preferredFrameRateRange(.init(minimum: 80, maximum: 120, __preferred: 120))
        })
        .onDisappear(perform: {
            refreshRateHelper.preferredFrameRateRange(.default)
        })
    }
}
