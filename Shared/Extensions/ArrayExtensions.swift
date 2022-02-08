//
//  ArrayExtensions.swift
//  FinTune
//
//  Created by Jack Caulfield on 2/7/22.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
