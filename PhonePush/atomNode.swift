//
//  atomNode.swift
//  DecayDice
//
//  Created by Nicholas Harrigan on 08/02/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import SpriteKit
import Foundation


class atomNode: SKNode {
    
    var eOrbitFrames = [SKTexture]()
    var eOrbit: SKSpriteNode!
    var nucleusFrames = [SKTexture]()
    var nucleus: SKSpriteNode!
    
    var decayCheck = 0
    
    
   override init() {
    super.init()
    
    
    //Get textures for elecron orbits:
    let eOrbitAtlas = SKTextureAtlas(named: "eOrbits")
    for var i=1; i<=eOrbitAtlas.textureNames.count; i++ {
        eOrbitFrames.append(eOrbitAtlas.textureNamed("eOrbits\(i+1)"))
    }
    //Setup SpriteNode with textures - initialise on first frame
    eOrbit = SKSpriteNode(texture: eOrbitFrames[0])
    eOrbit.position = CGPoint(x:0,y:0)
    eOrbit.zPosition = 1.0
    
    //Get textures for nucleus
    let nucleusAtlas = SKTextureAtlas(named: "nucleus")
    for var i=1; i<=nucleusAtlas.textureNames.count; i++ {
        nucleusFrames.append(nucleusAtlas.textureNamed("nucleus\(i)"))
    }
    //Setup SpriteNode with textures - initialise on first frame
    nucleus = SKSpriteNode(texture: nucleusFrames[0])
    nucleus.position = CGPoint(x:-59,y:35)
    nucleus.zPosition = 0.0
    
    
    //Setup background image for atom
    var electronbg = SKSpriteNode(imageNamed: "electronbg")
    electronbg.zPosition = -1.0
    electronbg.position = CGPoint(x: 0,y: 0)

    addChild(electronbg)
    addChild(eOrbit)
    addChild(nucleus)
    
    animeOrbit()
    
    
    
    }

    
    
    func animeOrbit() {
        
        var ransize = UInt32(eOrbitFrames.count)
        
        //Action that runs electron orbit animation, starting on random frame
        //by waiting a random time that is a multiple of the time between frames
        eOrbit.runAction(
            SKAction.sequence([
                SKAction.waitForDuration(Double(arc4random_uniform(ransize))*0.05),
            SKAction.repeatActionForever(
                SKAction.animateWithTextures(
                    eOrbitFrames, timePerFrame: 0.05, resize: false, restore: true)
            )]),
            withKey: "eOrbitAnimation")
        
    }
    
    func animnucleus() {
        
        decayCheck = 1
        
        nucleus.runAction(SKAction.sequence([SKAction.animateWithTextures(nucleusFrames, timePerFrame: 0.05, resize: true, restore: false),SKAction.runBlock({self.alpha = 0.1})]), withKey: "nucleusAnimation")
        
        
    
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}