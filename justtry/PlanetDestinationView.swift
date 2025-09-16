import SwiftUI

struct PlanetDestinationView: View {
    let planet: Planet

    var body: some View {
        switch planet {
        case .mercury:
            // Меню с двумя режимами, оба имеют общий фон
            ScrollView {
                VStack(spacing: 24) {
                    NavigationLink {
                        PlanetScreen(title: "Mercury") {
                            MercuryDetailScreen()     // внутри — 3D Меркурия + пин
                        }
                    } label: { mercurySurfaceCard }

                    NavigationLink {
                        PlanetScreen(title: "Mercury Orbit") {
                            MercuryOrbitScreen()      // внутри — орбитальный режим
                        }
                    } label: { mercuryOrbitCard }
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())

        case .earth:
            PlanetScreen(title: "Earth") {
                Earth3DView(textureName: "earth_8k")
            }

        case .venus:
            PlanetScreen(title: "Venus") {
                Venus3DView(textureName: "venus_8k")
            }

        case .mars:
            PlanetScreen(title: "Mars") {
                Mars3DView(textureName: "mars_8k")
            }

        case .jupiter:
            PlanetScreen(title: "Jupiter") {
                Jupiter3DView(textureName: "jupiter_8k")
            }

        case .saturn:
            PlanetScreen(title: "Saturn") {
                Saturn3DView(textureName: "saturn_8k")
            }

        case .uranus:
            PlanetScreen(title: "Uranus") {
                Uranus3DView(textureName: "uranus_8k")
            }

        case .neptune:
            PlanetScreen(title: "Neptune") {
                Neptune3DView(textureName: "neptune_8k")
            }
        }
    }

    // MARK: – красивые карточки
    private var mercurySurfaceCard: some View {
        HStack {
            Image(systemName: "globe.europe.africa.fill")
                .font(.system(size: 28))
                .foregroundColor(.yellow)
                .frame(width: 44, height: 44)
                .background(.black.opacity(0.6))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 6) {
                Text("Mercury Surface").font(.headline).foregroundColor(.white)
                Text("Explore craters & features").font(.subheadline).foregroundColor(.white.opacity(0.7))
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var mercuryOrbitCard: some View {
        HStack {
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(.teal)
                .frame(width: 44, height: 44)
                .background(.black.opacity(0.6))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 6) {
                Text("Mercury Orbit (Kepler)").font(.headline).foregroundColor(.white)
                Text("Elliptical path & velocity").font(.subheadline).foregroundColor(.white.opacity(0.7))
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
