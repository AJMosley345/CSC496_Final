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
    
    private var pokemonToSpawn = 3
    private var backgroundMusic: SKAudioNode?
    
    private var capturedPokemonName: String?

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
        let currentPokemonCount = self.children.filter { $0.name == "pokemon" }.count
        let pokemonNeeded = 3 - currentPokemonCount
        
        guard pokemonNeeded > 0 else { return } // Ensure we have a positive number of Pokémon to spawn
        
        for _ in 1...pokemonNeeded {
            spawnPokemon()
        }
    }
    
    
    func spawnPokemon() {
        let pokemonNumber = Int.random(in: 1...151)
        let pokemonNode = SKSpriteNode(imageNamed: "\(pokemonNumber)")
        pokemonNode.name = "pokemon"
        
        let backgroundWidth = CGFloat(1024.731)
        let backgroundHeight = CGFloat(753.924)
        
        let xOffset = backgroundWidth / 2
        let yOffset = backgroundHeight / 2
        
        let margin: CGFloat = 50
        let xRange = (-xOffset + margin)...(xOffset - margin)
        let yRange = (-yOffset + margin)...(yOffset - margin)
        
        pokemonNode.position = CGPoint(
            x: CGFloat.random(in: xRange),
            y: CGFloat.random(in: yRange)
        )
        
        // Configure the physics body and other properties for the Pokémon
        pokemonNode.physicsBody = SKPhysicsBody(rectangleOf: pokemonNode.size)
        pokemonNode.physicsBody?.categoryBitMask = PhysicsCategory.Pokemon
        pokemonNode.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        pokemonNode.physicsBody?.collisionBitMask = PhysicsCategory.None
        pokemonNode.physicsBody?.isDynamic = false
        pokemonNode.alpha = 0
        pokemonNode.zPosition = 1
        
        pokemonNode.isHidden = true

        // Add the Pokémon to the scene
        self.addChild(pokemonNode)
        
        print("Spawning Pokémon at position: \(pokemonNode.position)")

    }
    
   

    private func displayCapturedPokemon(_ pokemonNode: SKSpriteNode) {
        
        let capturedPokemonDisplay = SKSpriteNode(texture: pokemonNode.texture)
                
        capturedPokemonDisplay.size = CGSize(width: 100, height: 100)
        capturedPokemonDisplay.position = CGPoint(x: frame.midX, y: frame.midY)
        capturedPokemonDisplay.zPosition = 10
        addChild(capturedPokemonDisplay)

        let nameLabel = SKLabelNode(fontNamed: "Arial")
        nameLabel.name = pokemonNode.name
        nameLabel.fontSize = 20
        nameLabel.fontColor = SKColor.black
        nameLabel.position = CGPoint(x: capturedPokemonDisplay.position.x, y: capturedPokemonDisplay.position.y - 50)
        nameLabel.zPosition = 11
        addChild(nameLabel)

        let delayAction = SKAction.wait(forDuration: 2.0)
        let removeAction = SKAction.removeFromParent()
        capturedPokemonDisplay.run(SKAction.sequence([delayAction, removeAction]))
        nameLabel.run(SKAction.sequence([delayAction, removeAction]))
        }

    
    // Define a dictionary to map Pokémon numbers to their names




    
    func playBackgroundMusic(_ filename: String) {
            let backgroundMusic = SKAudioNode(fileNamed: filename)
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
    }


    
    func stopBackgroundMusic() {
            backgroundMusic?.run(SKAction.stop())
    }

        func resumeBackgroundMusic() {
            backgroundMusic?.run(SKAction.play())
    }
    
    func playCaptureSound() {
            stopBackgroundMusic() // Stop the background music
            let playSound = SKAction.playSoundFileNamed("capture_sound.mp3", waitForCompletion: true)
            run(playSound) { [weak self] in
                // Resume background music after the capture sound has finished playing
                self?.resumeBackgroundMusic()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
            // Spawn initial Pokémon
            spawnPokemonsIfNeeded()
        }
        
        let dt = currentTime - self.lastUpdateTime
        
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
        
        // Check and spawn Pokémon if needed
        spawnPokemonsIfNeeded()
        
        for pokemon in self.children.filter({ $0.name == "pokemon" }) {
            if let pokemonNode = pokemon as? SKSpriteNode, let playerNode = self.player {
                let distance = hypot(pokemonNode.position.x - playerNode.position.x,
                                     pokemonNode.position.y - playerNode.position.y)
                
                if distance < 100 {  // Set a threshold distance for visibility
                    pokemonNode.alpha = 1  // Make Pokémon visible
                } else {
                    pokemonNode.alpha = 0  // Keep Pokémon invisible
                }
            }
        }
    }
    
    private func spawnPokemonsIfNeeded() {
        let currentPokemonCount = self.children.filter { $0.name == "pokemon" }.count
        if currentPokemonCount < self.pokemonToSpawn {
            for _ in 1...(self.pokemonToSpawn - currentPokemonCount) {
                spawnPokemon()
            }
        }
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
                // Display the captured Pokémon and print its name
                displayCapturedPokemon(pokemonNode)
                print("Captured Pokémon: \(pokemonNode.name ?? "Unknown")")
                displayCapturedPokemon(pokemonNode)
                pokemonNode.removeFromParent() // Remove the captured Pokémon
                playCaptureSound()
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

