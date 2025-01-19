//
//  SettingsListView.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/9/25.
//

import SwiftUI

struct SettingsListView: View {
    @State var machine_id: String
    @State private var isLoading: Bool = true
    @State private var settings: [Setting] = [] // Array of `Setting` objects
    @State private var errorMessage: String? = ""

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading Settings...")
                } else if let errorMessage = errorMessage, !errorMessage.isEmpty {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if settings.isEmpty {
                    VStack {
                        Text("You have yet to add settings for this machine.")
                            .foregroundColor(.gray)
                        NavigationLink(destination: AddMachineSettingPage(machineID: machine_id)) {
                            Text("Add Settings")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        } .fixedSize()
                    }
                }
                else {
                    List(settings) { setting in
                        VStack(alignment: .leading) {
                            ForEach(setting.settings.keys.sorted(), id: \.self) { key in
                                Text("\(key): \(setting.settings[key] ?? "")")
                            }
                        }
                        .padding()
                        .swipeActions(edge: .trailing) {
                            Button {
                                // some new view in here to edit setting ex: EditSettingSheet(setting: setting)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                    }

                    
                }
            }
            .task {
                await loadSettings()
            }
            }
        }
    private func loadSettings() async {
        isLoading = true
        do {
            // Fetch settings from your API
            settings = try await MachineAPI.shared.getSettings(machineID: machine_id) // Assume this returns `SettingResponse`
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    }



