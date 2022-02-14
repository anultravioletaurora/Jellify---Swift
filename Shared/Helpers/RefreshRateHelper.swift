//
//  RefreshRateHelper.swift
//  Jellify (iOS)
//
//  Created by Jack Caulfield on 2/13/22.
//

import Foundation
import QuartzCore

@available(iOS 15.0, *)
class RefreshRateHelper {

    static let shared = RefreshRateHelper()
    
    private var displayLink:CADisplayLink? = nil

   init() {
        displayLink = CADisplayLink(target: self, selector: #selector(ignore))
        displayLink?.add(to: .current, forMode: .default)
    }

    @objc
    func ignore(link: CADisplayLink) {
    }

    func preferredFrameRateRange(_ range:CAFrameRateRange){
        displayLink?.preferredFrameRateRange = range
    }

}
