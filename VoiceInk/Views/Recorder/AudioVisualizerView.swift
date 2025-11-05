import SwiftUI

struct AudioVisualizer: View {
    let audioMeter: AudioMeter
    let color: Color
    let isActive: Bool
    
    private let barCount = 12
    private let minHeight: CGFloat = 5
    private let maxHeight: CGFloat = 32
    private let barWidth: CGFloat = 3.5
    private let barSpacing: CGFloat = 2.3
    private var hardThreshold: Double {
        let sensitivity = UserDefaults.standard.double(forKey: "microphoneSensitivity")
        let defaultSensitivity = sensitivity == 0 ? 0.5 : sensitivity
        // Convert 0.1-1.0 range to 0.05-0.4 threshold range (inverted - higher sensitivity = lower threshold)
        return 0.45 - (defaultSensitivity * 0.4)
    }

    private let sensitivityMultipliers: [Double]

    @State private var barHeights: [CGFloat]
    @State private var targetHeights: [CGFloat]

    init(audioMeter: AudioMeter, color: Color, isActive: Bool) {
        self.audioMeter = audioMeter
        self.color = color
        self.isActive = isActive

        let sensitivity = UserDefaults.standard.double(forKey: "microphoneSensitivity")
        let baseSensitivity = sensitivity == 0 ? 0.5 : sensitivity
        let multiplierRange = 0.5 + (baseSensitivity * 1.5) // Range from 0.65-2.0 based on sensitivity
        
        self.sensitivityMultipliers = (0..<barCount).map { _ in
            Double.random(in: (multiplierRange * 0.7)...(multiplierRange * 1.3))
        }
        
        _barHeights = State(initialValue: Array(repeating: minHeight, count: barCount))
        _targetHeights = State(initialValue: Array(repeating: minHeight, count: barCount))
    }
    
    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.7)
                    .fill(color)
                    .frame(width: barWidth, height: barHeights[index])
            }
        }
        .onChange(of: audioMeter) { _, newValue in
            if isActive {
                updateBars(with: Float(newValue.averagePower))
            } else {
                resetBars()
            }
        }
        .onChange(of: isActive) { _, newValue in
            if !newValue {
                resetBars()
            }
        }
    }
    
    private func updateBars(with audioLevel: Float) {
        let rawLevel = max(0, min(1, Double(audioLevel)))
        let adjustedLevel = rawLevel < hardThreshold ? 0 : (rawLevel - hardThreshold) / (1.0 - hardThreshold)
        
        let range = maxHeight - minHeight
        let center = barCount / 2
        
        for i in 0..<barCount {
            let distanceFromCenter = abs(i - center)
            let positionMultiplier = 1.0 - (Double(distanceFromCenter) / Double(center)) * 0.4
            
            // Use randomized sensitivity
            let sensitivityAdjustedLevel = adjustedLevel * positionMultiplier * sensitivityMultipliers[i]
            
            let targetHeight = minHeight + CGFloat(sensitivityAdjustedLevel) * range
            
            let isDecaying = targetHeight < targetHeights[i]
            let smoothingFactor: CGFloat = isDecaying ? 0.6 : 0.3 // Adjusted smoothing
            
            targetHeights[i] = targetHeights[i] * (1 - smoothingFactor) + targetHeight * smoothingFactor
            
            // Only update if change is significant enough to matter visually
            if abs(barHeights[i] - targetHeights[i]) > 0.5 {
                withAnimation(
                    isDecaying
                    ? .spring(response: 0.4, dampingFraction: 0.8)
                    : .spring(response: 0.3, dampingFraction: 0.7)
                ) {
                    barHeights[i] = targetHeights[i]
                }
            }
        }
    }
    
    private func resetBars() {
        withAnimation(.easeOut(duration: 0.15)) {
            barHeights = Array(repeating: minHeight, count: barCount)
            targetHeights = Array(repeating: minHeight, count: barCount)
        }
    }
}

struct StaticVisualizer: View {
    private let barCount = 12
    private let barWidth: CGFloat = 3.5
    private let staticHeight: CGFloat = 5.0 
    private let barSpacing: CGFloat = 2.3
    let color: Color
    
    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.7)
                    .fill(color)
                    .frame(width: barWidth, height: staticHeight)
            }
        }
    }
}
