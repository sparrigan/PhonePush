//
//  atomCVLayout.swift
//  TestUICollectionView
//
//  Created by Nicholas Harrigan on 22/05/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

class atomCVLayout: UICollectionViewFlowLayout {
    
    var lastCVHeight:CGFloat = CGFloat(0.0)
    var lastCVWidth:CGFloat = CGFloat(0.0)
    var NwMain:Int = 0
    var NhMain:Int = 0
    var rScaleMain:Double = 0.0
    var widthGapMain:Double = 0.0
    var heightGapMain:Double = 0.0
    var atomSize:CGSize = CGSizeMake(0,0)
    var itemValsDic = [Int: [Int: CGRect]]()
    var keyForSize = 0
    var numAtoms = 0
    var Rmain = 0.2
    
    convenience init(atomSize:CGSize, numAtoms:Int) {
        self.init()
        //Get passed size of atoms that will be used in this layout
        //and number of atoms to construct the layout for
        self.atomSize = atomSize
        self.numAtoms = numAtoms
    }
    override init() {
        super.init()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //This is called only once by UICV before layout is undertaken - do intensive calcs here
    override func prepareLayout() {

        //Check whether size of UICV calling the layout has changed before going any further
        if (self.collectionView!.frame.height != lastCVHeight || self.collectionView!.frame.width != lastCVWidth) {
        
            //Hash current width and height of collectionView to use as key in dictionary
            keyForSize = hashSize(self.collectionView!.frame.width, b: self.collectionView!.frame.height)
            
            //Check whether need to generate a new entry for current has key in dictionary
            //If entry exists then carry on without re-calculating
            if itemValsDic[keyForSize] == nil {
                
                //DO WE NEED THIS?
                //Make empty dictionary for this size
                itemValsDic[keyForSize] = [Int:CGRect]()
                
                //Calculate new parameter values with calcNums function
                (NwMain, NhMain, rScaleMain, widthGapMain, heightGapMain) = calcNums(Double(self.collectionView!.frame.width), H: Double(self.collectionView!.frame.height), ha: Double(atomSize.height), wa: Double(atomSize.width), R: Rmain, Natoms: numAtoms)
    
                //Get atom width and height from calcNums values
                var width = CGFloat(rScaleMain)*atomSize.width
                var height = CGFloat(rScaleMain)*atomSize.height
                
                //Check wheter will need to center last row & do necessary prelim calcs
                var centerOffset:CGFloat = 0
                var numOnFinalRow = CGFloat(numAtoms - (NhMain-1)*NwMain)
                if  Int(numOnFinalRow) < NwMain {
                    centerOffset = 0.5*(self.collectionView!.frame.width-(numOnFinalRow*width+(numOnFinalRow-1)*CGFloat(Rmain)*width))-0.5*CGFloat(widthGapMain)
                }
                
                //Loop over all cells and store calculated values of x,y,w and h in dictionary
                for ii in 0...numAtoms-1 {
                    //Get row index for current cell
                    var rowIndex:Int = ii/NwMain
                    //Get column index for current cell. Starts at 0.
                    var colIndex:Int = ii%NwMain
                    //Need to split up expression for new coordinates into terms because of bug(!)
                    var T1 = (widthGapMain/2)
                    var T2 = Double(colIndex)*Double(atomSize.width)*rScaleMain
                    var xVal = CGFloat(T1 + T2*(1+Rmain))
        
                    var T3 = (heightGapMain/2)
                    var T4 = Double(rowIndex)*Double(atomSize.height)*rScaleMain
                    var yVal = CGFloat(T3 + T4*(1+Rmain))
                    
                    //If we are on the bottom row then center cells
                    if (rowIndex == NhMain-1)  {
                        xVal += centerOffset
                        
                    }
                    
                    //Store finalised values for this cell in the dictionary
                    self.itemValsDic[keyForSize]![ii] = CGRectMake(xVal,yVal,width,height)
                }

            }
        
        }
        
    }


    
    //Called by UICollectionView when it needs to update a whole rectangular area of cells
    override func layoutAttributesForElementsInRect(rect: CGRect) ->
        [AnyObject] {
            
            //No matter what rect UICV requests, re-layout all cells as will always
            //need to recalculate all sizes and positions
            var allAttributesInRect = super.layoutAttributesForElementsInRect(CGRectInfinite)

            //Loop through and modify the attributes of all cells in this rect
            for cellAttributes in allAttributesInRect! {
                //Set frame of cell attribute to relevant calculated values from dictionary
                (cellAttributes as! UICollectionViewLayoutAttributes).frame = itemValsDic[keyForSize]![cellAttributes.indexPath!.row]!
            }
            
            //Return array of modified attributes for all cells in this rectangle
            return allAttributesInRect!
    }
 
    
    //Called by UICollectionView when it wants to update a specific cell by index
    override func layoutAttributesForItemAtIndexPath(indexPath:
        NSIndexPath) -> UICollectionViewLayoutAttributes {
            
            //Get UICollectionViewLayoutAttributes of current cell
            var attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            //Set frame of cell attribute to relevant calculated values from dictionary
            attributes.frame = itemValsDic[keyForSize]![indexPath.row]!
            
            //Return the modified attributes
            return attributes
    }
    
    
    //Calculates the number of atoms wide and high to use for current size, and scale factor
    func calcNums(W: Double, H: Double, ha: Double, wa: Double, R: Double, Natoms:Int) -> (Nw: Int, Nh: Int, rscale: Double, widthGap: Double, heightGap: Double) {
        
        //Update last values for width and height of collectionView since we have a new set
        lastCVWidth = self.collectionViewContentSize().width
        lastCVHeight = self.collectionViewContentSize().height
        
        //Terms needed for solving quadratic equation for rscale
        var T1 = R*(H*wa+W*ha)
        var T2 = pow(R,2.0)*pow(H*wa+W*ha,2.0)
        var T3 = 4*ha*wa*(Double(Natoms)*pow(R+1,2.0)-pow(R,2.0))*W*H
        var T4 = 2*ha*wa*(Double(Natoms)*pow(R+1,2.0)-pow(R,2.0))
        //First attempt at calculating rscale
        var rscale = (T1 + pow(T2+T3,0.5))/T4
        //Find Number of atoms based on this rscale value
        var Nw = Double(Natoms)*rscale*ha*(R+1)/(H+rscale*R*ha)
        var Nh = Double(Natoms)/Nw

        //Round values
        Nw = round(Nw)
        Nh = round(Nh)
        //If we are now less than 100 atoms, then add another row on bottom that will store
        //the stragglers that make up to 100
        if Int(Nw*Nh) < Natoms { ++Nh }
        
        //Find total width and height of view made from atoms with calculated parameters
        //Note use Nw-1 and Nh-1 since we want flush to edges so only need N-1 spacings
        var totalWidth = (Nw-1)*R*rscale*wa + Nw*rscale*wa
        var totalHeight = (Nh-1)*R*rscale*ha + Nh*rscale*ha
  
        //Check whether our rounding has made us overshoot
        if (totalWidth > W || totalHeight > H) {
            //Find which dimension has biggest difference and set rscale to fit that dimension
            if (totalWidth-W) != (totalHeight-H) {
                if max(totalWidth-W,totalHeight-H) == totalWidth-W {
                    rscale = W/((Nw-1)*R*wa+Nw*wa)
                } else {
                    rscale = H/((Nh-1)*R*ha+Nh*ha)
                }
            } else {
                //Both are the same, could use either: just use totalWidth
                rscale = W/((Nw-1)*R*wa+Nw*wa)
            }
        }

        //Recalculate totals with new rscale
        totalHeight = (Nh-1)*R*rscale*ha + Nh*rscale*ha
        totalWidth = (Nw-1)*R*rscale*wa + Nw*rscale*wa
        //Calculate how much space is left for above/below & left/right, and pass this back too
        var heightGap = round(H - totalHeight)
        var widthGap = round(W - totalWidth)
        //Ensuring floating point errors don't give -ve values (eg: -0.0)
        if heightGap<=0 {heightGap = 0}
        if widthGap<=0 {widthGap = 0}
        
        
        //Nw: Atoms wide. Nh: Atoms high. rscale: scale factor for atoms AND spacing.
        //width/heightgap: remaining view space around grid when made with these parameters
        return(Int(Nw), Int(Nh), rscale, widthGap, heightGap)
    }
    
    //Worlds crappest hash function - for generating a dictionary key from a screen size
    func hashSize(a:CGFloat,b:CGFloat) -> Int {
        return ("\(Int(a))"+"\(Int(b))").toInt()!
    }
    

}




