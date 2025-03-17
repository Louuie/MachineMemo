//
//  CreateWorkoutSheet.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 3/15/25.
//

import SwiftUI

struct CreateWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workoutName: String = ""
    @State private var exercises: [String: [String: [String: String]]] = [:]
    
    var onSave: ((Workout) -> Void)?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Workout Info")) {
                    TextField("Workout Name", text: $workoutName)
                        .autocapitalization(.words)
                }
                
                Section(header: Text("Exercises")) {
                    ForEach(exercises.keys.sorted(by: extractExerciseNumber), id: \.self) { exerciseName in
                        VStack(alignment: .leading) {
                            Text(exerciseName)
                                .font(.headline)
                            
                            ForEach(exercises[exerciseName]!.keys.sorted(by: extractSetNumber), id: \.self) { setNumber in
                                let setData = exercises[exerciseName]![setNumber]!
                                HStack {
                                    Text("Set \(setNumber)")
                                    
                                    TextField("Weight", text: Binding(
                                        get: { setData["weight"] ?? "0" },
                                        set: { newValue in
                                            updateSet(exerciseName: exerciseName, setNumber: setNumber, key: "weight", value: newValue)
                                        }
                                    ))
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 60)

                                    TextField("Reps", text: Binding(
                                        get: { setData["reps"] ?? "0" },
                                        set: { newValue in
                                            updateSet(exerciseName: exerciseName, setNumber: setNumber, key: "reps", value: newValue)
                                        }
                                    ))
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 50)
                                    
                                    // Delete Set Button (only if more than 1 set exists)
                                    if exercises[exerciseName]!.count > 1 {
                                        Button(action: {
                                            deleteSet(from: exerciseName, setNumber: setNumber)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            
                            Button("Add Set") {
                                addSet(to: exerciseName)
                            }
                        }
                    }
                    
                    Button("Add Exercise") {
                        addExercise()
                    }
                }
            }
            .navigationTitle("Create Workout")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(workoutName.isEmpty || exercises.isEmpty)
                }
            }
        }
    }
    
    private func addExercise() {
        let exerciseNumber = exercises.count + 1
        let exerciseName = "Exercise \(exerciseNumber)"
        exercises[exerciseName] = ["1": ["weight": "0", "reps": "0"]]
    }
    
    private func addSet(to exerciseName: String) {
        guard var exercise = exercises[exerciseName] else { return }
        let newSetNumber = "\(exercise.count + 1)"
        exercise[newSetNumber] = ["weight": "0", "reps": "0"]
        exercises[exerciseName] = exercise
    }
    
    private func deleteSet(from exerciseName: String, setNumber: String) {
        guard var exercise = exercises[exerciseName] else { return }

        // Remove the selected set
        exercise.removeValue(forKey: setNumber)

        // Renumber the remaining sets in order
        let reorderedSets = exercise.keys.sorted(by: extractSetNumber).enumerated().reduce(into: [String: [String: String]]()) { (newDict, indexPair) in
            let (index, oldKey) = indexPair
            newDict["\(index + 1)"] = exercise[oldKey]!
        }
        
        // Assign updated sets back to the main state
        exercises[exerciseName] = reorderedSets
    }
    
    private func updateSet(exerciseName: String, setNumber: String, key: String, value: String) {
        if var exercise = exercises[exerciseName] {
            if var set = exercise[setNumber] {
                set[key] = value
                exercise[setNumber] = set
                exercises[exerciseName] = exercise
            }
        }
    }
    
    private func saveWorkout() {
        let workout = Workout(
            id: 0,
            name: workoutName,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            exercises: exercises
        )
        
        onSave?(workout)
        dismiss()
    }
    
    /// Sort exercises numerically (e.g., "Exercise 1", "Exercise 2")
    private func extractExerciseNumber(_ exercise1: String, _ exercise2: String) -> Bool {
        let num1 = Int(exercise1.replacingOccurrences(of: "Exercise ", with: "")) ?? 0
        let num2 = Int(exercise2.replacingOccurrences(of: "Exercise ", with: "")) ?? 0
        return num1 < num2
    }

    /// Sort sets numerically (e.g., "1", "2", "3")
    private func extractSetNumber(_ set1: String, _ set2: String) -> Bool {
        let num1 = Int(set1) ?? 0
        let num2 = Int(set2) ?? 0
        return num1 < num2
    }
}
