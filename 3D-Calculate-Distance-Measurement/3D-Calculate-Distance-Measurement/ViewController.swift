//
//  ViewController.swift
//  3D-Calculate-Distance-Measurement
//
//  Created by Mesut Gedik on 7.05.2023.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResult.first {
                addDot(at: hitResult)
            }
        }
    }
    
    func addDot (at hitResult: ARHitTestResult){
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x,
                                      y: hitResult.worldTransform.columns.3.y,
                                      z: hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate ()
        }
        
        func calculate (){
            let startNode = dotNodes[0]
            let endNode = dotNodes[1]
            
            let a = endNode.position.x - startNode.position.x
            let b = endNode.position.y - startNode.position.y
            let c = endNode.position.z - startNode.position.z
            
            let distance = sqrt(powf(a, 2) + powf(b, 2) + powf(c, 2))
           
            updateText(text: "\(abs(distance))", atPosition: endNode.position)
            
        }
    }
    
    func updateText(text: String, atPosition: SCNVector3) {
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        let textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(x: atPosition.x , y: atPosition.y + 0.01, z: atPosition.z)
        
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
