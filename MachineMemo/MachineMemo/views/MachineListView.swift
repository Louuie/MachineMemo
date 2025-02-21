//
//  MachineListView.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//  Modified by Eric Hurtado.

import SwiftUI

struct MachineListView: View {
    private var groupedMachines: [String: [Machine]] {
        Dictionary(grouping: filteredMachines, by: { $0.brand })
    }

    @State private var machines: [Machine] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var search: String = ""
    
    var filteredMachines: [Machine] {
        if search.isEmpty {
            return machines.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } else {
            return machines.filter { machine in
                machine.name.localizedCaseInsensitiveContains(search) || machine.brand.localizedCaseInsensitiveContains(search)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    SpinnerView()
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List {
                        let sortedBrands = groupedMachines.keys.sorted()
                        
                        ForEach(sortedBrands, id: \.self) { brand in
                            if let machines = groupedMachines[brand] {
                                Section(header: Text(brand).font(.headline)) {
                                    ForEach(machines) { machine in
                                        NavigationLink(destination: MachineDetailsView(machine: machine)) {
                                            Text(machine.name)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Machines")
            .onAppear {
                if machines.isEmpty {
                    Task {
                        await loadMachines()
                    }
                }
            }
            .searchable(text: $search)
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
