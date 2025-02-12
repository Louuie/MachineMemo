//
// YourMachinesPage.swift
// MachineMemo
//
// This page displays a list of machines that the current user has settings for.
// It queries the settings table to get all machine_ids associated with the user,
// then fetches the corresponding machine details from the machines table.
// Unlike the MachineListView, this shows only machines the user has interacted with
// and does not group them by brand.

import SwiftUI

struct YourMachinesPage: View {
    @State private var machines: [Machine] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var search: String = ""
    
    var filteredMachines: [Machine] {
        if search.isEmpty {
            return machines
        } else {
            return machines.filter { machine in
                machine.name.localizedCaseInsensitiveContains(search) || 
                machine.brand.localizedCaseInsensitiveContains(search)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading Your Machines...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if machines.isEmpty {
                    Text("You haven't used any machines yet")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(filteredMachines) { machine in
                            NavigationLink(destination: MachineDetailsView(machine: machine)) {
                                VStack(alignment: .leading) {
                                    Text(machine.name)
                                        .font(.headline)
                                    Text(machine.brand)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Your Machines")
            .task {
                await loadMachines()
            }
            .searchable(text: $search)
        }
    }

    private func loadMachines() async {
        do {
            machines = try await MachineAPI.shared.getUserMachines()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}