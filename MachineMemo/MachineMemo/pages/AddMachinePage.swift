//
//  AddMachinePage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 1/5/25.
//  Modified by Eric Hurtado.
//

import SwiftUI
import PhotosUI

struct AddMachinePage: View {
    // State variables for the form
    @State private var machineName: String = ""
    @State private var machineBrand: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State var isLoading: Bool = false
    @State var navigateScreen: Bool = false
    @State var errorMessage: String = ""
    @State var machineID: Int = 0
    @State var addMachineResponse: AddMachine = AddMachine(status: "", message: "", id: 0)

    var body: some View {
        NavigationStack {
            Form {
                Section("Create Machine") {
                    TextField("Machine Name", text: $machineName)
                    TextField("Brand", text: $machineBrand)

                    // Image Picker
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack {
                            Text("Select Machine Image")
                            Spacer()
                            if selectedImage != nil {
                                Image(uiImage: selectedImage!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onChange(of: selectedPhotoItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImage = image
                            }
                        }
                    }

                    Button(action: {
                        Task {
                            await addMachine(name: machineName, brand: machineBrand, image: selectedImage)
                            if errorMessage.isEmpty {
                                navigateScreen = true
                            }
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Save Machine")
                        }
                    }
                    .disabled(isLoading || machineName.isEmpty || machineBrand.isEmpty)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateScreen) {
                MachineDetailsView(machine: Machine(id: machineID, name: machineName, type: "User", brand: machineBrand))
            }
            .navigationTitle("Add Machine")
        }
    }

    private func addMachine(name: String, brand: String, image: UIImage?) async {
        do {
            isLoading = true
            errorMessage = ""

            let newMachine = Machine(id: nil, name: name, type: "User", brand: brand)
            addMachineResponse = try await MachineAPI.shared.addMachine(machine: newMachine, image: image)
            machineID = addMachineResponse.id

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to add machine: \(error.localizedDescription)"
        }
    }
}
