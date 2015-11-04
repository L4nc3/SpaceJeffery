//
//  GameScene.swift
//  Space Jeffery
//
//  Created by Lance Ackerman on 11/1/15.
//  Copyright (c) 2015 Mav3r1ck. All rights reserved.
//

import SpriteKit

enum BodyType: UInt32 {
    case player = 1
    case enemy = 2
    case ground = 4
    case sky = 6
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var gameOver = false
    let endLabel = SKLabelNode(text: "Game Over")
    let endLabel2 = SKLabelNode(text: "Tap to restart!")
    let touchToBeginLabel = SKLabelNode(text: "Touch to begin!")
    let points = SKLabelNode(text: "0")
    var numPoints = 0
    let explosionSound = SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: true)
    let coinSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    
    
    let player = SKSpriteNode(imageNamed:"spacemonkey_fly02")
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        physicsWorld.contactDelegate = self
        backgroundColor = UIColor.blackColor()
        player.position = CGPoint(x:frame.size.width * 0.1, y: frame.size.height * 0.5)
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(circleOfRadius:player.frame.size.width * 0.3)
        player.physicsBody?.allowsRotation = false
        
        let collisionFrameBottom = CGRectInset(frame, 0, -self.size.height * 0.2)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: collisionFrameBottom)
        
        let collisionFrameTop = CGRectInset(frame, 0, self.size.height * 0.01)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: collisionFrameTop)
        
        physicsBody?.categoryBitMask = BodyType.ground.rawValue
        physicsBody?.categoryBitMask = BodyType.sky.rawValue
        player.physicsBody?.categoryBitMask = BodyType.player.rawValue
        player.physicsBody?.contactTestBitMask = BodyType.enemy.rawValue
        player.physicsBody?.collisionBitMask = BodyType.ground.rawValue
        player.physicsBody?.collisionBitMask = BodyType.sky.rawValue
        player.physicsBody?.dynamic = false
        
        setupLabels()
    }
    
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        let random = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return random * (max - min) + min
    }
    
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "boss_ship")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: frame.size.width, y: frame.size.height * random(min: 0, max: 1))
        addChild(enemy)
        enemy.runAction( SKAction.moveByX(-size.width - enemy.size.width, y: 0.0, duration: NSTimeInterval(random(min: 1, max: 2))))
        
        // contactDelegate
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width/4)
        enemy.physicsBody?.dynamic = false
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody?.categoryBitMask = BodyType.enemy.rawValue
        enemy.physicsBody?.contactTestBitMask = BodyType.player.rawValue
        enemy.physicsBody?.collisionBitMask = 0
        
    }
    
    
    func jumpPlayer() {
        let impulse =  CGVector(dx: 0, dy: 75)
        player.physicsBody?.applyImpulse(impulse)
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        if (!gameOver) {
            if player.physicsBody?.dynamic == false {
                player.physicsBody?.dynamic = true
                touchToBeginLabel.hidden = true
                backgroundColor = SKColor.blackColor()
                
                runAction(SKAction.repeatActionForever(
                    SKAction.sequence([
                        SKAction.runBlock(spawnEnemy),
                        SKAction.waitForDuration(1.0)])))
            }
           
            jumpPlayer()
            
        }
  
        else if (gameOver) {
            let newScene = GameScene(size: size)
            newScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            view?.presentScene(newScene, transition: reveal)
        }
    
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch(contactMask) {
        case BodyType.player.rawValue | BodyType.enemy.rawValue:
            let secondNode = contact.bodyB.node
            secondNode?.removeFromParent()
            let firstNode = contact.bodyA.node
            firstNode?.removeFromParent()
            endGame()
        default:
            return
        }
    }
    
    func setupLabels() {

        touchToBeginLabel.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        touchToBeginLabel.fontColor = UIColor.whiteColor()
        touchToBeginLabel.fontSize = 50
        addChild(touchToBeginLabel)
        
        points.position = CGPoint(x: frame.size.width/2, y: frame.size.height * 0.2)
        points.fontColor = UIColor.whiteColor()
        points.fontSize = 100
        addChild(points)
    }
    
    func updateEnemy(enemy: SKNode) {
        if enemy.position.x < 0 {
            enemy.removeFromParent()
            runAction(coinSound)
            numPoints++
            points.text = "\(numPoints)"  
        }
    }
    
    func endGame() {

        gameOver = true
        removeAllActions()
        runAction(explosionSound)

        endLabel.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        endLabel.fontColor = UIColor.whiteColor()
        endLabel.fontSize = 50
        endLabel2.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2 + endLabel.fontSize)
        endLabel2.fontColor = UIColor.whiteColor()
        endLabel2.fontSize = 20
        points.fontColor = UIColor.whiteColor()
        addChild(endLabel)
        addChild(endLabel2)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if !gameOver {
            if player.position.y <= 0 {
                endGame()
            }
            enumerateChildNodesWithName("enemy") {
                enemy, _ in
        if enemy.position.x <= 0 {
            self.updateEnemy(enemy)
            }
         }
       }
    }


}
