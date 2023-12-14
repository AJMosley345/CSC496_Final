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


class Player: SKSpriteNode{
    
    func move(_ direction: Direction){
        print("Move player: \(direction.rawValue)")
            switch direction{
            case .up:
                self.texture? = SKTexture(imageNamed: "player_up")
                self.physicsBody?.velocity = CGVector(dx: 0, dy: 100)
            case .down:
                self.texture? = SKTexture(imageNamed: "player_down")
                self.physicsBody?.velocity = CGVector(dx:0, dy: -100)
            case .left:
                self.physicsBody?.velocity = CGVector(dx:-100, dy: 0)
            case .right:
                self.physicsBody?.velocity = CGVector(dx:100, dy: 0)
            case .stop:
                stop()
            }
        }
        
        func stop(){
            self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        }
}
