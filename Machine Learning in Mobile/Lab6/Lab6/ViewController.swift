//
//  ViewController.swift
//  Lab6
//
//  Created by Dhaval Gogri on 11/10/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//


//Server URL of Tornado and MongoDB
let SERVER_URL = "http://10.8.154.229:8000"

import UIKit
import CoreMotion

class ViewController: UIViewController, URLSessionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    //Variable declaration for session, queue and buffer
    var session = URLSession()
    let operationQueue = OperationQueue()
    var ringBuffer = RingBuffer()
    
    // UI component outlets from Main.Storyboard
    @IBOutlet weak var buttonTakePicture: UIButton!
    @IBOutlet weak var buttonUpload: UIButton!
    @IBOutlet weak var segmentTrainPredict: UISegmentedControl!
    @IBOutlet weak var imageViewRPS: UIImageView!
    @IBOutlet weak var labelPredition: UILabel!
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var pickerFormationType: UIPickerView!
    @IBOutlet weak var buttonUpdateModel: UIButton!
    
    
    //Variable declaration
    let formationType = ["Train for Rock","Train for Paper","Train for Scissor"]
    let dsid:Int = 44
    var selectedRow = "Train for Rock"
    var isImageCaptured = false
    var isImageUploading = false
    var segmentControlOptionSelected = 0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Setting up session, Delegate, setting default values
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        self.session = URLSession(configuration: sessionConfig,
                                  delegate: self,
                                  delegateQueue:self.operationQueue)
        self.pickerFormationType.delegate = self
        self.pickerFormationType.dataSource = self
        self.segmentTrainPredict.selectedSegmentIndex = 0
        self.labelPredition.alpha = 0
        self.pickerFormationType.alpha = 1
        
        
    }
    
    
    
    func sendFeatures(_ array:String, withLabel label:String){
        //Variable to check when image is uploading.
        self.isImageUploading = true
        //Show activity indicator when making network calls
        self.activityIndicatorView.alpha = 1
        
        //Creating a base and post URL
        let baseURL = "\(SERVER_URL)/AddDataPoint"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["feature":array,
                                       "label":"\(label)",
            "dsid":self.dsid]
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        request.httpMethod = "POST"
        request.httpBody = requestBody
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{(data, response, error) in
                                                                    DispatchQueue.main.async {
                                                                        //Goes into if loop if we get error due to network issues
                                                                        if(error != nil){
                                                                            if let res = response{
                                                                                print("Response:\n",res)
                                                                            }
                                                                            self.showAlertBox("Error")
                                                                        }
                                                                        else{
                                                                            //success, we got data from server.
                                                                            //Save the data into the json dictionary which includes
                                                                            //feature and label
                                                                            
                                                                            let jsonDictionary = self.convertDataToDictionary(with: data)
                                                                            if(jsonDictionary.count > 0){
                                                                                print(jsonDictionary["feature"]!)
                                                                                print(jsonDictionary["label"]!)
                                                                                self.showAlertBox("Data uploaded successfully")
                                                                            }
                                                                            else{
                                                                                self.showAlertBox("Server Error")
                                                                            }
                                                                        }
                                                                        //setting the variable to default when uploading finished
                                                                        self.isImageUploading = false
                                                                        self.activityIndicatorView.alpha = 0
                                                                    }
        })
        
        postTask.resume() // start the task
    }
    
    func getPrediction(_ array:String){
        //Show activity indicator when making network calls
        self.activityIndicatorView.alpha = 1
        
        //Creating a base and post URL
        let baseURL = "\(SERVER_URL)/PredictOne"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        //
        let jsonUpload:NSDictionary = ["feature":array, "dsid":self.dsid]
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{(data, response, error) in
                                                                    DispatchQueue.main.async {
                                                                        
                                                                        if(error != nil){
                                                                            if let res = response{
                                                                                print("Response:\n",res)
                                                                            }
                                                                            self.showAlertBox("Error")
                                                                        }
                                                                        else{
                                                                            //Get data from server and store it in dictionary
                                                                            let jsonDictionary = self.convertDataToDictionary(with: data)
                                                                            //If there is some data present, it means success
                                                                            if(jsonDictionary.count > 0){
                                                                                NSLog("Data\nData\nData")
                                                                                NSLog("\(jsonDictionary)")
                                                                                NSLog("Data\nData\nData")
                                                                                // Get the prediction data from the dictionary and convert it
                                                                                // into a utf-8 string format
                                                                                let prediction1Model = (jsonDictionary["prediction1"]! as! String).utf8
                                                                                let prediction2Model = (jsonDictionary["prediction2"]! as! String).utf8
                                                                                print(prediction1Model)
                                                                                print(prediction2Model)
                                                                                //show the prediction to the user
                                                                                self.labelPredition.text = "Prediction is : \(prediction1Model) using KNN and \(prediction2Model) using SVM"

                                                                            }
                                                                            else{
                                                                                self.showAlertBox("Error in getting prediction")
                                                                            }
                                                                        }
                                                                        self.activityIndicatorView.alpha = 0
                                                                        
                                                                    }
                                                                    
        })
        
        postTask.resume() // start the task
    }
    
    
    
    func makeModel() {
        // create a GET request for server to update the ML model with current data
        let baseURL = "\(SERVER_URL)/UpdateModel"
        //send knn parameter to use in the machine learning models from the phone to server
        let query = "?dsid=\(self.dsid)&knn=3"
        
        let getUrl = URL(string: baseURL+query)
        let request: URLRequest = URLRequest(url: getUrl!)
        let dataTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{(data, response, error) in
                                                                    // handle error!
                                                                    if (error != nil) {
                                                                        if let res = response{
                                                                            print("Response:\n",res)
                                                                        }
                                                                        self.showAlertBox("Error")
                                                                    }
                                                                    else{
                                                                        //Get data from server and store it in dictionary
                                                                        let jsonDictionary = self.convertDataToDictionary(with: data)
                                                                        //If there is some data present, it means success
                                                                        if(jsonDictionary.count > 0){
                                                                            //Get accuracy
                                                                            if let resubAcc = jsonDictionary["resubAccuracy"]{
                                                                                print("Resubstitution Accuracy is", resubAcc)
                                                                                self.showAlertBox("Model Updated successfully")
                                                                            }
                                                                        }
                                                                        else{
                                                                            self.showAlertBox("Error in Server")
                                                                        }
                                                                    }
                                                                    
                                                                    
        })
        
        dataTask.resume() // start the task
        
    }
    
    //MARK: JSON Conversion Functions
    func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do { // try to make JSON and deal with errors using do/catch block
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    //Converting the data we get from the server to an NSDictionary
    func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                                 options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            print("json error: \(error.localizedDescription)")
            return NSDictionary() // just return empty
        }
    }
    
    // Taking image from camera button
    @IBAction func takePictureFromCamera(_ sender: UIButton) {
        //Initialize an ImagePickerController which would help in selecting an image using a camera
        let vc = UIImagePickerController()
        // apply delegate, source type and editing
        vc.delegate = self
        vc.sourceType = .camera
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    //Upload the image onto the server
    @IBAction func uploadImage(_ sender: Any) {
        //Checks if the user has selcted image or is any uploading of data going on
        if(isImageCaptured && !isImageUploading){
            let imageData:NSData = self.imageViewRPS.image!.jpegData(compressionQuality: 100)! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            sendFeatures(strBase64, withLabel: selectedRow)
        }
        else{
            //If image not selected show an alert to user to select an image
            if(!isImageCaptured){
                self.showAlertBox("Please select an image")
            }
        }
    }
    
    //Take picture from the camera
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        // If image not present, error and return
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        //If image image present. Apply that into the image view
        isImageCaptured = true;
        self.imageViewRPS.image = image
        //If the prediction tab is ON, then send the image to the server for prediction
        if(isImageCaptured && !isImageUploading && self.segmentTrainPredict.selectedSegmentIndex == 1){
            //Convert the image data into a base64 string before sending it to the server
            let imageData:NSData = self.imageViewRPS.image!.jpegData(compressionQuality: 100)! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            //Get prediction from the server
            self.getPrediction(strBase64)
        }
    }
    
    
    
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return formationType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return formationType[row]
    }
    // picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //save the text of the picker view into a variable which would be used as a label while uploading data
        selectedRow = self.formationType[row] as String
    }
    
    //Used for training and prediction
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        if(isImageUploading){
            sender.selectedSegmentIndex = self.segmentControlOptionSelected
        }
        //If same index selected return
        if(self.segmentControlOptionSelected == sender.selectedSegmentIndex)
        {
            return
        }
        switch sender.selectedSegmentIndex
        {
            //Index 0 == Training
            case 0:
                //Making a few changes in UI depending on the segment selected
                self.labelPredition.alpha = 0
                self.pickerFormationType.alpha = 1
                self.buttonUpload.alpha = 1
                self.buttonUpdateModel.alpha = 1
                self.imageViewRPS.image = UIImage(named:"rock_paper_scissor_2_gray")!
                self.isImageCaptured = false
                self.isImageUploading = false
            //Index 0 == Prediction
            case 1:
                //Making a few changes in UI depending on the segment selected
                self.labelPredition.alpha = 1
                self.labelPredition.text = "Prediction is : "
                self.pickerFormationType.alpha = 0
                self.imageViewRPS.image = UIImage(named:"rock_paper_scissor_2_gray")!
                self.isImageCaptured = false
                self.isImageUploading = false
                self.buttonUpload.alpha = 0
                self.buttonUpdateModel.alpha = 0
            default:
                break
        }
        self.segmentControlOptionSelected = sender.selectedSegmentIndex
    }
    
    
    //Show alert messages wherever necessary
    func showAlertBox(_ message: String?) {
        let alert = UIAlertController(title: "INFORMATION", message: message, preferredStyle: .alert)
        
        // Only when the user presses the 'GOT IT!' button, the game scene is created
        let okButton = UIAlertAction(title: "GOT IT!", style: .default, handler: { action in
            
            alert.dismiss(animated: true)
        })
        
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    //update model after we have uploaded images
    @IBAction func updateModel(_ sender: Any) {
        if(!isImageUploading){
            self.makeModel()
        }
    }
    
    
}





