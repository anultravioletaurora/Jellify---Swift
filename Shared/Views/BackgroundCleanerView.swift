//
//  BackgroundCleanerView.swift
//  FinTune
//
//  Created by Jack Caulfield on 10/17/21.
//

import SwiftUI

struct BackgroundCleanerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            
            var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

            visualEffectView.frame = (view.superview?.superview!.bounds)!

            view.superview?.addSubview(visualEffectView)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

public extension View{
    @ViewBuilder
    func clearBackground(_ enable:Bool = true) -> some View{
        if enable{
            background(BackgroundCleanerView())
        }
        else {
            self
        }
    }
}
