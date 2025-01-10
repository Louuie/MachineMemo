//
//  SettingsListView.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/9/25.
//

import SwiftUI

struct SettingsListView: View {
    @State private var isLoading: Bool = false
    @State private var settings: Setting = Setting(machine_id: "12345", settings: ["seat_height": "4", "back_seat": "2"])
    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Loading Settings...")
            } else {
                List() {
                    ForEach(Array(settings.settings), id: \.key) { key, value in
                        VStack {
                            Text("\(key)")
                            Text("\(value)")
                        }
                        .navigationTitle("Settings")
                        .task {
                            await loadSettings()
                        }
                    }
                }
            }
        }
    }
    private func loadSettings() async {
        do {
           // TODO: Finish implementing this, need to add the logic of fetching settings in 'MachineAPI'
        }
    }
}

#Preview {
    SettingsListView()
}
