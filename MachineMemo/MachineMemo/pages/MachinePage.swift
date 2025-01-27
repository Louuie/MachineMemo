//
//  MachinePage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//
import SwiftUI

struct MachinePage: View {
    var body: some View {
        NavigationStack {
            MachineListView()
                .navigationTitle("Machines")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddMachinePage()) {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
    }
}

#Preview {
    MachinePage()
}
