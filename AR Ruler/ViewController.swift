//
//  ViewController.swift
//  AR Ruler
//
//  Created by Isaac Urbina on 1/20/25.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
	
	
	// MARK: - IBOutlets
	
	@IBOutlet var sceneView: ARSCNView!
	
	
	// MARK: - variables
	private var dotNodes = [SCNNode]()
	private var textNode = SCNNode()
	
	
	// MARK: - UIViewController
	
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
	
	
	// MARK: - ARSCNViewDelegate
	
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
	
	
	// MARK: - private functions
	
	private func addDot(at hitResult: ARHitTestResult) {
		let dotGeometry = SCNSphere(radius: 0.005)
		let material = SCNMaterial()
		material.diffuse.contents = UIColor.red
		dotGeometry.materials = [material]
		
		let dotNode = SCNNode(geometry: dotGeometry)
		dotNode.position = SCNVector3(
			x: hitResult.worldTransform.columns.3.x,
			y: hitResult.worldTransform.columns.3.y,
			z: hitResult.worldTransform.columns.3.z
		)
		
		sceneView.scene.rootNode.addChildNode(dotNode)
		
		dotNodes.append(dotNode)
		
		if dotNodes.count >= 2 {
			calculate()
		}
	}
	
	private func calculate() {
		let start = dotNodes[0]
		let end = dotNodes[1]
		
		print(start.position)
		print(end.position)
		
		let a = end.position.x - start.position.x
		let b = end.position.y - start.position.y
		let c = end.position.z - start.position.z
		
		let distance = sqrt(pow(a,2) + pow(b,2) + pow(c,2))
		
		updateText(text: "\(distance)", at: end.position)
	}
	
	private func updateText(text: String, at position: SCNVector3) {
		textNode.removeFromParentNode()
		
		let textGeometry = SCNText(string: text, extrusionDepth: 1)
		let material = SCNMaterial()
		material.diffuse.contents = UIColor.red
		textGeometry.materials = [material]
		
		textNode = SCNNode(geometry: textGeometry)
		textNode.position = SCNVector3(
			x: 0,
			y: 0.01,
			z: -0.1
		)
		textNode.scale = SCNVector3(
			x: position.x,
			y: position.y + 0.01,
			z: position.z
		)
		
		sceneView.scene.rootNode.addChildNode(textNode)
	}
}
