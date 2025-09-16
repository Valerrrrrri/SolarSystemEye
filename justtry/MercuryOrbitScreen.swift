import SwiftUI

struct MercuryOrbitScreen: View {
    @State private var timeScale: Double = 2000
    @State private var vKms: Double = 0

    var body: some View {
        ZStack {
            MercuryOrbitView(timeScale: timeScale) { v in
                vKms = v
            }
            .ignoresSafeArea()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                Text("Time scale").font(.caption).foregroundStyle(.secondary)
                Slider(value: $timeScale, in: 200...8000, step: 50) {
                    Text("Speed")
                } minimumValueLabel: {
                    Text("×200").font(.caption2)
                } maximumValueLabel: {
                    Text("×8000").font(.caption2)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text(String(format: "v = %.2f km/s", vKms))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
        }
        .navigationTitle("Mercury Orbit")
        .navigationBarTitleDisplayMode(.inline)
    }
}


