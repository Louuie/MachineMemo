//
//  EditMachineSettingPage.swift
//  MachineMemo
//
//  Created by Eric Hurtado on 1/22/25.
//


import SwiftUI

struct EditMachineSettingPage: View {
    @State var machineID: String
    @State var setting: Setting
    @State var errorMessage: String = ""
    @State var extraMachineSettings: [String]
    @State var extraSettingVal: [String]
    @State private var showToast: Bool = false
    @Environment(\.dismiss) var dismiss

    init(machineID: String, setting: Setting) {
        self._machineID = State(initialValue: machineID)
        self._setting = State(initialValue: setting)
        self._extraMachineSettings = State(initialValue: Array(setting.settings.keys))
        self._extraSettingVal = State(initialValue: Array(setting.settings.values))
    }

    var body: some View {
        NavigationStack {
            Form {
                ForEach(extraMachineSettings.indices, id: \.self) { index in
                    Section("Edit Setting \(index + 1)") {
                        TextField("Setting Name", text: $extraMachineSettings[index])
                        TextField("Setting Value", text: $extraSettingVal[index])
                            .keyboardType(.numberPad)
                    }
                }

                // Add Setting Button
                Button(action: {
                    extraMachineSettings.append("")
                    extraSettingVal.append("")
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
                        await updateSettings()
                    }
                }) {
                    Text("Update Settings")
                }
                .tint(.green)
                .disabled(!canSubmit())
            }
            .navigationTitle("Edit Settings")
        }
    }
    
    private func updateSettings() async {
        do {
            guard validateFields() else {
                errorMessage = "All fields must be filled out and cannot be empty or whitespace."
                return
            }
            
            guard let machineIdAsInt = Int(machineID) else {
                errorMessage = "Invalid machine_id: \(machineID)"
                return
            }
            
            let updatedSettings = Dictionary(uniqueKeysWithValues: zip(extraMachineSettings, extraSettingVal))
            
            let updatedSetting = try await MachineAPI.shared.updateSetting(settingId: setting.id!, updatedSettings: updatedSettings, machine_id: machineIdAsInt)
            
            print(updatedSetting)
            
            dismiss()
        } catch {
            errorMessage = "Failed to update the setting: \(error.localizedDescription)"
        }
    }

    private func validateFields() -> Bool {
        guard !extraMachineSettings.isEmpty,
              !extraSettingVal.isEmpty,
              !extraMachineSettings.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }),
              !extraSettingVal.contains(where: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            return false
        }
        return true
    }

    private func canSubmit() -> Bool {
        return !extraMachineSettings.isEmpty &&
               !extraSettingVal.isEmpty &&
               validateFields()
    }
}

