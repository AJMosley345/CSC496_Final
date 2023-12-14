//
//  GameScene.swift
//  Final
//
//  Created by AJ on 11/30/23.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var player: Player?
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        physicsWorld.contactDelegate = self

    }
    
    override func didMove(to view: SKView) {
        playBackgroundMusic("background_music.mp3")
        player = childNode(withName: "player") as? Player
    }
    func playBackgroundMusic(_ filename: String) {
            let backgroundMusic = SKAudioNode(fileNamed: filename)
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }
    
    func playCaptureSound() {
        let playSound = SKAction.playSoundFileNamed("capture_sound.mp3", waitForCompletion: false)
        self.run(playSound)
    }

    
    
    func touchDown(atPoint pos : CGPoint) {
        print("touch down")
        let nodeAtPoint = atPoint(pos)
        if let touchedNode = nodeAtPoint as? SKSpriteNode{
            if touchedNode.name?.starts(with: "controller_") == true{
                let direction = touchedNode.name?.replacingOccurrences(of: "controller_", with: "")
                player?.move(Direction(rawValue: direction ?? "stop")!)
            }
        }
    }
    
    
    
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}

extension GameScene:SKPhysicsContactDelegate{
    func didBegin(_ contact: SKPhysicsContact) {
        let firstNode = contact.bodyA.node as? SKSpriteNode
        let secondNode = contact.bodyB.node as? SKSpriteNode
        
        if let firstNode = firstNode, let secondNode = secondNode {
            if (firstNode.name == "player" && secondNode.name == "pokemon") || (firstNode.name == "pokemon" && secondNode.name == "player") {
                print("player touched pokemon")
            }
        }
    }
}
