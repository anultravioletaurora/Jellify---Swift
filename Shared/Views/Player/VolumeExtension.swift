//
//  VolumeExtension.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/24/21.
//

import Foundation
import MediaPlayer

extension MPVolumeView {
    func setVolume(_ volume: Float) {
        
        print("Setting system volume to: \(volume)")
        let slider = self.subviews.first(where: { $0 is UISlider }) as? UISlider

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}
