import SwiftUI

enum Planet: String, CaseIterable {
    case mercury, venus, earth, mars, jupiter, saturn, uranus, neptune
    var displayName: String { rawValue.capitalized }
    var imageName: String { rawValue }
    
}

struct HomeView: View {
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                StarBackground().ignoresSafeArea()
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 40) {
                        ForEach(Planet.allCases, id: \.self) { planet in
                            NavigationLink {
                                PlanetDestinationView(planet: planet)
                            } label: {
                                VStack(spacing: 12) {
                                    Image(planet.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 2))
                                    Text(planet.displayName)
                                        .foregroundStyle(.white)
                                        .font(.headline)
                                }
                            }
                        }
                    }
                    .padding(.top, 80)
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("Choose a planet")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StarBackground: View {
    let stars = (0..<120).map { _ in
        CGPoint(x: CGFloat.random(in: 0...1), y: CGFloat.random(in: 0...1))
    }
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black
                ForEach(0..<stars.count, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.4...1)))
                        .frame(width: CGFloat.random(in: 1...3),
                               height: CGFloat.random(in: 1...3))
                        .position(
                            x: stars[i].x * geo.size.width,
                            y: stars[i].y * geo.size.height
                        )
                }
            }
        }
    }
}




