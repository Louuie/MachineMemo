//
//  SpinnerView.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 2/20/25.
//

import SwiftUI

struct SpinnerView: View {
    var body: some View {
        VStack {
            LottieView(filename: "dumbell_spinner")
                .frame(width: 150, height: 150)
            Text("Refreshing your session...")
                .font(.headline)
        }
    }
}
