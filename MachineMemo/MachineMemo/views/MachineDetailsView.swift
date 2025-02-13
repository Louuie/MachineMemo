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
        SettingsListView(machine_id: String(machine.id ?? 0), machine: machine)
    }
}

#Preview {
    MachineDetailsView(machine: Machine(id: 0, name: "Test", type: "User", brand: "Test"))
}
