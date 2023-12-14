//
//  Player.swift
//  Final
//
//  Created by Joseph Haywood on 12/14/23.
//

import Foundation
import SpriteKit

enum Direction: String {
    case stop
    case left
    case right
    case up
    case down
}


class Player: SKSpriteNode {
    
    private var currentDirection: Direction = .stop
    
    func move(_ direction: Direction) {
        // Only update the direction and apply movement if it's different from the current direction
        if currentDirection != direction {
            currentDirection = direction
            applyMovement(direction: currentDirection)
        }
    }
    
    func stop() {
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
    }
    
    private func applyMovement(direction: Direction) {
        print("Move player: \(direction.rawValue)")

        switch direction {
            case .up:
                self.texture = SKTexture(imageNamed: "player_up")
                self.physicsBody?.velocity = CGVector(dx: 0, dy: 100)
            case .down:
                self.texture = SKTexture(imageNamed: "player_down")
                self.physicsBody?.velocity = CGVector(dx: 0, dy: -100)
            case .left:
                self.texture = SKTexture(imageNamed: "player_left") // Assuming you have a left texture
                self.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
            case .right:
                self.texture = SKTexture(imageNamed: "player_right") // Assuming you have a right texture
                self.physicsBody?.velocity = CGVector(dx: 100, dy: 0)
            case .stop:
                self.physicsBody?.velocity = CGVector.zero
        }
    }
}
