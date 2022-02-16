//
//  VolumeSlider.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/24/21.
//

import SwiftUI
import MediaPlayer
import UIKit

struct VolumeSlider: View {
    @ObservedObject private var volObserver = VolumeObserver.shared
    @ObservedObject var player = Player.shared

    @State var volume : Float = 0

    var body: some View {
        
        HStack {

            Image(systemName:"speaker.wave.1")

            Slider(value: $volume, onEditingChanged: { _ in
            })
                .onChange(of: volume, perform: { _ in

                    if player.player != nil {
                        volObserver.setVolume(volume: volume)
//                        volObserver.setVolume(volume: volume)
                        player.player?.volume = volume
                    }
                })

            Image(systemName:"speaker.wave.3")
        }
        .padding(.horizontal, 25)
        .onAppear(perform: {
            volume = volObserver.volume
        })
    }
}
//
//struct VolumeSlider: UIViewRepresentable {
//   func makeUIView(context: Context) -> MPVolumeView {
//      MPVolumeView(frame: .zero)
//   }
//
//   func updateUIView(_ view: MPVolumeView, context: Context) {}
//}

