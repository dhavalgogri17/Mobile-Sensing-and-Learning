//
//  ViewController.swift
//  ExampleRedBearChat
//
//

import UIKit
import Charts



class ViewController: UIViewController {
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var bleShield:BLE = (UIApplication.shared.delegate as! AppDelegate).bleShield
    
    // reference to label displaying device name
    @IBOutlet weak var labelDeviceName: UILabel!

    // reference to spinner , it loads when device is connecting to audrino board via bluetooth
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // reference to label displaying color of the led in the audrino board
    @IBOutlet weak var labelRGBValue: UILabel!
    
    // reference to label displaying the brightness of the led in the audrino board
    @IBOutlet weak var labelIntensityValue: UILabel!
    
    // this switch will tell us wheather to control LED in board from iphone or from peripherals
    @IBOutlet weak var switcherTakePhoneValue: UISwitch!
    
    // reference to slider which adjusts the brightness of the led in the audrino board
    @IBOutlet weak var sliderIntensityValue: UISlider!
    
    // change the color of LED on the audrino board
    @IBOutlet weak var buttonChangeColor: UIButton!
    
    // 0 = red, 1 = green, 2 = blue
    var colorState = 0
    
    // brightness value vs time line graph
    @IBOutlet weak var lineChartViewIntensityData: LineChartView!
    
    // value for chart
    var intensityValues : Array<Int> = Array()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spinner.startAnimating()
        for _ in 0...50{
            intensityValues.append(0)
        }
        
        //LineChart will automatically scale based on the data we feed it. Depending on Min and Max value
        self.lineChartViewIntensityData.autoScaleMinMaxEnabled = true
        
        //Removing the grid lines in the PPG signal view
        self.lineChartViewIntensityData.xAxis.drawGridLinesEnabled = false
        
        // BLE Connect Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onBLEDidConnectNotification),
                                               name: NSNotification.Name(rawValue: kBleConnectNotification),
                                               object: nil)
        
        // BLE Disconnect Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onBLEDidDisconnectNotification),
                                               name: NSNotification.Name(rawValue: kBleDisconnectNotification),
                                               object: nil)
        
        // BLE Recieve Data Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onBLEDidRecieveDataNotification),
                                               name: NSNotification.Name(rawValue: kBleReceivedDataNotification),
                                               object: nil)
        
        
    }
    
    
    // MARK: ====== BLE Delegate Methods ======
    func bleDidUpdateState() {
        
    }
    
    
    
    @objc func onBLEDidConnectNotification(notification:Notification){
        print("Notification arrived that BLE Connected")
        let deviceName = notification.userInfo!["name"] as! String
        
        // set device name in label
        self.labelDeviceName.text = "Device Name : \(deviceName)"
        
        self.spinner.stopAnimating()
    }
    
    
    // NEW  DISCONNECT FUNCTION
    @objc func onBLEDidDisconnectNotification(notification:Notification){
        print("Notification arrived that BLE Disconnected a Peripheral")
    }
    
    
    
    // NEW FUNCTION EXAMPLE: this was written for you to show how to change to a notification based model
    @objc func onBLEDidRecieveDataNotification(notification:Notification){
        
        // get the data from board
        let d = notification.userInfo?["data"] as! Data?
        
        // if data is not null
        if(d != nil){
            
            // decode the data
            var a = String(bytes: d!, encoding: String.Encoding.utf8)
            
            // trim all extra data we got at the end
            a = a?.replacingOccurrences(of: "\0", with: "")
            let s = a
            
            NSLog("String data = \(String(describing: s))")
            
            // we send values from board seperated by space so here we split the string and get individual values
            var arduinoInformation = s?.split(separator: " ")
            
            // set intensity (brightness of LED) value
            labelIntensityValue.text = "Intensity : \(arduinoInformation![0])"
            
            // set color value (color state)
            let colorInfo = Int(arduinoInformation![1])
            colorState = colorInfo!
            
            NSLog("String data = \(String(describing: s))")
            
            // update labels in main thread & color the text to same color that of the LED on board
            DispatchQueue.main.async {
                self.sliderIntensityValue.value = Float(arduinoInformation![0]) ?? 0
                if(self.colorState == 0){
                    self.labelRGBValue.text = "Red Color in LED"
                    self.labelRGBValue.textColor = UIColor.red
                }
                else if(self.colorState == 1){
                    self.labelRGBValue.text = "Green Color in LED"
                    self.labelRGBValue.textColor = UIColor.green
                }
                else{
                    self.labelRGBValue.text = "Blue Color in LED"
                    self.labelRGBValue.textColor = UIColor.blue
                }
                
                
                
                for i in 0...50{
                    if(i < 50){
                        self.intensityValues[i] = self.intensityValues[i + 1]
                    }
                    else{
                        self.intensityValues[i] = Int(self.sliderIntensityValue.value)
                    }
                }
                
                
                let values = (0..<50).map { (i) -> ChartDataEntry in
                    return ChartDataEntry(x: Double(Int(i)), y: Double(self.intensityValues[i] ))
                }
                
                //Set the data to the LineChart
                //Clear previous values
                //Remove circles and text from the line chart
                //notify that the data set has changed,
                //creates another display of the fresh data
                let brightnessData = LineChartDataSet(values: values, label: "Intensity Signal")
                
                // remove unwanted lines from graph
                brightnessData.drawCirclesEnabled = false
                brightnessData.drawValuesEnabled = false
                
                let data = LineChartData(dataSet: brightnessData)
                self.lineChartViewIntensityData.data?.clearValues()
            
                self.lineChartViewIntensityData.data = data
                self.lineChartViewIntensityData.notifyDataSetChanged()
                self.lineChartViewIntensityData.setNeedsDisplay()
                
            }
        }
        
        //self.labelText.text = s
    }
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        // if controlling via phone
        if(switcherTakePhoneValue.isOn){
            let sliderValue = Int(sender.value)
            let d = "\(sliderValue) \(colorState) 1".data(using: String.Encoding.utf8)!
            NSLog("\(sliderValue)  \(d)")
            bleShield.write(d)
        }
        else{
            let sliderValue = Int(sender.value)
            let d = "\(sliderValue) \(colorState) 0".data(using: String.Encoding.utf8)!
            NSLog("\(sliderValue)  \(d)")
            bleShield.write(d)
        }
        
    }
    
    
    
    
    @IBAction func colorChanged(_ sender: UIButton) {
        
        // if controlling via phone
        if(switcherTakePhoneValue.isOn){
            let sliderValue = Int(sliderIntensityValue.value)
            colorState = (colorState + 1) % 3
            let d = "\(sliderValue) \(colorState) 1".data(using: String.Encoding.utf8)!
            NSLog("\(sliderValue)  \(d)")
            bleShield.write(d)
        }
        else{
            let sliderValue = Int(sliderIntensityValue.value)
            let d = "\(sliderValue) \(colorState) 0".data(using: String.Encoding.utf8)!
            NSLog("\(sliderValue)  \(d)")
            bleShield.write(d)
        }
        
    }
    
    
    @IBAction func switcherChangedValue(_ sender: UISwitch) {
        
        // if controlling via phone
        if(sender.isOn){
            sliderIntensityValue.isEnabled = true
            buttonChangeColor.isEnabled = true
            let sliderValue = Int(sliderIntensityValue.value)
            let d = "\(sliderValue) \(colorState) 1".data(using: String.Encoding.utf8)!
            NSLog("\(sliderValue)  \(d)")
            //labelIntensityValue.text = "Intensity : \(sliderValue)"
            bleShield.write(d)
        }
        else{
            sliderIntensityValue.isEnabled = false
            buttonChangeColor.isEnabled = false
            let sliderValue = Int(sliderIntensityValue.value)
            let d = "\(sliderValue) \(colorState) 0".data(using: String.Encoding.utf8)!
            NSLog("\(sliderValue)  \(d)")
            bleShield.write(d)
        }
    }
    
    
    
}








