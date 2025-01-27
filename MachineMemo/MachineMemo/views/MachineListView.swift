//
//  MachineListView.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//  Modified by Eric Hurtado.

import SwiftUI

struct MachineListView: View {
    @State private var machines: [Machine] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading Machines...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List(machines) { machine in
                        NavigationLink(destination: MachineDetailsView(machine: machine)) {
                            VStack(alignment: .leading) {
                                Text(machine.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(machine.brand)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Machines")
            .task {
                await loadMachines()
            }
        }
    }

    private func loadMachines() async {
        do {
            machines = try await MachineAPI.shared.fetchMachines()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

#Preview {
    MachineListView()
}
