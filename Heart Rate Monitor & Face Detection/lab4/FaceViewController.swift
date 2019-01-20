//
//  FaceViewController.swift
//  lab4
//
//  Created by Dhaval Gogri on 10/9/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

import UIKit
import Foundation

class FaceViewController: UIViewController {

    var filters : [CIFilter]! = nil
    var videoManager:VideoAnalgesic! = nil
    let pinchFilterIndex = 2
    var detector:CIDetector! = nil
    var toggleEnabled = true;
    let bridge = OpenCVBridge()
    
    //MARK: Outlets in view
    
    
    @IBOutlet weak var flashSlider: UISlider!
    @IBOutlet weak var stageLabel: UILabel!
    @IBOutlet weak var buttonToggleFlash: UIButton!
    @IBOutlet weak var buttonToggleCamera: UIButton!
    
    
    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        self.setupFilters()
        
        self.bridge.loadHaarCascade(withFilename: "nose")
        
        self.videoManager = VideoAnalgesic.sharedInstance
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.front)
        
        // create dictionary for face detection
        // HINT: you need to manipulate these proerties for better face detection efficiency
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow,CIDetectorTracking:true] as [String : Any]
        
        // setup a face detector in swift
        self.detector = CIDetector(ofType: CIDetectorTypeFace,
                                   context: self.videoManager.getCIContext(), // perform on the GPU is possible
            options: (optsDetector as [String : AnyObject]))
        
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        
    }
    
    //MARK: Process image output
    func processImage(inputImage:CIImage) -> CIImage{
        
        // detect faces
        //        let f = getFaces(img: inputImage)
        
        // if no faces, just return original image
        //        if f.count == 0 { return inputImage }
        
        var retImage = inputImage
        
        // if you just want to process on separate queue use this code
        // this is a NON BLOCKING CALL, but any changes to the image in OpenCV cannot be displayed real time
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
        //            self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
        //            self.bridge.processImage()
        //        }
        
        // use this code if you are using OpenCV and want to overwrite the displayed image via OpenCv
        // this is a BLOCKING CALL
        self.bridge.setTransforms(self.videoManager.transform)
        self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
        self.bridge.processImage()
        retImage = self.bridge.getImage()
        
        //HINT: you can also send in the bounds of the face to ONLY process the face in OpenCV
        // or any bounds to only process a certain bounding region in OpenCV
        //        self.bridge.setTransforms(self.videoManager.transform)
        //        self.bridge.setImage(retImage,
        //                             withBounds: f[0].bounds, // the first face bounds
        //                             andContext: self.videoManager.getCIContext())
        
        self.bridge.processImage()
        retImage = self.bridge.getImageComposite() // get back opencv processed part of the image (overlayed on original)
        if(self.bridge.isfingerDetected()){
            self.videoManager.turnOnFlashwithLevel(1.0);
            toggleEnabled = false;
            DispatchQueue.main.async {
                self.buttonToggleCamera.alpha = 0
                self.buttonToggleFlash.alpha = 0
            }
            
            //            self.buttonToggleCamera.isEnabled = false
            //            self.buttonToggleFlash.isEnabled = false
        }
        else{
            if(!toggleEnabled){
                self.videoManager.turnOffFlash();
                toggleEnabled = true;
                DispatchQueue.main.async {
                    self.buttonToggleCamera.alpha = 1
                    self.buttonToggleFlash.alpha = 1
                }
                //                self.buttonToggleCamera.isEnabled = true
                //                self.buttonToggleFlash.isEnabled = true
            }
        }
        
        return retImage
    }
    
    //MARK: Setup filtering
    func setupFilters(){
        filters = []
        
        let filterPinch = CIFilter(name:"CIBumpDistortion")!
        filterPinch.setValue(-0.5, forKey: "inputScale")
        filterPinch.setValue(75, forKey: "inputRadius")
        filters.append(filterPinch)
        
    }
    
    //MARK: Apply filters and apply feature detectors
    func applyFiltersToFaces(inputImage:CIImage,features:[CIFaceFeature])->CIImage{
        var retImage = inputImage
        var filterCenter = CGPoint()
        
        for f in features {
            //set where to apply filter
            filterCenter.x = f.bounds.midX
            filterCenter.y = f.bounds.midY
            
            //do for each filter (assumes all filters have property, "inputCenter")
            for filt in filters{
                filt.setValue(retImage, forKey: kCIInputImageKey)
                filt.setValue(CIVector(cgPoint: filterCenter), forKey: "inputCenter")
                // could also manipualte the radius of the filter based on face size!
                retImage = filt.outputImage!
            }
        }
        return retImage
    }
    
    func getFaces(img:CIImage) -> [CIFaceFeature]{
        // this ungodly mess makes sure the image is the correct orientation
        //let optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.sharedApplication().statusBarOrientation)]
        let optsFace = [CIDetectorImageOrientation:self.videoManager.ciOrientation]
        // get Face Features
        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
        
    }
    
    
    
    @IBAction func swipeRecognized(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.left:
            self.bridge.processType += 1
        case UISwipeGestureRecognizer.Direction.right:
            self.bridge.processType -= 1
        default:
            break
            
        }
        
        stageLabel.text = "Stage: \(self.bridge.processType)"
        
    }
    
    //MARK: Convenience Methods for UI Flash and Camera Toggle
    @IBAction func flash(_ sender: AnyObject) {
        self.videoManager.toggleFlash()
        //        if(toggleEnabled){
        //            if(self.videoManager.toggleFlash()){
        //                self.flashSlider.value = 1.0
        //            }
        //            else{
        //                self.flashSlider.value = 0.0
        //            }
        //        }
    }
    
    @IBAction func switchCamera(_ sender: AnyObject) {
        //if(toggleEnabled){
        self.videoManager.toggleCameraPosition()
        //}
    }
    
    @IBAction func setFlashLevel(sender: UISlider) {
        if(sender.value>0.0){
            self.videoManager.turnOnFlashwithLevel(sender.value)
        }
        else if(sender.value==0.0){
            self.videoManager.turnOffFlash()
        }
    }
    

    

}
