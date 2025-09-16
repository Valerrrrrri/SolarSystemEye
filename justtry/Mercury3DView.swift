import SwiftUI
import SceneKit

struct MercuryDetailScreen: View {
    @State private var show = false

    var body: some View {
        ZStack {
            Mercury3DView(textureName: "mercury_8k") {
                show = true   // pin tapped
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $show) {
            VStack(spacing: 12) {
                Text("Beethoven crater").font(.title2).bold()
                Text("Lat −20.8°, Lon 123.6°W → 236.4°E")
                    .font(.subheadline).foregroundStyle(.secondary)

                Image("beethoven_crater")   // Image Set in Assets
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer(minLength: 12)
            }
            .padding()
            .presentationDetents([.medium, .large])
        }
    }
}

// MARK:lickable pin
struct Mercury3DView: UIViewRepresentable {
    let textureName: String
    var onPinTapped: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> SCNView {
        let v = SCNView()
        v.scene = SCNScene()
        v.backgroundColor = .clear
        v.allowsCameraControl = true
        v.antialiasingMode = .multisampling4X
        v.defaultCameraController.interactionMode = .orbitTurntable
        v.defaultCameraController.inertiaEnabled = true
        v.preferredFramesPerSecond = 60

        // Camera
        let cam = SCNNode()
        cam.camera = SCNCamera()
        cam.camera?.zFar = 1000
        cam.position = SCNVector3(0, 0, 3)
        v.scene?.rootNode.addChildNode(cam)
        v.pointOfView = cam

        let sphere = SCNSphere(radius: 1.0)
        sphere.segmentCount = 128

        let mat = SCNMaterial()
        mat.diffuse.contents = UIImage(named: textureName) ?? UIColor.darkGray
        mat.lightingModel = .constant
        mat.diffuse.mipFilter = .linear
        mat.diffuse.minificationFilter = .linear
        mat.diffuse.magnificationFilter = .linear
        sphere.firstMaterial = mat

        let planet = SCNNode(geometry: sphere)
        planet.name = "planet"
        v.scene?.rootNode.addChildNode(planet)

        let look = SCNLookAtConstraint(target: planet)
        look.isGimbalLockEnabled = true
        cam.constraints = [look]

        // Beethoven pin
        addBeethovenPin(on: planet)

        context.coordinator.attachTap(to: v)

        return v
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let parent: Mercury3DView
        weak var scnView: SCNView?

        init(_ parent: Mercury3DView) { self.parent = parent }

        func attachTap(to view: SCNView) {
            let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
            tap.numberOfTapsRequired = 1
            tap.cancelsTouchesInView = false
            tap.delegate = self
            view.addGestureRecognizer(tap)
            self.scnView = view
        }

        @objc func onTap(_ gr: UITapGestureRecognizer) {
            guard let v = scnView else { return }
            let p = gr.location(in: v)
            let hits = v.hitTest(p, options: [
                .categoryBitMask: 1 << 5,
                .firstFoundOnly: true,
                .boundingBoxOnly: false
            ])
            print("tap at \(p), hits.count = \(hits.count)")
            if let node = hits.first?.node {
                print("hit node:", node.name ?? "no name")
                if node.name == "beethovenPin" {
                    parent.onPinTapped?()
                }
            }
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
    }

    private func addBeethovenPin(on planet: SCNNode) {
        // USGS: lat = −20.8°, lonW = 123.6° → lonE = 236.4°
        let latDeg: CGFloat = -20.8
        let lonWestDeg: CGFloat = 123.6
        let lonEDeg: CGFloat = 360.0 - lonWestDeg // 236.4°E

        let φ = latDeg * .pi / 180.0
        let λ = lonEDeg * .pi / 180.0

        // Slightly above the surface so it doesn't z-fight
        let r: CGFloat = 1.02
        let pos = SCNVector3(
            x: Float(r * cos(φ) * cos(λ)),
            y: Float(r * sin(φ)),
            z: Float(-r * cos(φ) * sin(λ))
        )

        // Bigger, double-sided pin to ensure reliable hit
        let size: CGFloat = 0.12  // make large; shrink later to ~0.06–0.08
        let plane = SCNPlane(width: size, height: size)
        plane.cornerRadius = size / 2

        let m = SCNMaterial()
        m.diffuse.contents = UIColor.white
        m.emission.contents = UIColor.white
        m.isDoubleSided = true
        plane.firstMaterial = m

        let pin = SCNNode(geometry: plane)
        pin.name = "beethovenPin"
        pin.position = pos
        pin.categoryBitMask = 1 << 5        // unique mask for hitTest
        pin.constraints = [SCNBillboardConstraint()]

        planet.addChildNode(pin)
    }
}
