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
            Text("\(machine.name)")
            Text("\(machine.brand)")
            Text("\(machine.type)")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddMachineSettingPage()) {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
    }
}
