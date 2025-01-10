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
                        let machineSettings = Dictionary(uniqueKeysWithValues: zip(extraMachineSettings, extraSettingVal))
                        print("Machine Settings: \(machineSettings)")
                        print("\(machineID)")
                        await addSetting(machine_id: machineID, settings: machineSettings) // Fixed call
                    }
                }) {
                    Text("Submit Settings")
                }
                .tint(.green)
            }
            .navigationTitle("Add Settings")
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
            let newSetting = Setting(id: nil, machine_id: machineIDAsInt, settings: settings)
            
            // Send the request using the API
            let addSettingResponse = try await MachineAPI.shared.addSetting(setting: newSetting)
            print(addSettingResponse)
            print(machine_id)
        } catch {
            errorMessage = "Failed to add the setting: \(error.localizedDescription)"
        }
    }
}

