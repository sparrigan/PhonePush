//
//  ViewController.swift
//  DecayDice
//
//  Created by Nicholas Harrigan on 07/02/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

import SpriteKit

protocol vcProtocol {
    
    func returnData()
}

class DecayDiceVC: UIViewController, vcProtocol {

    var scene:AtomScene!
    var atomNums = UITextField(frame: CGRect(x: 500, y: 50, width: 200, height: 50))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        var atomWidth = view.bounds.size.width*0.8
        
        var atomHeight = view.bounds.size.height*0.8
        
        scene = AtomScene(sizeinput: CGSize(width: atomWidth, height: atomHeight), atomField: atomNums)
        
        let skView = SKView(frame: CGRect(x: (view.bounds.size.width-atomWidth)/2,y: (view.bounds.size.height-atomHeight)/2, width: atomWidth, height: atomHeight))
        
        //println(atomWidth)
        
       // println("skView width: \(skView.frame.width). skview x: \((view.bounds.size.width-atomWidth)/2). Whole view width: \(view.bounds.size.width)")
        
         
        //let skView = SKView(frame: view.bounds)
        
        self.view.addSubview(skView)
        
        skView.presentScene(scene)
        
        atomNums.font = UIFont(name: "Arial", size: 60)
        atomNums.userInteractionEnabled = false
        atomNums.text = String(scene.atomsRemaining)
        
        view.addSubview(atomNums)
        
    
        
        //CALL MODEL THAT LAYS OUT SPRITES IN A WAY THAT DIVIDES UP VIEW BASED ON NUMBER REQUIRED.
        
        //ADD BUTTON FOR RUNNING A TIME EVOLUTION
        
        //TEXTBOX COUNTER INCREASES WITH EACH EVOLUTION
        
        //RESET BUTTON WITH "ARE YOU SURE POPUP"
        
        //WITH EACH UPDATE, EITHER DISPLAYS NUMBER REMIAINING OR DOESN'T DEPENDENT ON
        //SETTING VARIABLE.
        
        //CAN PLOT GRAPH AT END OR WHEN BUTTON IS PRESSED.
        
        //WHEN BUTTON IS PRESSED, CAN DISPLAY TABLE OF RESULTS.
        
        //===
        
        //USE SPRITEKIT. MAKE A SCENE
        
        // USE SKNODE FOR EACH ATOM.
        
        //SKNODE HAS TWO CHILDREN - ONE IS NUCLEUS, OTHER IS ORBITING ELECTRONS
        
        //CHANGE ZPOSITION OF NUCLEI TO BE BEHIND.
        
        //ANIMATE NUCLEI AND THEN CHANGE TRANSPARENCY OF PARENT NODE WHEN HAVE A DECAY.
        
        //CALL METHOD WITHIN THE SCENE THAT RUNS THROUGH ATOMS AND CHECKS FOR DECAYS ON BUTTON CLICK.
        
        //Button for progressing time by one unit
        let button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.frame = CGRectMake(100, 50, 150, 50)
        button.backgroundColor = UIColor.blueColor()
        button.setTitle("Progress 1 second", forState: UIControlState.Normal)
        button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(button)
        

        //Button for showing data
        let dataButton   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        dataButton.frame = CGRectMake(300, 50, 150, 50)
        dataButton.backgroundColor = UIColor.blueColor()
        dataButton.setTitle("Show Data", forState: UIControlState.Normal)
        dataButton.addTarget(self, action: "dataButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(dataButton)
        
            
    }
    
    

    func buttonAction(sender:UIButton!)
    {
        scene.decayUpdate()
    }

    
    func dataButtonAction(sender:UIButton!)
    {
        let dataVC = dataViewController()
        //Set delegate value of dataVC
        dataVC.delegate = self
        //self.presentViewController(dataVC, animated: true, completion: nil)
        self.navigationController?.pushViewController(dataVC, animated: true)
        
        dataVC.decayData = scene.getDecayData()
        
        //CALL scene.getDecayData() here to get [[Int]] and then pass to dataVC
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max-min) + min
    }

    
    func returnData() {
        //println("YUS")
    }
    

}

