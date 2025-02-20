//
//  SettingsListView.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/9/25.
//  Modified by Eric Hurtado.

import SwiftUI

struct SettingsListView: View {
    @State var machine_id: String
    let machine: Machine
    @State private var isLoading: Bool = true
    @State private var settings: [Setting] = [] // Array of `Setting` objects
    @State private var errorMessage: String? = ""
    @AppStorage("shouldRefreshSettings") var shouldRefreshSettings = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 8) { // Prev 16
                // Machine Info Section
                VStack(spacing: 12) {
                    Image(machine.brand)
                        .resizable()
                        .frame(width: 70, height: 70)
                    
                    VStack(spacing: 8) {
                        Text(machine.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(machine.brand)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12) // Prev 20
                .background(Color(.systemBackground))
                
                // Settings Section
                if isLoading {
                    ProgressView("Loading Settings...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                        }
                        .fixedSize()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(settings) { setting in
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(setting.settings.keys.sorted(), id: \.self) { key in
                                    HStack(alignment: .center) {
                                        Text(key.uppercased())
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                        Spacer()
                                        Text(setting.settings[key] ?? "")
                                            .font(.body)
                                            .multilineTextAlignment(.trailing)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                            )
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .leading) {
                                Button {
                                    let editView = EditMachineSettingPage(machineID: machine_id, setting: setting)
                                    let hostingController = UIHostingController(rootView: editView)
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let rootViewController = windowScene.windows.first?.rootViewController {
                                        rootViewController.present(hostingController, animated: true, completion: nil)
                                    }
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .padding(.horizontal, 8)
                    .onChange(of: shouldRefreshSettings) { _ in
                        Task {
                            await refreshList()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                if settings.isEmpty {
                    Task {
                        await loadSettings()
                    }
                }
            }
        }
    }

    private func loadSettings() async {
        isLoading = true
        do {
            // Fetch settings from your API
            settings = try await MachineAPI.shared.getSettings(machineID: machine_id)
            
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func refreshList() async {
        do {
            settings = try await MachineAPI.shared.getSettings(machineID: machine_id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}



