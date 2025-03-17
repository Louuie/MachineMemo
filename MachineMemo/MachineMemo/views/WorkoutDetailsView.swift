//
//  WorkoutDetailsView.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 3/15/25.
//
//import SwiftUI
//
//struct WorkoutDetailsView: View {
//    var workout: Workout
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                ForEach(workout.exercises, id: \.id) { exercise in
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text(exercise.name)
//                            .font(.headline)
//                            .foregroundColor(.blue)
//
//                        VStack(spacing: 8) {
//                            ForEach(exercise.sets.indices, id: \.self) { index in
//                                let set = exercise.sets[index]
//                                HStack {
//                                    Text("Set \(index + 1):")
//                                        .font(.subheadline)
//                                        .foregroundColor(.gray)
//
//                                    Spacer()
//
//                                    Text("\(set.reps) reps @ \(set.weight, specifier: "%.0f") lbs")
//                                        .font(.subheadline)
//                                        .fontWeight(.medium)
//                                }
//                                .padding()
//                                .background(Color(.secondarySystemBackground))
//                                .cornerRadius(8)
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(Color(.systemBackground))
//                    .cornerRadius(12)
//                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
//                }
//            }
//            .padding()
//        }
//        .navigationTitle(workout.name)
//    }
//}
import SwiftUI
struct WorkoutDetailsView: View {
    var body: some View {
        Text("WorkoutDetailsView")
    }
}

