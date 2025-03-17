//
//  WorkoutsPage.swift
//  MachineMemo
//
//  Created by Elias Dandouch on 3/15/25.
//
import SwiftUI

struct WorkoutsPage: View {
    @State private var workouts: [Workout] = []
    @State private var showCreateWorkoutSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List(workouts) { workout in
                        //WorkoutCard(workout: workout)
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showCreateWorkoutSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title.weight(.semibold))
                                .padding()
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 4, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Workouts")
            .sheet(isPresented: $showCreateWorkoutSheet) {
                CreateWorkoutSheet()
            }
        }
    }
}



//    private func loadWorkouts() async {
//        do {
//            isLoading = true
//            workouts = try await WorkoutAPI.shared.getUserWorkouts()
//            isLoading = false
//        } catch {
//            errorMessage = error.localizedDescription
//            isLoading = false
//        }
//    }
//struct WorkoutCard: View {
//    var workout: Workout
//
//    var body: some View {
//        NavigationLink(destination: WorkoutDetailsView(workout: workout)) {
//            HStack(spacing: 15) {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text(workout.name)
//                        .font(.headline)
//                        .foregroundColor(.blue)
//
//                    ForEach(workout.exercises.prefix(2), id: \.id) { exercise in
//                        Text("\(exercise.name) - Total Sets: \(exercise.sets.count)")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                    }
//                }
//                Spacer()
//                Image(systemName: "chevron.right") // Chevron inside card
//                    .foregroundColor(.gray)
//            }
//            .padding()
//            .background(Color(.secondarySystemBackground))
//            .cornerRadius(12)
//            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
//        }
//    }
//}




