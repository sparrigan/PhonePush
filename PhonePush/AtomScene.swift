//
//  AtomScene.swift
//  DecayDice
//
//  Created by Nicholas Harrigan on 08/02/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import SpriteKit
import UIKit

class AtomScene: SKScene {
    
    var atomArray: [atomNode] = []
    var atomsRemaining = 0
    var atomNumField:UITextField!
    //Array for storing timestep and atom number data in order TIME,NUMBER
    var decayArray:[[Int]] = [[],[]]
    
    init(sizeinput: CGSize, atomField: UITextField) {
        super.init(size: sizeinput)
        atomNumField = atomField
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = UIColor.whiteColor()
        
        
        
        //Fraction of image size to use as the padding spacing
        var R = 0.25

        //Get a test instance of atomNode to find its size
        var tempAtomNode = atomNode()
        
        var atomActualSize = (width: Double(tempAtomNode.calculateAccumulatedFrame().width), height: Double(tempAtomNode.calculateAccumulatedFrame().height))

        //Figure out the scaling to use and number of sprites in a row and column
        var scalingData = calcNums(Double(self.frame.height), W: Double(self.frame.width), ha: atomActualSize.height, wa: atomActualSize.width, R: R)
        
        //Put starting entry into array of decay data:
        decayArray[0].append(0)
        decayArray[1].append(Int(Double(scalingData.Nw)*Double(scalingData.Nh)))
        
        for i in 1...scalingData.Nw {
            for j in 1...scalingData.Nh {
                
                var newAtomNode = atomNode()
            
                atomArray.append(newAtomNode)
            
                newAtomNode.xScale = CGFloat(scalingData.rscale)
                newAtomNode.yScale = CGFloat(scalingData.rscale)
            
                newAtomNode.position = getAtomPos(scalingData.rscale,R: R, aSize: atomActualSize, i: i, j: j)
            
                addChild(newAtomNode)
            }
        }
        
        atomsRemaining = scalingData.Nw*scalingData.Nh
        
        
        /*
        for i in 0...5 {
        
            var tempAtomNode = atomNode()
            
            atomArray.append(tempAtomNode)
       
            tempAtomNode.position = CGPoint(x: i*50, y: 100)
            tempAtomNode.xScale = 0.3
            tempAtomNode.yScale = 0.3
            addChild(tempAtomNode)
            
        }
        */
        
        
        
 

    }
    
    
    //Finds the parameters for spacing out sprites
    func calcNums(H: Double, W: Double, ha: Double, wa: Double, R: Double) -> (Nw: Int, Nh: Int, rscale: Double) {
     
        
        var T1 = -R*(H*wa+W*ha)
        var T2 = pow(R,2.0)*pow(H*wa+W*ha,2.0)
        var T3 = 4*ha*wa*(9*R+10)*(11*R+10)*W*H
        var T4 = (2*ha*wa*(9*R+10)*(11*R+10))
        var rscale = (T1 + pow(T2+T3,0.5))/T4
        var Nw = ceil(100*rscale*ha*(R+1)/(H-R*rscale*ha))
        var Nh = ceil(100/Nw)
    
        //Don't think we need to check if we can get better as anything better than NwNh (for solutions) would imply Nw(Nh-1) = NwNh - Nw is still above 100. i.e. that if we take off Nw (so one row) we still get above 100 - but if this was possible then we would have gotten this in our original solution as it would have given us a lower number of rows to begin with (same argument is symmetric with respect to trying to reduce the number of columns).
        
        //Recalibrate rscale value to account for having had to ceil the Nw and Nh values
        rscale = W/(Nw*wa+(Nw+1)*R*wa)
   
        return(Int(Nw), Int(Nh), rscale)
    }
    
    
    //Returns a CGPoint for the position of sprite at location i,j
    
    func getAtomPos(rscale: Double, R: Double, aSize: (width: Double, height: Double), i: Int, j: Int) -> CGPoint {
        
        var xPos = Double(i)*R*rscale*aSize.width+(Double(i)-1)*rscale*aSize.width + rscale*aSize.width/2
        
        var yPos = Double(j)*R*rscale*aSize.height+(Double(j)-1)*rscale*aSize.height + rscale*aSize.height/2
        
        return CGPoint(x:xPos, y:yPos)
        
    }
    
    
    //Update decays
    func decayUpdate() {
       
        
        //Loop over atoms and decay with given probability
        
        for i in 0...atomArray.count-1 {
            
            if (atomArray[i].decayCheck == 0) && (Float(arc4random())/Float(UINT32_MAX) <= 0.04895) {
                
                atomArray[i].animnucleus()
                --atomsRemaining
                atomNumField.text = String(atomsRemaining)
            }
            
        }
       
        //Add new data to decayArray
        decayArray[0].append(decayArray[0][decayArray[0].count-1]+1)
        decayArray[1].append(atomsRemaining)
        
    }
    
    func getDecayData() -> [[Int]] {
        return decayArray
    }
    

    override func update(currentTime: CFTimeInterval) {
        
    }
    
    
    
}