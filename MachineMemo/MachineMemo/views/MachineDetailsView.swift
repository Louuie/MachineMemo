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
            VStack(spacing: 12) {
                Text(machine.brand).font(.title)
                Text(machine.name).font(.subheadline)
                SettingsListView(machine_id: String(machine.id ?? 0))
            }
            .padding(.leading)
        }
    }
}

#Preview {
    MachineDetailsView(machine: Machine(id: 0, name: "Test", type: "User", brand: "Test"))
}
