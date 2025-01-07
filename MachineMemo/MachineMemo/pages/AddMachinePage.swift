//
//  AddMachinePage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//

import SwiftUI

struct AddMachinePage: View {
    // State variables for the form
    @State private var machineName: String = ""
    @State private var machineBrand: String = ""
    @State var isLoading: Bool = false
    @State var navigateScreen: Bool = false
    @State var errorMessage: String = ""
    @State var addMachineResponse: AddMachine = AddMachine(status: "", message: "")
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Create Machine") {
                    TextField("Machine Name", text: $machineName)
                    TextField("Brand", text: $machineBrand)
                    
                    Button(action: {
                        Task {
                            await addMachine(name: machineName, brand: machineBrand)
                            if errorMessage.isEmpty {
                                navigateScreen = true
                            }
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Save Machine")
                        }
                    }
                    .disabled(isLoading || machineName.isEmpty || machineBrand.isEmpty)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateScreen) {
                MachineDetailsView(machine: Machine(id: nil, name: machineName, type: "User", brand: machineBrand))
            }
            .navigationTitle("Add Machine")
        }
    }
    
    private func addMachine(name: String, brand: String) async {
        do {
            isLoading = true
            errorMessage = ""
            
            let newMachine = Machine(id: nil, name: name, type: "User", brand: brand)
            addMachineResponse = try await MachineAPI.shared.addMachine(machine: newMachine)
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to add machine: \(error.localizedDescription)"
        }
    }
}

#Preview {
    AddMachinePage()
}

