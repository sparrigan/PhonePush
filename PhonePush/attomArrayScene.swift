//
//  attomArrayScene.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 13/05/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//




import UIKit

class atomArrayScene: UIView {
    
    var initialSize: CGRect = CGRectZero
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var checkFirst = 0
    var image = UIImage(named: "electronbg")
    var atomActualSize = (width: 0.0,height: 0.0)
    //Fraction of image size to use as the padding spacing
    var R = 0.25
    //Used to check whether size of view has changed and needs to re-layout
    var oldThisViewSize = CGSize(width: 0.0, height: 0.0)
    var oldAtomNumbers = (width: 0.0, height: 0.0)
    //Initialise view dictionary
    var viewsDictionary = Dictionary<String, UIImageView>()
    //Metric dictionary
    var metricDictionary = Dictionary<String, Double>()
    //Array for holding row views
    var rowArray = [UIView]()
    var viewDicDic = Dictionary<Int,Dictionary<String,UIImageView>>()
    //Spacer views used in autolayout for atoms
    var spViewLeft:UIImageView = UIImageView(frame: CGRectMake(0,0,10,800))
    var spViewRight:UIImageView = UIImageView(frame: CGRectMake(0,0,10,800))
    var spViewTop:UIView = UIView(frame: CGRectMake(0,0,800,10))
    var spViewBottom:UIView = UIView(frame: CGRectMake(0,0,800,10))
    var constraintsH:[AnyObject] = []
    var constraintsHIsAdded = 0
    var atomHeightConstraints = Array<NSLayoutConstraint>()
    var atomHeightConstraintsIsAdded = 0
    var atomVCentConstraints:[[AnyObject]] = []
    var atomVCentConstraintsIsAdded = 0
    var viewsDictionaryRows = Dictionary<String, UIView>()
    var rowViewWidthIsAdded = 0
    var rowConstraintsHIsAdded = 0
    var rowHeightConstraints:[[AnyObject]] = []
    var rowConstraintsH:[AnyObject] = []

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        //self.backgroundColor = UIColor.blueColor()
        
        //Get a test instance of atomNode to find its size
        var tempAtomNode = UIImageView(image: image)
        atomActualSize.width = Double(tempAtomNode.bounds.width)
        atomActualSize.height = Double(tempAtomNode.bounds.height)
        //Set up metric values for autolayout
        metricDictionary["screenHeight"] = Double(screenSize.height)
        metricDictionary["screenWidth"] = Double(screenSize.width)
        metricDictionary["parentWidth"] = Double(self.frame.width)
    
        //Set spacer views ready for autolayout
        spViewLeft.setTranslatesAutoresizingMaskIntoConstraints(false)
        spViewRight.setTranslatesAutoresizingMaskIntoConstraints(false)
        spViewTop.setTranslatesAutoresizingMaskIntoConstraints(false)
        spViewBottom.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //Setup Top and Bottom spacers for rows
        self.addSubview(spViewTop)
        self.addSubview(spViewBottom)
        viewsDictionaryRows["spViewTop"] = spViewTop
        viewsDictionaryRows["spViewBottom"] = spViewBottom
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "actOnStatusBarNotification", name: UIApplicationWillChangeStatusBarOrientationNotification, object: nil)
        
    
    }
    
    
    func actOnStatusBarNotification() {
        self.setNeedsUpdateConstraints()
       
    }
    
    
    override func updateConstraints() {
        
        println("UPDATE CONSTRIANTS CALLED")
        super.updateConstraints()
        
        //doTheWork()
        
        //self.layoutSubviews()
    }
    
    
    

    func doTheWork() {
    
        //Remove existing constraints
        self.removeConstraints(self.constraints())
        if (rowArray.count > 1) {
            for kk in 0...(rowArray.count-1) {
                rowArray[kk].removeConstraints(rowArray[kk].constraints())
            }
        }
        //Remove all existing row views
        if (rowArray.count > 1) {
            for kk in 0...(rowArray.count-1) {
        
                rowArray[kk].subviews.map({ $0.removeFromSuperview() })
                rowArray[kk].removeFromSuperview()
            }
        }
        
        
        //Clear rowArray
        rowArray = []
        //Clear row constraints
        rowHeightConstraints = []
        rowConstraintsH = []
    
    }
    
    //func doTheWork() {
    override func layoutSubviews() {
        println("Here with height = \(self.frame.height) and width = \(self.frame.width)")
        if self.frame.height != oldThisViewSize.height || self.frame.width != oldThisViewSize.width {
            oldThisViewSize.height = self.frame.height
            oldThisViewSize.width = self.frame.width
            
            //Find number of atoms for a row/column for requested size of this view.
            var scalingData = calcNums(Double(self.frame.height), W: Double(self.frame.width), ha: atomActualSize.height, wa: atomActualSize.width, R: R)
            
            //Check if number of atoms changed (if not then autolayout takes care of everything)
            if Double(scalingData.Nw) != oldAtomNumbers.width || Double(scalingData.Nh) != oldAtomNumbers.height {
                //println("")
                //println("===This go: \(scalingData.Nh) rows")
                //println("===This go: \(scalingData.Nw) atoms on each row")
                //CLEAN UP BEFORE WE START
                //Remove existing constraints
                self.removeConstraints(self.constraints())
                if (rowArray.count > 1) {
                     for kk in 0...(rowArray.count-1) {
                         rowArray[kk].removeConstraints(rowArray[kk].constraints())
                     }
                }
                //Remove all existing row views
                if (rowArray.count > 1) {
                    for kk in 0...(rowArray.count-1) {
                        rowArray[kk].removeFromSuperview()
                    }
                }
                
                //Clear rowArray
                rowArray = []
                //Clear row constraints
                rowHeightConstraints = []
                rowConstraintsH = []
                
                //println("Constraints on self at start of this reordering: \(self.constraints())")
                
                
                
                //LOOP OVER ROWS
                for ii in 1...scalingData.Nh {
                    //Clear arrays that are reused for each row
                    constraintsH = []
                    atomHeightConstraints = []
                    atomVCentConstraints = []
                    
                    //println("Row \(ii)")
                    //Setup the rowview for this row, including adding to relevant viewdictionaries
                    var rowView = UIView(frame: CGRectMake(0,0,self.frame.width,900))
                    //rowView.backgroundColor = UIColor.redColor()
                    //Add new row view to array
                    rowArray.append(rowView)
                    //Add the row to the row viewDic (used for inter-row autolayouts)
                    viewsDictionaryRows["rowView\(ii)"] = rowArray[rowArray.count-1]
                    //Create a viewDic for the atoms in the row and include spacer views
                    viewDicDic[ii] = Dictionary<String,UIImageView>()
                    viewDicDic[ii]!["spViewLeft"] = UIImageView(frame: CGRectMake(0,0,10,800))
                    viewDicDic[ii]!["spViewLeft"]!.setTranslatesAutoresizingMaskIntoConstraints(false)
                    rowView.addSubview(viewDicDic[ii]!["spViewLeft"]!)
                    viewDicDic[ii]!["spViewRight"] = UIImageView(frame: CGRectMake(0,0,10,800))
                    viewDicDic[ii]!["spViewRight"]!.setTranslatesAutoresizingMaskIntoConstraints(false)
                    rowView.addSubview(viewDicDic[ii]!["spViewRight"]!)
                    rowView.addSubview(spViewLeft)
                    rowView.addSubview(spViewRight)
                    //Dear autoformat: I'll handle these constraints, thank you very much.
                    rowView.setTranslatesAutoresizingMaskIntoConstraints(false)
                    
                    self.addSubview(rowView)
                
                    //LOOP OVER ATOMS WITHIN THIS ROW
                    
                    for jj in 1...scalingData.Nw {
                        
                        //Add atoms (including to viewDictionary)
                        var tempAtomNode = UIImageView(image: image)
                        tempAtomNode.setTranslatesAutoresizingMaskIntoConstraints(false)
                        //Add reference to new atom to viewDic for this row
                        //COME BACK AND OUT HANDLER FOR IF NO ELEMENT!
                        viewDicDic[ii]!["Atom\(jj)"] = tempAtomNode
                        rowView.addSubview(viewDicDic[ii]!["Atom\(jj)"]!)
                    }
                    
                    //Atom constraints
                    //*Horizontal*
                    var constraintString = buildAtomConstraint(scalingData.Nw)
                    constraintsH = NSLayoutConstraint.constraintsWithVisualFormat(constraintString, options: NSLayoutFormatOptions(0), metrics: nil, views: viewDicDic[ii]!)
                    rowView.addConstraints(constraintsH)
                    //*Vertical* constraints for atoms within one row:
                    //Single constraints to keep heights of atoms same as widths
                                //Create new constraints
                    for jj in 1...scalingData.Nw {
                        atomHeightConstraints.append(NSLayoutConstraint(item: viewDicDic[ii]!["Atom\(jj)"]!, attribute: .Height, relatedBy: .Equal, toItem: viewDicDic[ii]!["Atom\(jj)"]!, attribute: .Width, multiplier: 1.0, constant: 0))
                    }
                    
                    rowView.addConstraints(atomHeightConstraints)
                    //Vertical centering constraints for each atom in the row view
                    //Create new constraints
                    for jj in 1...scalingData.Nw {
                        atomVCentConstraints.append(NSLayoutConstraint.constraintsWithVisualFormat("V:|[Atom\(jj)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewDicDic[ii]!))
                    }
                    for jj in 1...scalingData.Nw {
                        rowView.addConstraints(atomVCentConstraints[jj-1])
                    }
                    
                }
                
                
                //ROW CONSTRAINTS
                
                //*Horizontal* Loop through views and set width constraints
                for kk in 0...rowArray.count-1 {
                    rowHeightConstraints.append(NSLayoutConstraint.constraintsWithVisualFormat("H:|[rowView\(kk+1)(<=screenWidth)]|", options: NSLayoutFormatOptions(0), metrics: metricDictionary, views: viewsDictionaryRows))
                }
                for kk in 0...(rowHeightConstraints.count-1) {
                    self.addConstraints(rowHeightConstraints[kk])
                }
            
                //*Vertical* constraints for row views:
                
                //Generate string of VFL constraints for all row views vertical alignment
                var rowConstraintString = buildRowConstraint(rowArray.count)
                //Add constraint
                rowConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat(rowConstraintString, options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionaryRows)
                self.addConstraints(rowConstraintsH)

                
                for jj in 0...scalingData.Nh-1 {
                    self.addSubview(rowArray[jj])
                }
                
              //End of check for number of atoms changed
            }
        
            if (self.backgroundColor == UIColor.greenColor()) {
                self.backgroundColor = UIColor.purpleColor()
                //println("HERE")
            } else {
                self.backgroundColor = UIColor.greenColor()
                //println("NO HERE")
            }
            
        }
            
    }

    /*
    
    override func layoutSubviews() {
    
        //ADD ALL NECESSARY SUBVIEWS IN INIT
        
        //ON EACH LAYOUTSUBVIEW, RECALCULATE NW AND NH, IF BIGGER THEN ADD MORE SUBVIEWS AS REQUIRED
        
        //THEN ON EACH LAYOUTSUBVIEW, IF THE SIZE OF PARENT VIEW IS DIFFERENT THEN *REMOVE* ALL
        //EXISTING CONSTRAINTS, AND ADD NEW ONES APPROPRIATELY.
        //THEN CALL LAYOUTIFNEEDED
        //ADD CHECKVAR TO MAKE SURE THIS IS ONLY DONE ONCE FOR A GIVEN SIZE OF SUBVIEW
        
        //Check if size of parent view has changed
        
        
        if self.frame.height != oldThisViewSize.height || self.frame.width != oldThisViewSize.width {
            oldThisViewSize.height = self.frame.height
            oldThisViewSize.width = self.frame.width

            //Find number of atoms for a row/column for requested size of this view.
            var scalingData = calcNums(Double(self.frame.height), W: Double(self.frame.width), ha: atomActualSize.height, wa: atomActualSize.width, R: R)
            
            //Check if number of atoms changed (if not then autolayout takes care of everything)
            if Double(scalingData.Nw) != oldAtomNumbers.width || Double(scalingData.Nh) != oldAtomNumbers.height {
                //  REMOVING ALL CONSTRAINTS HERE
                
                //if (rowArray.count > 1) {
               //     for kk in 0...(rowArray.count-1) {
               ///         rowArray[kk].removeConstraints(rowArray[kk].constraints())
               //     }
               // }

                
                
    
                self.removeConstraints(self.constraints())
                if rowArray.count > 1 {
                for ii in 0...rowArray.count-1 {
                    rowArray[ii].removeConstraints(rowArray[ii].constraints())
                
                }
                }
                constraintsH = []
                atomHeightConstraints = []
                atomVCentConstraints = []

                
                  println("New scalingData.Nh is \(scalingData.Nh)")
                //If only Nh is different then just add new rows at Nh-NhOLD (each with Nw)
                //Otherwise loop through all Nh, checking each row for how many atoms it has and 
                //adding if necessary (existing ones might need some, new ones will need all)
                
                //If new Nh is less than previous then remove extra rows from rowArray first
                println("Before removing rows have \(rowArray.count) rows")
                if scalingData.Nh < rowArray.count {
                    for var ii = rowArray.count-1; ii > scalingData.Nh-1; --ii {
                        rowArray[ii].removeFromSuperview()
                        rowArray.removeAtIndex(ii)
                        //Remove this row from the row viewDic
                        viewsDictionaryRows.removeValueForKey("rowView\(ii+1)")
                        //Remove atoms viewDic for this row from dictionary
                        viewDicDic.removeValueForKey(ii)
                    }
                }
                println("AFTER removing rows have \(rowArray.count) rows")

                
                
                
                
                //Now loop through rows and add/remove atoms as necessary
                for ii in 1...scalingData.Nh {
                    
                    
                    
                    var rowView = UIView()
                    println("NOW DOING ROW NUMBER \(ii)")
                    //Check whether rowView already exists at this index & if not add a new rowView
                    if ii > rowArray.count {
                        //View for holding a single row of atoms
                        rowView = UIView(frame: CGRectMake(0,0,self.frame.width,900))
                        rowView.backgroundColor = UIColor.redColor()
                        //Add new row view to array
                        rowArray.append(rowView)
                        //Add the row to the row viewDic (used for inter-row autolayouts)
                        viewsDictionaryRows["rowView\(ii)"] = rowArray[rowArray.count-1]
                        //Create a viewDic for the atoms in the row and include spacer views
                        viewDicDic[ii] = Dictionary<String,UIImageView>()
                        viewDicDic[ii]!["spViewLeft"] = UIImageView(frame: CGRectMake(0,0,10,800))
                        viewDicDic[ii]!["spViewLeft"]!.setTranslatesAutoresizingMaskIntoConstraints(false)
                        rowView.addSubview(viewDicDic[ii]!["spViewLeft"]!)
                        viewDicDic[ii]!["spViewRight"] = UIImageView(frame: CGRectMake(0,0,10,800))
                        viewDicDic[ii]!["spViewRight"]!.setTranslatesAutoresizingMaskIntoConstraints(false)
                        rowView.addSubview(viewDicDic[ii]!["spViewRight"]!)
                        rowView.addSubview(spViewLeft)
                        rowView.addSubview(spViewRight)
                        //Dear autoformat: I'll handle these constraints, thank you very much.
                        rowView.setTranslatesAutoresizingMaskIntoConstraints(false)
                        self.addSubview(rowView)
                    } else {
                        rowView = rowArray[ii-1]
                    }
                    
                    self.removeConstraints(self.constraints())
                    
                    rowView.removeConstraints(rowView.constraints())
                    
                    constraintsH = []
                    atomHeightConstraints = []
                    atomVCentConstraints = []
                    
                    println("AFTER adding rows when needed have \(rowArray.count) rows")
                    
                    println("viewDic contains data for \(viewDicDic.count) rows")
                    
                    println("Number of atoms in current row dic is: \(viewDicDic[ii]!.count)")
                    
                    //Check if need to add/remove atoms & constraints to this row
                    //Case for adding atoms:
                    //if Double(scalingData.Nw) > oldAtomNumbers.width {
                    
                    //Subtract 2 because have spacer views in this dictionary as well as atoms
                    var oldvarDicAtomNumb = viewDicDic[ii]!.count - 2
                    
                    if scalingData.Nw > oldvarDicAtomNumb {
                        
                        //Generate Nw atomNodes and add to viewDic for autolayout and sub to current row view
                        for jj in (oldvarDicAtomNumb+1)...scalingData.Nw {
                        
                            println("Added \(jj) times")
                            var tempAtomNode = UIImageView(image: image)
                            tempAtomNode.setTranslatesAutoresizingMaskIntoConstraints(false)
                            //Add reference to new atom to viewDic for this row
                            //COME BACK AND OUT HANDLER FOR IF NO ELEMENT!
                            viewDicDic[ii]!["Atom"+String(jj)] = tempAtomNode
                            rowView.addSubview(tempAtomNode)
                        }

                    //Case for removing atoms
                    } else if scalingData.Nw < oldvarDicAtomNumb {
                        for var jj = oldvarDicAtomNumb; jj > scalingData.Nw; --jj {
                            println("Removed \(jj) times")
                            //Remove excess atom from rowview and from relevant viewDic
                            //COME BACK AND OUT HANDLER FOR IF NO ELEMENT!
                            viewDicDic[ii]!["Atom"+String(jj)]!.removeFromSuperview()
                            viewDicDic[ii]!.removeValueForKey("Atom"+String(jj))
                        }
                    }
                    //println("At row \(ii) and have \(viewDicDic[ii]!.count-2) Atoms")
                    
                    //Now have the correct number of atoms in this rowView, update constraints
                    
                    //CONSTRAINTS BETWEEN ATOMS AND ROW VIEW

                    //Build string for horizontal constraints on atoms within this row. Make atoms all same
                    //width and give standard spacing (could include custom spacing with metricsDictionary)
                    
                    //!!!!NEED TO MAKE SURE WE HAVE REMOVED CONSTRAINTS BEFORE ADDING THEM ON AGAIN
                    
                    var constraintString = buildAtomConstraint(scalingData.Nw)


                    //Remove old constraints
                    if constraintsHIsAdded != 0 {
                        rowView.removeConstraints(constraintsH)
                        constraintsH = []
                    }
                    //Remove constraints if they have already been added
                    if atomHeightConstraintsIsAdded != 0 {
                        rowView.removeConstraints(atomHeightConstraints)
                        atomHeightConstraints = []
                    }
                    //Remove constraints if they have already been added
                    if atomVCentConstraintsIsAdded != 0 {
                        for jj in 0...(atomVCentConstraints.count-1) {
                            rowView.removeConstraints(atomVCentConstraints[jj])
                        }
                        atomVCentConstraints = []
                    }
                    

                    
                    

                    //self.removeConstraints(self.constraints())
                  
                    
                    
                    
                    //constraintsH = []
                    //atomHeightConstraints = []
                    //atomVCentConstraints = []

                    
                    println("CONSTRAINTS: \(rowView.constraints())")
                    
                    //Generate new constraint
                    constraintsH = NSLayoutConstraint.constraintsWithVisualFormat(constraintString, options: NSLayoutFormatOptions(0), metrics: nil, views: viewDicDic[ii]!)
                    
                    //println("Current constraint string for atoms in this row follows")
                    //println(constraintString)
                    //println("")
                    //Add new constraint
                    rowView.addConstraints(constraintsH)
                    constraintsHIsAdded = 1
                    
                    //constraints for atoms within one row:
                    //Single constraints to keep heights of atoms same as widths
                    println("Number of atoms we have is \(viewDicDic[ii]!.count-2). Trying to get \(scalingData.Nw)")
                    //Create new constraints
                    for jj in 1...scalingData.Nw {
                        atomHeightConstraints.append(NSLayoutConstraint(item: viewDicDic[ii]!["Atom\(jj)"]!, attribute: .Height, relatedBy: .Equal, toItem: viewDicDic[ii]!["Atom\(jj)"]!, attribute: .Width, multiplier: 1.0, constant: 0))
                    }

                    rowView.addConstraints(atomHeightConstraints)
                    atomHeightConstraintsIsAdded = 1
                    
                    //Vertical centering constraints for each atom in the row view
                   

                    //Create new constraints
                    for jj in 1...scalingData.Nw {
                        atomVCentConstraints.append(NSLayoutConstraint.constraintsWithVisualFormat("V:|[Atom\(jj)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewDicDic[ii]!))
                    }
                    //Add all constraints on atoms within rowview
                    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    //CANT WE DO THIS BY JUST ADDING THE WHOLE ARRAY ATOMVCENTCONSTRAINTS ONCE?
                    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
                    for jj in 1...scalingData.Nw {
                        rowView.addConstraints(atomVCentConstraints[jj-1])
                    }
                    atomVCentConstraintsIsAdded = 1
                }
                
                //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                //REMOVE ROW-LEVEL CONSTRAINTS HERE WITH CHECKVARS
                //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                
                
                //CONSTRAINTS BETWEEN ROW VIEWS AND HOLDING SUPERVIEW
                //constraints for row views:
                //Remove exsiting row constraints if they exist
                if rowViewWidthIsAdded != 0 {
                    for jj in 0...(rowHeightConstraints.count-1) {
                        self.removeConstraints(rowHeightConstraints[jj])
                    }
                    rowHeightConstraints = []
                }
                //Loop through views
                println("ROWARRAY COUNT HERE IS: \(rowArray.count)")
                for ii in 0...rowArray.count-1 {

                    //Allow rowview's height can vary up to screensize to ensure fits to atoms
                    //(Atoms have V:|[Atom]|)
                    //DELETED THIS! DONT THINK WE NEED IT ANYMORE:
                    //let rowViewHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=5)-[rowView\(ii+1)(<=screenHeight)]-(>=5)-|", options: NSLayoutFormatOptions(0), metrics: metricDictionary, views: viewsDictionary2)
                    //constraints for row views:
                    //Set width of row views to be equal to desired width of parent view
                    rowHeightConstraints.append(NSLayoutConstraint.constraintsWithVisualFormat("H:|[rowView\(ii+1)(<=screenWidth)]|", options: NSLayoutFormatOptions(0), metrics: metricDictionary, views: viewsDictionaryRows))
                    //Add all constraints on row views
                    //COMMENTED OUT:
                    //self.addConstraints(rowViewHeight)
                    
                }
                for ii in 0...(rowHeightConstraints.count-1) {
                    self.addConstraints(rowHeightConstraints[ii])
                }
                rowViewWidthIsAdded = 1
                
                //constraints for row views:
                //Remove exsiting row constraints if they exist
                if rowConstraintsHIsAdded != 0 {
                    self.removeConstraints(rowConstraintsH)
                    rowConstraintsH = []
                }
                //Generate string of VFL constraints for all row views vertical alignment
                var rowConstraintString = buildRowConstraint(rowArray.count)
                //Add constraint
                rowConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat(rowConstraintString, options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionaryRows)
                self.addConstraints(rowConstraintsH)
                rowConstraintsHIsAdded = 1
             
                //Update old values for numbers of atoms
                oldAtomNumbers.width = Double(scalingData.Nw)
                oldAtomNumbers.height = Double(scalingData.Nh)
            }
        }
    }
*/

    

    //Adds or removes atoms to constraint string for a rowView
    func buildAtomConstraint(numbAtoms:Int) -> String {
        //println("nubAtoms is: \(numbAtoms)")
        var constraintString = "H:|-[spViewLeft(>=0@200)]-[Atom1]"
        //var constraintString = "|-(>=0@200)-[Atom1]"
        for jj in 2...numbAtoms {
            constraintString += "-[Atom\(jj)(==Atom1)]"
        }
        //constraintString += "-(>=0@200)-|"
        constraintString += "-[spViewRight(==spViewLeft)]-|"
    
        return constraintString
    }
    
    func buildRowConstraint(numbRows:Int) -> String {
        //(Use spacer view (spView) to sacrifice top and bottom padding equally)
        var rowConstraintString = "V:|-[spViewTop(>=0@999)]-[rowView1]"
        for ii in 2...numbRows {
            rowConstraintString += "-[rowView\(ii)(==rowView1)]"
        }
        rowConstraintString += "-[spViewBottom(==spViewTop)]-|"
    
        return rowConstraintString
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
 
    
    //Update decays
    
    
}
