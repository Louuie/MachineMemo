//
//  AddMachineSettingPage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/9/25.
//

import SwiftUI

struct AddMachineSettingPage: View {
    // State variables for the form
    @State private var machineName: String = ""
    @State private var machineBrand: String = ""
    @State var extraMachineSettings = [""] 
    @State var extraSettingVal = [""]
    
    var body: some View {
        NavigationStack {
            Form {
                ForEach(extraMachineSettings.indices, id: \.self) { index in
                    TextField("Setting Name", text: $extraMachineSettings[index]) /// use each element in the array
                    TextField("Setting Value", text: $extraSettingVal[index]).keyboardType(.numberPad)
                }
                Section("Create Setting") {
                    Button(action: {
                        /// Add another empty text field to the view
                        extraMachineSettings.append("")
                    }) {
                        Text("Add Setting")
                    }
                }
                Button(action: {
                    print("Add Machine tapped!")
                }) {
                    Text("Add Setting")
                }
                .tint(.green)

            }
        }
    }
}

#Preview {
    AddMachineSettingPage()
}
