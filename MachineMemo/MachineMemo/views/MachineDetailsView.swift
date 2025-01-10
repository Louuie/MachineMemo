//
//  MachineDetailsView.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//

import SwiftUI

struct MachineDetailsView: View {
    let machine: Machine
    var body: some View {
        NavigationStack {
            VStack {
                Text("\(machine.name)").font(.title)
                Text("\(machine.brand)").font(.subheadline)
                SettingsListView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: AddMachineSettingPage(machineID: machine.id != nil ? String(machine.id!) : "")) {
                                Image(systemName: "plus")
                                Text("\(machine.id != nil ? String(machine.id!) : "")")
                            }

                        }
                    }
            }.padding(.leading)

        }
    }
}
