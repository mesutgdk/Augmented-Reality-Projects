//
//  ViewController.swift
//  3D-Dice-Rolling-On
//
//  Created by Mesut Gedik on 6.05.2023.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode] ()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            
            // sistem görüntüyü(plane'nin) dik olarak algılıyor, onu doksan derece yere yatırıyoruz
            
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            // result.isEmpty Boşsa !results.isEmpty boş değilse
            if let hitResult = results.first {
//                print(hitResult)
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                     
                     if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
             
                         diceNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                                        hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                                                        hitResult.worldTransform.columns.3.z)
                         diceArray.append(diceNode)
             
                         sceneView.scene.rootNode.addChildNode(diceNode)
                         
                         roll(dice: diceNode)
                         
                }
            }
        }
    }
    
    func rollAll (){
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice:dice)
            }
        }
        
    }
    
    func roll (dice:SCNNode) {
        
        let randomX = (Float(arc4random_uniform(4)) + 1) * (Float.pi/2)
        let randomZ = (Float(arc4random_uniform(4)+1) * (Float.pi/2))
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX),
                                              y: 0,
                                              z: CGFloat(randomZ),
                                              duration: 0.7))
    }
    
    @IBAction func rollAgain (){
        rollAll()
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
