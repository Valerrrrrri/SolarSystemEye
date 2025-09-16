import SwiftUI
import SceneKit

struct MercuryOrbitView: UIViewRepresentable {
    let timeScale: Double
    var onSpeedUpdate: (Double) -> Void

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let v = SCNView()
        v.scene = SCNScene()
        v.backgroundColor = .clear
        v.allowsCameraControl = true
        v.antialiasingMode = .multisampling4X
        v.preferredFramesPerSecond = 60

        guard let scene = v.scene else { return v }

        // Константы орбиты
        let a_km: Double = 57_909_050
        let e: Double   = 0.205_630
        let b_km = a_km * sqrt(1 - e*e)
        let c_km = a_km * e
        let S: Double = 1_000_000.0

        let cam = SCNNode()
        cam.camera = SCNCamera()
        cam.camera?.zFar = 1e7
        cam.position = SCNVector3(0, 140, 420)
        cam.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cam)

        let sun = SCNSphere(radius: 14)
        let sunMat = SCNMaterial()
        sunMat.lightingModel = .constant
        sunMat.diffuse.contents  = UIImage(named: "sun_8k") ?? UIColor.systemYellow
        sunMat.emission.contents = UIImage(named: "sun_8k") ?? UIColor.systemYellow
        sun.firstMaterial = sunMat
        let sunNode = SCNNode(geometry: sun)
        scene.rootNode.addChildNode(sunNode)

        let sunLight = SCNLight()
        sunLight.type = .omni
        sunLight.intensity = 1800
        sunLight.color = UIColor.white
        let sunLightNode = SCNNode()
        sunLightNode.light = sunLight
        sunLightNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(sunLightNode)

        let haloPlane = SCNPlane(width: 120, height: 120)
        haloPlane.cornerRadius = 60
        let haloMat = SCNMaterial()
        haloMat.lightingModel = .constant
        haloMat.diffuse.contents = UIColor.clear
        haloMat.emission.contents = UIColor.yellow.withAlphaComponent(0.45)
        haloMat.blendMode = .add
        haloMat.isDoubleSided = true
        haloMat.writesToDepthBuffer = false
        haloPlane.firstMaterial = haloMat
        let halo = SCNNode(geometry: haloPlane)
        halo.constraints = [SCNBillboardConstraint()]
        sunNode.addChildNode(halo)

        let spin = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2.0, z: 0, duration: 40)
        sunNode.runAction(.repeatForever(spin))

        let A = CGFloat(a_km / S), B = CGFloat(b_km / S), C = CGFloat(c_km / S)
        let path = UIBezierPath()
        let samples = 360
        var pts: [CGPoint] = []
        for i in 0..<samples {
            let t = Double(i) / Double(samples) * 2.0 * Double.pi
            let x =  A * CGFloat(cos(t)) - C
            let z =  B * CGFloat(sin(t))
            pts.append(CGPoint(x: x, y: z))
        }
        path.move(to: pts.first ?? .zero)
        for p in pts.dropFirst() { path.addLine(to: p) }
        path.close()

        let orbitShape = SCNShape(path: path, extrusionDepth: 0.3)
        let orbitMat = SCNMaterial()
        orbitMat.lightingModel = .constant
        orbitMat.emission.contents = UIColor.white.withAlphaComponent(0.65)
        orbitMat.diffuse.contents  = UIColor.white.withAlphaComponent(0.2)
        orbitMat.writesToDepthBuffer = false
        orbitShape.firstMaterial = orbitMat
        let orbitNode = SCNNode(geometry: orbitShape)
        orbitNode.eulerAngles = SCNVector3(-CGFloat.pi/2, 0, 0)

        // 7
        let inclination: Float = 7.0 * Float.pi / 180.0
        orbitNode.eulerAngles.x -= inclination
        scene.rootNode.addChildNode(orbitNode)

        // 🪐
        let merc = SCNSphere(radius: 6)
        let mercMat = SCNMaterial()
        let mercTex = UIImage(named: "mercury_8k")

        mercMat.diffuse.contents  = mercTex
        mercMat.emission.contents = mercTex
        mercMat.lightingModel = .constant

        merc.firstMaterial = mercMat
        let mercuryNode = SCNNode(geometry: merc)
        scene.rootNode.addChildNode(mercuryNode)
        context.coordinator.sceneView     = v
        context.coordinator.mercuryNode   = mercuryNode
        context.coordinator.params        = .init(a_km: a_km, e: e, scale: S)
        context.coordinator.onSpeedUpdate = onSpeedUpdate
        context.coordinator.timeScale     = timeScale
        context.coordinator.inclinationX  = inclination
        context.coordinator.start()

        return v
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.timeScale = timeScale
    }


    struct OrbitParams {
        let a_km: Double
        let e: Double
        let scale: Double
        var T: Double { 87.969 * 24 * 3600 }
        var n: Double { 2.0 * Double.pi / T }
        let mu: Double = 1.327_124_400_18e20
    }

    final class Coordinator: NSObject {
        weak var sceneView: SCNView?
        weak var mercuryNode: SCNNode?
        var params: OrbitParams!
        var displayLink: CADisplayLink?
        var t0 = CACurrentMediaTime()
        var timeScale: Double = 2000
        var onSpeedUpdate: ((Double) -> Void)?
        var inclinationX: Float = 0

        func start() {
            stop()
            t0 = CACurrentMediaTime()
            let link = CADisplayLink(target: self, selector: #selector(step))
            link.add(to: .main, forMode: .common)
            displayLink = link
        }
        func stop() { displayLink?.invalidate(); displayLink = nil }

        @objc private func step() {
            guard let mercury = mercuryNode else { return }
            let t = CACurrentMediaTime() - t0

            let M = params.n * (t * timeScale)

            // Kepler: M = E − e sinE
            let e = params.e
            var E = M
            for _ in 0..<6 {
                let f  = E - e * sin(E) - M
                let fp = 1 - e * cos(E)
                E -= f / fp
            }

            // r  ν
            let a_km = params.a_km
            let r_km = a_km * (1 - e * cos(E))
            let nu = 2 * atan2( sqrt(1+e) * sin(E/2), sqrt(1-e) * cos(E/2) )

            let x_km = r_km * cos(nu)
            let z_km = r_km * sin(nu)
            let S = params.scale
            var pos = SCNVector3(x_km / S, 0, z_km / S)

            let c = cos(Double(inclinationX)), s = sin(Double(inclinationX))
            let yR = Double(pos.y) * c - Double(pos.z) * s
            let zR = Double(pos.y) * s + Double(pos.z) * c
            pos.y = Float(yR); pos.z = Float(zR)
            mercury.position = pos

            let a_m  = a_km * 1000.0
            let r_m  = r_km * 1000.0
            let mu   = params.mu
            let v_mps = sqrt( mu * (2.0/r_m - 1.0/a_m) )
            onSpeedUpdate?(v_mps / 1000.0)
        }

        deinit { stop() }
    }
}
