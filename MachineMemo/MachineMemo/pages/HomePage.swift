//
//  HomePage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/7/25.
//

import SwiftUI

struct HomePage: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App Description
                Text("Welcome to MachineMemo")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Text("MachineMemo helps you keep track of your machine settings at the gym. Never forget the perfect seat height, weight stack, or handle position again!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Icon
                Image(systemName: "dumbbell")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)

                Spacer()
                
            }
            .padding()
        }
    }
}

// Preview
struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}

