//
//  Earth3DView.swift
//  justtry
//
//  Created by Valery Mokrytska on 30.09.25.
//

import SwiftUI
import SceneKit

struct Earth3DView: UIViewRepresentable {
    let textureName: String

    func makeUIView(context: Context) -> SCNView {
        let v = SCNView()
        v.scene = SCNScene()
        v.backgroundColor = .clear
        v.allowsCameraControl = true
        v.antialiasingMode = .multisampling4X
        v.defaultCameraController.interactionMode = .orbitTurntable
        v.defaultCameraController.inertiaEnabled = true
        v.preferredFramesPerSecond = 60

        // camera
        let cam = SCNNode()
        cam.camera = SCNCamera()
        cam.camera?.zFar = 1000
        cam.position = SCNVector3(0, 0, 3)
        v.scene?.rootNode.addChildNode(cam)

        // texture
        let sphere = SCNSphere(radius: 1.0)
        sphere.segmentCount = 128

        let mat = SCNMaterial()
        if let img = UIImage(named: textureName) {
            mat.diffuse.contents = img
        } else {
            print("⚠️ Image Set '\(textureName)' not found")
            mat.diffuse.contents = UIColor.darkGray
        }
        mat.lightingModel = .constant
       

        sphere.firstMaterial = mat

        let planet = SCNNode(geometry: sphere)
        v.scene?.rootNode.addChildNode(planet)

        let look = SCNLookAtConstraint(target: planet)
        look.isGimbalLockEnabled = true
        cam.constraints = [look]
        
        return v;

    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}
