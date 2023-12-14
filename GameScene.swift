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
    private var player: Player?
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        physicsWorld.gravity = CGVector(dx: 0, dy: 0) // Adjust as needed
        physicsWorld.contactDelegate = self
    }
    
    override func didMove(to view: SKView) {
        playBackgroundMusic("background_music.mp3")
        player = childNode(withName: "player") as? Player
        
        setupPlayerPhysics()
        spawnPokemons()
    }

    func setupPlayerPhysics() {
        player?.physicsBody = SKPhysicsBody(rectangleOf: player?.size ?? CGSize.zero)
        player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player?.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player?.physicsBody?.contactTestBitMask = PhysicsCategory.Pokemon
        player?.physicsBody?.collisionBitMask = PhysicsCategory.None
        player?.physicsBody?.isDynamic = true
    }

    func spawnPokemons() {
        for _ in 1...3 {
            spawnPokemon()
        }
    }

    func spawnPokemon() {
        let pokemonNumber = Int.random(in: 1...151)
        let pokemonNode = SKSpriteNode(imageNamed: "\(pokemonNumber)")
        pokemonNode.name = "pokemon"
        pokemonNode.position = CGPoint(x: CGFloat.random(in: 0...self.size.width),
                                       y: CGFloat.random(in: 0...self.size.height))
        pokemonNode.physicsBody = SKPhysicsBody(rectangleOf: pokemonNode.size)
        pokemonNode.physicsBody?.categoryBitMask = PhysicsCategory.Pokemon
        pokemonNode.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        pokemonNode.physicsBody?.collisionBitMask = PhysicsCategory.None
        pokemonNode.physicsBody?.isDynamic = false
        pokemonNode.alpha = 0  // Make Pokémon initially invisible

        addChild(pokemonNode)
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Intentionally empty if you do not wish to change direction on move
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }

    func touchDown(atPoint pos: CGPoint) {
        let nodesAtPoint = nodes(at: pos)
        for node in nodesAtPoint {
            if let nodeName = node.name, nodeName.starts(with: "controller_") {
                let directionString = nodeName.replacingOccurrences(of: "controller_", with: "")
                if let direction = Direction(rawValue: directionString) {
                    player?.move(direction)
                }
            }
        }
    }

    func touchUp(atPoint pos: CGPoint) {
        player?.stop()
    }
        

    override func update(_ currentTime: TimeInterval) {
            // Called before each frame is rendered
            if self.lastUpdateTime == 0 {
                self.lastUpdateTime = currentTime
            }
            
            let dt = currentTime - self.lastUpdateTime
            for entity in self.entities {
                entity.update(deltaTime: dt)
            }
            
            self.lastUpdateTime = currentTime
        }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if firstBody.categoryBitMask == PhysicsCategory.Player && secondBody.categoryBitMask == PhysicsCategory.Pokemon {
            if let pokemonNode = secondBody.node as? SKSpriteNode {
                print("Player has encountered a Pokémon!")
                playCaptureSound()
                pokemonNode.removeFromParent()
            }
        }
    }
}

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0b1
    static let Pokemon: UInt32 = 0b10
}




// Player class and other necessary classes and extensions follow...

