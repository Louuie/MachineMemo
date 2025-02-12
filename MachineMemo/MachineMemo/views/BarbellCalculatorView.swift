import SwiftUI

enum PlateColor {
    static let plate55: Color = Color(.sRGB, red: 0.8, green: 0.2, blue: 0.2, opacity: 1)     // Bright red
    static let plate45: Color = Color(.sRGB, red: 0.2, green: 0.4, blue: 0.8, opacity: 1)     // Bright blue
    static let plate35: Color = Color(.sRGB, red: 0.9, green: 0.9, blue: 0.2, opacity: 1)     // Bright yellow
    static let plate25: Color = Color(.sRGB, red: 0.2, green: 0.8, blue: 0.2, opacity: 1)     // Bright green
    static let plate10: Color = Color(.sRGB, red: 1.0, green: 1.0, blue: 1.0, opacity: 1)     // Pure white
    static let plate5: Color = Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 1)      // Almost black
    static let plate2_5: Color = Color(.sRGB, red: 0.7, green: 0.7, blue: 0.7, opacity: 1)    // Light gray

    static func forWeight(_ weight: Double) -> Color {
        switch weight {
        case 45...55: return plate55
        case 35...44: return plate45
        case 25...34: return plate35
        case 15...24: return plate25
        case 10...14: return plate10
        case 5...9: return plate5
        default: return plate2_5
        }
    }
}

struct Plate: Identifiable {
    let id: String
    let weightKg: Double
    let weightLbs: Double
    let color: Color
    let position: Int
    
    var weight: Double
    var displayWeight: Double
    
    init(weightKg: Double, weightLbs: Double, color: Color, weight: Double, displayWeight: Double, position: Int = 0) {
        self.weightKg = weightKg
        self.weightLbs = weightLbs
        self.color = color
        self.weight = weight
        self.displayWeight = displayWeight
        self.position = position
        self.id = "\(weight)-\(position)"
    }
}

struct BarbellCalculatorView: View {
    @State private var targetWeight: Double = 20.0
    @State private var calculatedPlates: [Plate] = []
    @State private var isKg: Bool = true
    private let barWeightKg: Double = 20
    private let barWeightLbs: Double = 45
    private let weightIncrementKg: Double = 2.5
    private let weightIncrementLbs: Double = 5
    
    private var barWeight: Double { isKg ? barWeightKg : barWeightLbs }
    private var weightIncrement: Double { isKg ? weightIncrementKg : weightIncrementLbs }
    
    private var availablePlates: [Plate] {
        [
            Plate(weightKg: 25, weightLbs: 55, color: PlateColor.plate55, weight: isKg ? 25 : 55, displayWeight: isKg ? 25 : 55),
            Plate(weightKg: 20, weightLbs: 45, color: PlateColor.plate45, weight: isKg ? 20 : 45, displayWeight: isKg ? 20 : 45),
            Plate(weightKg: 15, weightLbs: 35, color: PlateColor.plate35, weight: isKg ? 15 : 35, displayWeight: isKg ? 15 : 35),
            Plate(weightKg: 10, weightLbs: 25, color: PlateColor.plate25, weight: isKg ? 10 : 25, displayWeight: isKg ? 10 : 25),
            Plate(weightKg: 5, weightLbs: 10, color: PlateColor.plate10, weight: isKg ? 5 : 10, displayWeight: isKg ? 5 : 10),
            Plate(weightKg: 2.5, weightLbs: 5, color: PlateColor.plate5, weight: isKg ? 2.5 : 5, displayWeight: isKg ? 2.5 : 5),
            Plate(weightKg: 1.25, weightLbs: 2.5, color: PlateColor.plate2_5, weight: isKg ? 1.25 : 2.5, displayWeight: isKg ? 1.25 : 2.5)
        ]
    }
    
    private func lbsToKg(_ lbs: Double) -> Double {
        return lbs / 2.20462
    }
    
    private func kgToLbs(_ kg: Double) -> Double {
        return kg * 2.20462
    }
    
    init() {
        _targetWeight = State(initialValue: barWeightKg)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Unit Toggle
                Picker("Weight Unit", selection: $isKg) {
                    Text("KG").tag(true)
                    Text("LBS").tag(false)
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: isKg) { _ in
                    calculatePlates()
                }
                
                // Weight Input Section with Conversion
                VStack(spacing: 10) {
                    HStack {
                        Button(action: { decrementWeight() }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 4) {
                            TextField("Weight", value: $targetWeight, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 32, weight: .bold))
                                .frame(width: 100)
                                .onChange(of: targetWeight) { newValue in
                                    if newValue < barWeight {
                                        targetWeight = barWeight
                                    }
                                    calculatePlates()
                                }
                            
                            // Conversion display
                            Text(isKg ? "\(kgToLbs(targetWeight), specifier: "%.1f") lbs" : "\(lbsToKg(targetWeight), specifier: "%.1f") kg")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: { incrementWeight() }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    
                    Text("Put these plates on each side")
                        .font(.headline)
                        .padding(.bottom, 30)
                }
                
                // Barbell Visualization
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.systemGray6))
                        .frame(height: 200)
                    
                    HStack(spacing: 0) {
                        // Bar shaft
                        Rectangle()
                            .frame(width: 30, height: 8)
                            .foregroundColor(.gray)
                        
                        ZStack(alignment: .leading) {
                            // Sleeve first (at the back)
                            Rectangle()
                                .frame(width: 120, height: 12)
                                .foregroundColor(Color(UIColor.systemGray4))
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.gray, lineWidth: 0.5)
                                )
                            
                            // Collar and Plates Group (in front)
                            ZStack(alignment: .leading) {
                                // Collar
                                Rectangle()
                                    .frame(width: 16, height: 20)
                                    .foregroundColor(Color(UIColor.systemGray3))
                                
                                // Plates stack - starts from collar
                                HStack(spacing: 0) {
                                    ForEach(calculatedPlates) { plate in
                                        PlateView(plate: plate)
                                    }
                                }
                                .offset(x: 16) // Offset by collar width
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.leading)
                }
                .padding(.horizontal)
                
                // Summary Section
                VStack(spacing: 20) {
                    Text("Plates per side:")
                        .font(.headline)
                        .padding(.top, 30)
                    
                    HStack(spacing: 30) {
                        // Plates breakdown
                        let plateCounts = calculatePlateCounts()
                        ForEach(plateCounts.sorted(by: { $0.key > $1.key }), id: \.key) { weight, count in
                            if count > 0 {
                                PlateCountView(weight: weight, count: count, isKg: isKg)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Plate calculator")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func decrementWeight() {
        let newWeight = targetWeight - weightIncrement
        if newWeight >= barWeight {
            targetWeight = newWeight
            calculatePlates()
        }
    }
    
    private func incrementWeight() {
        targetWeight += weightIncrement
        calculatePlates()
    }
    
    private func calculatePlateCounts() -> [Double: Int] {
        var counts: [Double: Int] = [:]
        for plate in calculatedPlates {
            counts[plate.weight, default: 0] += 1
        }
        return counts
    }
    
    private func calculateTotalWeight() -> Double {
        let platesWeight = calculatedPlates.map { $0.weight }.reduce(0, +) * 2
        return barWeight + platesWeight
    }
    
    private func calculatePlates() {
        calculatedPlates.removeAll()
        
        if targetWeight >= barWeight {
            var remainingWeight = (targetWeight - barWeight) / 2
            var bestPlates: [Plate] = []
            
            // Helper function to calculate total plates needed
            func calculateWithStartingPlate(startIndex: Int, remaining: Double) -> [Plate] {
                var result: [Plate] = []
                var remainingWeight = remaining
                var positionCounter = 0  // Add position counter
                
                // Try plates from the starting index
                for i in startIndex..<availablePlates.count {
                    let basePlate = availablePlates[i]
                    while remainingWeight >= basePlate.weight {
                        // Create new plate instance with unique position
                        let plate = Plate(
                            weightKg: basePlate.weightKg,
                            weightLbs: basePlate.weightLbs,
                            color: basePlate.color,
                            weight: basePlate.weight,
                            displayWeight: basePlate.displayWeight,
                            position: positionCounter
                        )
                        result.append(plate)
                        remainingWeight -= plate.weight
                        positionCounter += 1
                    }
                }
                
                return remainingWeight == 0 ? result : []
            }
            
            // Try starting with each plate size
            for i in 0..<availablePlates.count {
                let result = calculateWithStartingPlate(startIndex: i, remaining: remainingWeight)
                if !result.isEmpty && (bestPlates.isEmpty || result.count < bestPlates.count) {
                    bestPlates = result
                }
            }
            
            // If we found a solution, use it
            if !bestPlates.isEmpty {
                calculatedPlates = bestPlates
            } else {
                // Fallback to basic calculation if no exact match found
                var remaining = remainingWeight
                for plate in availablePlates {
                    while remaining >= plate.weight {
                        calculatedPlates.append(plate)
                        remaining -= plate.weight
                    }
                }
            }
        }
    }
}

struct PlateView: View {
    let plate: Plate
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(plate.color)
            .frame(width: 15, height: plateHeight(weight: plate.weight))
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.black, lineWidth: 1)
            )
    }
    
    private func plateHeight(weight: Double) -> Double {
        switch weight {
        case 45...55: return 130
        case 35...44: return 120
        case 25...34: return 110
        case 15...24: return 100
        case 10...14: return 90
        case 5...9: return 80
        default: return 70
        }
    }
}

struct PlateCountView: View {
    let weight: Double
    let count: Int
    let isKg: Bool
    
    private var plateColor: Color {
        // Use exact same logic as availablePlates
        if isKg {
            if weight == 25 { return PlateColor.plate55 }
            if weight == 20 { return PlateColor.plate45 }
            if weight == 15 { return PlateColor.plate35 }
            if weight == 10 { return PlateColor.plate25 }
            if weight == 5 { return PlateColor.plate10 }
            if weight == 2.5 { return PlateColor.plate5 }
            return PlateColor.plate2_5
        } else {
            if weight == 55 { return PlateColor.plate55 }
            if weight == 45 { return PlateColor.plate45 }
            if weight == 35 { return PlateColor.plate35 }
            if weight == 25 { return PlateColor.plate25 }
            if weight == 10 { return PlateColor.plate10 }
            if weight == 5 { return PlateColor.plate5 }
            return PlateColor.plate2_5
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(weight))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(plateColor == .white || plateColor == .yellow ? .black : .white)
            Text("×\(count)")
                .font(.system(size: 14))
                .foregroundColor(plateColor == .white || plateColor == .yellow ? .black : .white)
        }
        .frame(width: 45, height: 45)
        .background(plateColor)
        .overlay(
            Circle()
                .stroke(Color.black, lineWidth: 1)
        )
        .cornerRadius(25)
    }
}

#Preview {
    BarbellCalculatorView()
} 