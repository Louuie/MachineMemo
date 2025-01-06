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
    @State var extraMachineSettings = [""] /// array of ingredients
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Create Machine") {
                    TextField("Machine Name", text: $machineName)
                    TextField("Brand", text: $machineBrand)
                }
                ForEach(extraMachineSettings.indices, id: \.self) { index in
                    TextField("Example Field", text: $extraMachineSettings[index]) /// use each element in the array
                }
                Button(action: {
                    /// Add another empty text field to the view
                    extraMachineSettings.append("")
                }) {
                    Text("Add Setting")
                }
                Button(action: {
                    print("Add Machine tapped!")
                }) {
                    Text("Add Machine")
                }
                .tint(.green) // Correct placement of .tint()

            }
        }
    }
}

#Preview {
    AddMachinePage()
}
