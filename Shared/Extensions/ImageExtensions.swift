//
//  ImageExtensions.swift
//  JellyTuner
//
//  Created by Jack Caulfield on 2/9/22.
//

import Foundation
import SwiftUI

extension Image {

    public init(data: Data?) {
        guard let data = data,
            let uiImage = UIImage(data: data) else {
                self = Image("placeholder")
                return
        }
        self = Image(uiImage: uiImage)
    }
}
