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
                Text("\(machine.brand)").font(.title)
                Text("\(machine.name)").font(.subheadline)
                SettingsListView(machine_id: String(machine.id ?? 0))
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
//                            NavigationLink(destination: AddMachineSettingPage(machineID: machine.id != nil ? String(machine.id!) : "")) {
//                                Image(systemName: "plus")
//                                Text("\(machine.id != nil ? String(machine.id!) : "")")
//                            }

                        }
                    }
            }.padding(.leading)

        }
    }
}
