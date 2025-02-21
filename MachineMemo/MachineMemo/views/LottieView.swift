//
//  LottieView.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 2/20/25.
//
import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var filename: String

    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: filename)
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
