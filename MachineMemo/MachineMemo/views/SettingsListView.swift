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
    @State private var errorMessage: String? = ""

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading Settings...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                else {
                    List(settings) { setting in
                        VStack(alignment: .leading) {
                            Text("\(setting.machine_id)")
                        }
                    }
                    
                }
            }
            .navigationTitle("Machines")
            .task {
                await loadSettings()
            }
            }
        }
    private func loadSettings() async {
        isLoading = true
        do {
            // Fetch settings from your API
            settings = try await MachineAPI.shared.getSettings() // Assume this returns `SettingResponse`
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    }



