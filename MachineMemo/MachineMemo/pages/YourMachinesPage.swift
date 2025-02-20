//
//  YourMachinesPage.swift
//  MachineMemo
//
//  Created by Eric Hurtado on 2/11/25.
//
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
            ZStack {
                Color(.systemBackground).edgesIgnoringSafeArea(.all)

                VStack {
                    if isLoading {
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                            Text("Loading your machines...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }
                    } else if let errorMessage = errorMessage {
                        ErrorView(message: errorMessage) {
                            Task { await loadMachines() }
                        }
                    } else if machines.isEmpty {
                        EmptyStateView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredMachines) { machine in
                                    MachineCard(machine: machine, machine_icon: machine.brand)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .navigationTitle("Your Machines")
                .searchable(text: $search)
                .onAppear {
                    if machines.isEmpty {
                        Task {
                            await loadMachines()
                        }
                    }
                }
            }
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

// MARK: - Machine Card (Modern UI)
struct MachineCard: View {
    var machine: Machine
    var machine_icon: String

    var body: some View {
        NavigationLink(destination: MachineDetailsView(machine: machine)) {
            HStack(spacing: 15) {
                Image(machine_icon) // Placeholder for machine icon
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(machine.name)
                        .font(.headline)
                    Text(machine.brand)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
            Text("No machines found")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Start using machines and track them here.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Error State View
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "xmark.octagon.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.red)
            Text("Oops!")
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: retryAction) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}
