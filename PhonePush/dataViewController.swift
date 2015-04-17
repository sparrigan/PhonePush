//
//  dataViewController.swift
//  DecayDice
//
//  Created by Nicholas Harrigan on 11/02/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import Foundation
import UIKit


class dataViewController: UIViewController, UIDocumentInteractionControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    //MAYBE GET RID OF THIS:
    /*
    override init() {
        super.init()
    }

   required init(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
*/
    //END OF MAYBE GET RID OF STUFF
    
    var tableView:UITableView = UITableView()
    var items: [String] = ["Viper", "X", "Games"]
    
    var decayData: [[Int]] = [[],[]]
    var delegate:vcProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.frame = CGRectMake(0, 50, 320, 200);
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        
        
        
        
        
        // Do any additional setup after loading the view,
        // typically from a nib.

        self.view.backgroundColor = UIColor.whiteColor()
        
        let backButton   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        backButton.frame = CGRectMake(100, 50, 150, 50)
        backButton.backgroundColor = UIColor.blueColor()
        backButton.setTitle("Go Back", forState: UIControlState.Normal)
        backButton.addTarget(self, action: "backButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(backButton)

        let emailButton   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        emailButton.frame = CGRectMake(300, 50, 150, 50)
        emailButton.backgroundColor = UIColor.blueColor()
        emailButton.setTitle("Email data", forState: UIControlState.Normal)
        emailButton.addTarget(self, action: "emailButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(emailButton)

        
    }

    
    //Takes in two Arrays of Ints and converts each element to a string, and cocatenates
    //corresponding entries of arrays with a comma. and then joins with return character Note: Order of inputs is important
    func intToStringRows (AA: [Int], BB: [Int])->String {
        var temp:[String] = []
        //Only concatenate strings up until the length of shortest array input
        var shortestCount = [AA.count,BB.count].reduce(Int.max, combine: { min($0, $1) })
        
        for i in 0...shortestCount-1 {
            temp += [",".join([String(format:"%f",Double(AA[i])),String(format:"%f",Double(BB[i]))])]
        }
 
        
        var pString:String = "\n".join(temp)

        return pString
    }
    
    func backButtonAction(sender:UIButton!)
    {
        
        self.navigationController?.popViewControllerAnimated(true)
        //self.presentViewController(ViewController, animated: true, completion: nil)
        
    }

    func emailButtonAction(sender:UIButton!)
    {
        
        exportToEmail(self, data: intToStringRows(decayData[0], BB: decayData[1]))
        
    }
    
    //Function for exporting VELOCITY data to email
    //Call this from a button fired function
    func exportToEmail(delegate: UIDocumentInteractionControllerDelegate, data: String){
        let fileName = NSTemporaryDirectory().stringByAppendingPathComponent("myFile.csv")
        let url: NSURL! = NSURL(fileURLWithPath: fileName)
        data.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        if url != nil {
            let docController = UIDocumentInteractionController(URL: url)
            docController.UTI = "public.comma-separated-values-text"
            docController.delegate = delegate
            docController.presentPreviewAnimated(true)
        }
    }
    
    //Required method to be delegate of UIInteractionControllerView
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    
    //TableView required methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
    }
    
    
}