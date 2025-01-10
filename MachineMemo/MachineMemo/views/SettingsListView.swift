//
//  SettingsListView.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/9/25.
//

import SwiftUI

struct SettingsListView: View {
    @State private var isLoading: Bool = false
    @State private var settings: [Setting] = [] // Array of `Setting` objects
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Loading Settings...")
            } else {
                List {
                    ForEach(settings, id: \.machine_id) { setting in
                        Section(header: Text("Machine ID: \(setting.machine_id)")) {
                            ForEach(setting.settings.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                HStack {
                                    Text(key).bold() // Display the key
                                    Spacer()
                                    Text(value) // Display the value
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Settings")
                .onAppear() {
                    Task {
                        await loadSettings()
                    }
                }
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }

    private func loadSettings() async {
        isLoading = true
        do {
            settings = try await MachineAPI.shared.getSettings()
            print("Fetched Settings: \(settings)") // Debugging
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching settings: \(error)") // Debugging
            isLoading = false
        }
    }

}

