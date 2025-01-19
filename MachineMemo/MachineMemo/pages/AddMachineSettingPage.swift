//
//  AddMachineSettingPage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/9/25.
//

import SwiftUI

struct AddMachineSettingPage: View {
    // State variables for the form
    @State var machineID: String
    @State var errorMessage: String = ""
    @State var extraMachineSettings = [""]
    @State var extraSettingVal = [""]
    @State private var showToast: Bool = false
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                ForEach(extraMachineSettings.indices, id: \.self) { index in
                    Section("Create Setting \(index + 1)") {
                        TextField("Setting Name", text: $extraMachineSettings[index])
                        TextField("Setting Value", text: $extraSettingVal[index])
                            .keyboardType(.numberPad)
                    }
                }

                // Add Setting Button
                Button(action: {
                    extraMachineSettings.append("") // Add a new setting name
                    extraSettingVal.append("") // Add a new setting value
                }) {
                    Text("Add Setting")
                }
                .tint(.blue)

                // Remove Setting Button
                Button(action: {
                    if !extraMachineSettings.isEmpty {
                        extraMachineSettings.removeLast()
                        extraSettingVal.removeLast()
                    }
                }) {
                    Text("Remove Setting")
                }
                .tint(.red)

                // Submit Button
                Button(action: {
                    Task {
                        await submitSettings()
                    }
                }) {
                    Text("Submit Settings")
                }
                .tint(.green)
                .disabled(!canSubmit())
            }
            .navigationTitle("Add Settings")
        }
    }
    
    private func submitSettings() async {
        do {
            guard validateFields() else {
                errorMessage = "All fields must be filled out and cannot be empty or whitespace."
                return
            }
            
            let machineSettings = Dictionary(uniqueKeysWithValues: zip(extraMachineSettings, extraSettingVal))
            
            guard let machineIdAsInt = Int(machineID) else {
                errorMessage = "Invalid machine_id: \(machineID)"
                return
            }
            let newSetting = Setting(id: nil, machine_id: machineIdAsInt, settings: machineSettings, user_id: nil)
            
            let addSettingResponse = try await MachineAPI.shared.addSetting(setting: newSetting)
            
            print(addSettingResponse)
            
            dismiss()
        } catch {
            errorMessage = "Failed to add the setting \(error.localizedDescription)"
        }
    }

    private func addSetting(machine_id: String, settings: [String: String]) async {
        do {
            // Convert machine_id from String to Int
            guard let machineIDAsInt = Int(machine_id) else {
                errorMessage = "Invalid machine_id: \(machine_id)"
                return
            }

            // Create the Setting object with the converted Int
            let newSetting = Setting(id: nil, machine_id: machineIDAsInt, settings: settings, user_id: nil)
            
            // Send the request using the API
            let addSettingResponse = try await MachineAPI.shared.addSetting(setting: newSetting)
            print(addSettingResponse)
            print(machine_id)
        } catch {
            errorMessage = "Failed to add the setting: \(error.localizedDescription)"
        }
    }
    
    private func validateFields() -> Bool {
        // Ensure no empty or whitespace-only fields and at least one setting exists
        guard !extraMachineSettings.isEmpty,
              !extraSettingVal.isEmpty,
              !extraMachineSettings.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }),
              !extraSettingVal.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            return false
        }
        return true
    }

    private func canSubmit() -> Bool {
        // Validate that at least one setting exists and all fields are valid
        return !extraMachineSettings.isEmpty &&
               !extraSettingVal.isEmpty &&
               validateFields()
    }

    private func showError(_ message: String) {
        errorMessage = message
        withAnimation {
            showToast = true
        }
    }
}

