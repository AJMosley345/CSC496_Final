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
        for _ in 1...3 {  // Adjust the number of Pokémons to spawn
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
        guard let touch = touches.first else { return }
        _ = touch.location(in: self)
        // Implement touch logic (if needed)
    }

    override func update(_ currentTime: TimeInterval) {
        player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0) // Called before each frame is rendered
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }

        let dt = currentTime - self.lastUpdateTime

        for entity in self.entities {
            entity.update(deltaTime: dt)
        }

        enumerateChildNodes(withName: "pokemon") { node, _ in
            guard let pokemonNode = node as? SKSpriteNode, let player = self.player else { return }
            
            let distance = hypot(pokemonNode.position.x - player.position.x,
                                 pokemonNode.position.y - player.position.y)
            
            let visibilityThreshold: CGFloat = 100
            if distance < visibilityThreshold {
                pokemonNode.alpha = 1  // Make Pokémon visible
            } else {
                pokemonNode.alpha = 0  // Keep Pokémon invisible
            }
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
