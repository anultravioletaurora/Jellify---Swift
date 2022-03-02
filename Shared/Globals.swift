//
//  Globals.swift
//  Jellify
//
//  Created by Jack Caulfield on 2/16/22.
//

import Foundation
import UIKit

public class Globals{
    public static let playProgressRefresh: Double = 0.3
    public static let componentOpacity: Double = 0.6
    public static let debounceDuration: Double = 0.5
    
    public static let VIEW_FETCH_PAGE_SIZE : Int = 500
    public static let API_FETCH_PAGE_SIZE : Int = 10000
    public static let ARTWORK_FRAME : CGFloat = UIScreen.main.bounds.height / 4
    public static let MARQUEE_FADE : CGFloat = 16
    public static let MARQUEE_WAIT_DURATION : CGFloat = 3
}
