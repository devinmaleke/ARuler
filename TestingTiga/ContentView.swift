//
//  ContentView.swift
//  TestingTiga
//
//  Created by Devin Maleke on 19/05/23.
//

import SwiftUI
import UIKit
import SceneKit
import ARKit


struct ContentView: View {
// @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//    var backButton: some View {
//        Button(action: {
//            presentationMode.wrappedValue.dismiss()
//        }) {
//            HStack {
//                Image(systemName: "chevron.left")
//                Text("Kembali")
//            }
//        }
//    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                
                    VStack(alignment: .leading){
                        
                        ZStack{
                            HStack{
                                Spacer()
                                Image("background")
                                    .resizable()
                                    .frame(width: 290, height: 350)
                                Spacer()
                            }
                            .padding(.top,30)
                            HStack{
                                Spacer()
                                Text("ARuler")
                                    .font(.system(size: 40))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 71/255, green: 136/255, blue: 199/255))
                                Spacer()
                                    
                            }
                            .padding(.top,300)
                        }
                        
                        
                        HStack{
                            Spacer()
                            VStack {
                                Spacer()
                                HStack {
                                    NavigationLink(value: "Thisistest") {
                                        Text("START")
                                            .font(.system(size: 30))
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 0.2784313725490196, green: 0.5333333333333333, blue: 0.7803921568627451))
                                            .padding(.bottom,10)
                                            .padding(.top,10)
                                            .padding(.leading,40)
                                            .padding(.trailing,40)
                                            .overlay(
                                                Rectangle()
                                                    .stroke(Color(red: 0.2784313725490196, green: 0.5333333333333333, blue: 0.7803921568627451), lineWidth: 4)
                                            )
                                    }
                                }
                                
                                .padding(.bottom,150)
                                
                            }
                            Spacer()
                        }
                        
                        
                    }
                
            }
            .background(
                Color(red: 246/255, green: 241/255, blue: 241/255)
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

            )
            .navigationDestination(for: String.self) { _ in
                ContentViewController()
                    //.navigationBarBackButtonHidden(true)
                    //.navigationBarItems(leading: backButton)
                    .edgesIgnoringSafeArea(.all)
                
            }
            
            
        }
        
        
    }
}

struct ContentViewController: UIViewControllerRepresentable{
    
    func makeUIViewController(context: Context) -> some UIViewController {
        
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    
}


//extension SCNGeometry {
//    static func lineBetweenNodes(from nodeA: SCNNode, to nodeB: SCNNode) -> SCNGeometry {
//        let indices: [Int32] = [0, 1]
//        let source = SCNGeometrySource(vertices: [nodeA.position, nodeB.position])
//        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
//        return SCNGeometry(sources: [source], elements: [element])
//    }
//}

class LineNode: SCNNode {
    init(from vectorA: SCNVector3, to vectorB: SCNVector3, lineColor color: UIColor) {
        super.init()
        
        let height = self.distance(from: vectorA, to: vectorB)
        
        self.position = vectorA
        let nodeVector2 = SCNNode()
        nodeVector2.position = vectorB
        
        let nodeZAlign = SCNNode()
        nodeZAlign.eulerAngles.x = Float.pi/2
        
        let box = SCNBox(width: 0.003, height: height, length: 0.001, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = color
        box.materials = [material]
        
        let nodeLine = SCNNode(geometry: box)
        nodeLine.position.y = Float(-height/2) + 0.001
        nodeZAlign.addChildNode(nodeLine)
        
        self.addChildNode(nodeZAlign)
        self.constraints = [SCNLookAtConstraint(target: nodeVector2)]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func distance(from vectorA: SCNVector3, to vectorB: SCNVector3)-> CGFloat {
        return CGFloat (sqrt(
            (vectorA.x - vectorB.x) * (vectorA.x - vectorB.x)
                +   (vectorA.y - vectorB.y) * (vectorA.y - vectorB.y)
                +   (vectorA.z - vectorB.z) * (vectorA.z - vectorB.z)))
    }
}
class ViewController: UIViewController, ARSCNViewDelegate {
    var nodes = [SCNNode]()
    var textMeasure = SCNNode()
    var meter : Double?
    var lineNode = SCNNode()
    var outlineNode = SCNNode()
//    var drawingLine = false
    
    var sceneView: ARSCNView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView = ARSCNView(frame: view.frame)
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        view.addSubview(sceneView)
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
    
//    func doHitTestOnExistingPlanes() -> SCNVector3? {
//            let results = sceneView.hitTest(view.center, types: .featurePoint)
//            if let result = results.first {
//                let hitPos = SCNVector3()
//                return hitPos
//            }
//            return nil
//        }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if nodes.count >= 2 {
            for x in nodes{
                x.removeFromParentNode()
                textMeasure.removeFromParentNode()
                lineNode.removeFromParentNode()
                outlineNode.removeFromParentNode()
                nodes = [SCNNode]()
                
            }
        }
        
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResults.first{
                addNode(at: hitResult)
            }
        }
    }
    
    
    func addNode(at hitResult: ARHitTestResult){
        
        let nodeGeometry = SCNSphere(radius: 0.008)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.0784313725490196, green: 0.4235294117647059, blue: 0.5803921568627451, alpha: 1.0)
        nodeGeometry.materials = [material]
        
        let node = SCNNode(geometry: nodeGeometry)
        node.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(node)
        nodes.append(node)
        

        if nodes.count >= 2 {
            calculate()
            
        }
    }
    
    func calculate() {
        
        let start = nodes[0]
        let end = nodes[1]
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        
        meter = Double(abs(distance))
        
        let mark = Measurement(value: meter ?? 0 , unit: UnitLength.meters)
        let toCM = mark.converted(to: UnitLength.centimeters)
        
        let value = "\(toCM)"
        let finalValue = String(value.prefix(5)) + " CM"
        
        updateText(text: finalValue, atPosition: end.position)
        
        lineNode.removeFromParentNode()
        lineNode = LineNode(from: start.position, to: end.position, lineColor: UIColor(red: 0.0784313725490196, green: 0.4235294117647059, blue: 0.5803921568627451, alpha: 1.0)
        )
           sceneView.scene.rootNode.addChildNode(lineNode)
    }
    
    func updateText(text: String, atPosition position: SCNVector3) {
        textMeasure.removeFromParentNode()

        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.font = UIFont.systemFont(ofSize: 10)

        let textOutline = SCNText(string: text, extrusionDepth: 0.5)
        textOutline.font = UIFont.systemFont(ofSize: 10)

        let frontMaterial = SCNMaterial()
        frontMaterial.diffuse.contents = UIColor(red: 175/255, green: 211/255, blue: 226/255, alpha: 1)
        textGeometry.firstMaterial = frontMaterial

        let backMaterial = SCNMaterial()
        backMaterial.diffuse.contents = UIColor.black
        textGeometry.materials = [frontMaterial, backMaterial]

        textMeasure = SCNNode(geometry: textGeometry)
        textMeasure.position = SCNVector3(x: position.x, y: position.y + 0.01, z: position.z)
        textMeasure.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)

        let outlineMaterial = SCNMaterial()
        outlineMaterial.diffuse.contents = UIColor.black
        textOutline.firstMaterial = outlineMaterial

        outlineNode = SCNNode(geometry: textOutline)
        outlineNode.position = SCNVector3(x: position.x, y: position.y + 0.0148, z: position.z - 0.01)
        outlineNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)

        sceneView.scene.rootNode.addChildNode(textMeasure)
        sceneView.scene.rootNode.addChildNode(outlineNode)
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
