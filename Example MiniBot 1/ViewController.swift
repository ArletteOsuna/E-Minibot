//
//  ViewController.swift
//  MiniBot 1
//
//  Created by Arlette Osuna on 20/3/24.

import UIKit

/*
 * Main class.
 */
class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, MiniBotBLEConnectDelegate {
    
    // Bluetooth controller declaration.
    var miniBotBleConnect:MiniBotBLEConnect!


    // 'pickerSelectorRobot' outlet connection.
    @IBOutlet weak var pickerSelectorRobot: UIPickerView!
    
    let elementsPicker = ["Bot 1", "Bot 2", "Bot 3", "Bot 4", "Bot 5", "Bot 6", "Bot 7", "Bot 8", "Bot 9", "Bot 10", "Bot 11", "Bot 12" ]

    // Control buttons outlet connection.
    @IBOutlet weak var buttonFWL: UIButton!
    @IBOutlet weak var buttonBWL: UIButton!
    @IBOutlet weak var buttonFWR: UIButton!
    @IBOutlet weak var buttonBWR: UIButton!
        
    // 'buttonConnect' outlet connection.
    @IBOutlet weak var buttonConnect: UIButton!
    // 'buttonDarkLight' outlet connection.
    @IBOutlet weak var buttonDarkLight: UIButton!
    // 'batteryLevel' outlet connection.
    @IBOutlet weak var batteryLevel: UILabel!
    // 'sliderSpeed' outlet connection.
    @IBOutlet weak var sliderSpeed: UISlider!
    
    
    // Constraints outlet connection.
    @IBOutlet weak var constraintConnectTop: NSLayoutConstraint!
    @IBOutlet weak var constraintControlsBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintSliderBottom: NSLayoutConstraint!
    
    
    // Robot selected.
    var bot_selected:Int = 10
    
    // Store the dark-loght state (Light = true)
    var state_dark_light = true
    
    
    
    /*
     * Initializations and tasks to be done before the user starts using it.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check whether you are in Dark or Light mode.
        if UITraitCollection.current.userInterfaceStyle == .dark {
            state_dark_light = false
        } else {
            state_dark_light = true
        }
        
        //Rotate the slider 90 degrees so that it is displayed vertically.
        sliderSpeed.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        
        // Disables user interaction of the slider while waiting for the
        // rest of the initializations.
        sliderSpeed.isUserInteractionEnabled = false
        
        buttonConnect.tintColor = UIColor.init(red: 0.7, green: 0, blue: 0, alpha: 1)
        buttonConnect.setTitle("Connect to", for: .normal)
        
        // Set the delegate for the picker element.
        pickerSelectorRobot.delegate = self
        
        // Define parameters.
        let color_border = UIColor.lightGray.cgColor
        let border_width: CGFloat = 2
        
        // Modify the appearance of the 'buttonConnect' button.
        buttonConnect.layer.cornerRadius = 8
        buttonConnect.layer.borderWidth = border_width
        buttonConnect.layer.borderColor = color_border
        buttonConnect.layer.masksToBounds = true
        
        // Modify the appearance of the'buttonFWL' button.
        buttonFWL.layer.cornerRadius = 10
        buttonFWL.layer.borderWidth = border_width
        buttonFWL.layer.borderColor = color_border
        buttonFWL.layer.masksToBounds = true
        buttonFWL.isUserInteractionEnabled = false
        
        // Modify the appearance of the 'buttonBWL' button.
        buttonBWL.layer.cornerRadius = 10
        buttonBWL.layer.borderWidth = border_width
        buttonBWL.layer.borderColor = color_border
        buttonBWL.layer.masksToBounds = true
        buttonBWL.isUserInteractionEnabled = false
        
        // Modify the appearance of the 'buttonFWR' button.
        buttonFWR.layer.cornerRadius = 10
        buttonFWR.layer.borderWidth = border_width
        buttonFWR.layer.borderColor = color_border
        buttonFWR.layer.masksToBounds = true
        buttonFWR.isUserInteractionEnabled = false
        
        // Modify the appearance of the 'buttonBWR' button.
        buttonBWR.layer.cornerRadius = 10
        buttonBWR.layer.borderWidth = border_width
        buttonBWR.layer.borderColor = color_border
        buttonBWR.layer.masksToBounds = true
        buttonBWR.isUserInteractionEnabled = false
        
        // Gets the selected robot from the last session with the app.
        bot_selected = UserDefaults.standard.integer(forKey: "BOT_SELECTED")
        if bot_selected < 0 {
            bot_selected = 1
            UserDefaults.standard.setValue(bot_selected, forKey: "BOT_SELECTED")
        }
        
        // Sets the selection of the last robot in the picker element.
        pickerSelectorRobot.selectRow(self.bot_selected - 1, inComponent: 0, animated: true)
        
        // Gets the height of the screen to then set the constraints according to
        // the iPhone model.
        let height = UIScreen.main.nativeBounds.height
        
        print("Screen size -> height = \(height)")
        
        // Screen resolutions according to model.
        // iPhone 12/13/14/15 Pro Max/Plus  -> 1290 × 2796 pixels.
        // iPhone 12/13/14/15 Pro -> 1179 × 2556 pixels.
        // iPhone 6/7/8 Plus -> 1242.0 × 2208.0
        // iPhone SE -> 750 × 1334 pixels.
        // Ajust de les constraints.
        if height < 1400 { // SE
            constraintConnectTop.constant = 20
            constraintControlsBottom.constant = 20
            constraintSliderBottom.constant = 140
            print("MODEL SE")
        } else if height < 2300 && height > 1400 { // Plus
            constraintConnectTop.constant = 30
            constraintControlsBottom.constant = 60
            constraintSliderBottom.constant = 180
            print("MODEL PLUS")
        } else if height < 2700 && height > 1400 { // Pro
            constraintConnectTop.constant = 50
            constraintControlsBottom.constant = 80
            constraintSliderBottom.constant = 200
            print("MODEL PRO")
        } else if height > 2700 { // Pro Max
            constraintConnectTop.constant = 80
            constraintControlsBottom.constant = 100
            constraintSliderBottom.constant = 220
            print("MODEL PRO MAX")
        } else { // Others
            print("MODEL ?????")
        }

        // Initializes the Bluetooth controller.
        miniBotBleConnect =  MiniBotBLEConnect(bot: bot_selected)
        miniBotBleConnect.delegate = self
        miniBotBleConnect.connectServer()
    } // end of 'viewDidLoad' function block.

    
    
    /*
     * Action of the light-dark mode button which changes the appearance of the app.
     */
    @IBAction func actionButtonDarkLight(_ sender: Any) {
        if state_dark_light {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
        state_dark_light = !state_dark_light
    }
    
    
    
    // ****************************************************
    // ****************** Button actions ******************
    // ****************************************************

    /*
     * Send command both motors.
     * dir_l: 0 forward rotation left, 1 backward rotation left.
     * dir_r: 0 forward rotation right, 1 backward rotation right.
     * power_l: motor power left (0 to 100).
     * power_r: motor power right(0 to 100).
     */
    var dir_l = 0       // left
    var dir_r = 0       // right
    var power_l = 0     // left
    var power_r = 0     // right

    // ***** Left buttons *****
    
    /*
     * Action that is triggered when the Left-Fordware button
     * is pressed. (Touch-Down-event).
     */
    @IBAction func actionButtonLeftDown_F(_ sender: Any) {
        dir_l = 0       // Fordward left.
        power_l = 100   // Power 100% to motor left.
        sendMotorCommand()
        print("Fordward left Down")
    }
    
    
    /*
     * Action that is triggered when the Left-Fordware button
     * is released. (Touch-Up-Inside event).
     */
    @IBAction func actionButtonLeftUp_F(_ sender: Any) {
        dir_l = 0       // Fordward left.
        power_l = 0     // Power 0% (stop) to motor left.
        sendMotorCommand()
        print("Fordward left Up")
    }

    /*
     * Action that is triggered when the Left-Backware button
     * is pressed. (Touch-Down-event).
     * Ex: actionButtonLeftDown_B
     */
    
    @IBAction func actionButtonLeftDown_B(_ sender: Any) {
        dir_l = 1       // Backward rotation left.
           power_l = 100   // Power 100% to motor left.
           sendMotorCommand()
           print("Backward left Down")
       }
        
    
    /*
     * Action that is triggered when the Left-Backware button
     * is released. (Touch-Up-Inside event).
     *
     * Ex: actionButtonLeftUp_B
     */
 
    
    @IBAction func actionButtonLeftUp_B(_ sender: Any) {
        dir_l = 1       // Backward left.
        power_l = 0     // Power 0% (stop) to motor left.
        sendMotorCommand()
        print("Backward left Up")
    }
    
    
    
    // ***** Right buttons *****
    
    /*
     * Action that is triggered when the Right-Fordware button
     * is pressed. (Touch-Down event).
     *
     * Ex: actionButtonRightDown_F
     */

    @IBAction func actionButtonRightDown_F(_ sender: Any) {
        dir_r = 0       // forward right.
        power_r = 100   // Power 100% to motor right.
        sendMotorCommand()
        print("Forward right Down")
    }
    
    
    
    /*
     * Action that is triggered when the Right-Fordware button
     * is released. (Touch-Up-Inside event).
     *
     * Ex: actionButtonRightUp_F
     */
    
    @IBAction func actionButtonRightUp_F(_ sender: Any) {
        dir_r = 0       // Fordward Right.
        power_r = 0     // Power 0% (stop) to motor right.
        sendMotorCommand()
        print("Fordward Right Up")
    }
    
    
    /*
     * Action that is triggered when the Right-Backware button
     * is pressed. (Touch-Down-event).
     *
     * actionButtonRightDown_B
     */

    
    @IBAction func actionButtonRightDown(_ sender: Any) {
        dir_r = 1       // Backward right.
        power_r = 100   // Power 100% to motor right.
        sendMotorCommand()
        print("Backward right Down")
}
    
    /*
     * Action that is triggered when the Right-Backware button
     * is released. (Touch-Up-Inside event).
     *
     * actionButtonRightUp_B
     */
    
    
    @IBAction func actionButtonRightUp_B(_ sender: Any) {
        dir_r = 1       // Backward right.
        power_r = 0     // Power 0% (stop) to motor right.
        sendMotorCommand()
        print("Backward right Up")
    }
        
    //speed for the actionSlider
    
    var speed_l: Float = 0.0
    var speed_r: Float = 0.0
    
    
    @IBAction func actionSlider(_ sender: UISlider) {
        let value = sender.value // Get the current value
        // Adjust speed_l and speed_r based on the slider value
            speed_l = value
            speed_r = value
            sendMotorCommand()
            print("Speed change")
        }
          
    // ****************************************************
    // ****************************************************
    // ****************************************************

        
    // ****************************************************
    // *************** Additional functions ***************
    // ****************************************************

    
    /*
     * Delegated function (method) of the MiniBotBLEConnect class that notifies of
     * a state change in the bluetooth connection. We use it to enable or disable the
     * control buttons of the robot when there is no bluetooth connection with it.
     * It also enables or disables the robot selection picker so that a robot can only
     * be selected when there is no bluetooth connection to any of them.
     */
    func connectionStatus(connected: Bool) {
        print("ViewController.connectionStatus --> status = \(connected)")
        DispatchQueue.main.async {
            if connected {
                self.pickerSelectorRobot.isUserInteractionEnabled = false
                self.pickerSelectorRobot.selectRow(self.bot_selected - 1, inComponent: 0, animated: true)
                
                self.buttonFWL.isUserInteractionEnabled = true
                self.buttonBWL.isUserInteractionEnabled = true
                self.buttonFWR.isUserInteractionEnabled = true
                self.buttonBWR.isUserInteractionEnabled = true
                self.sliderSpeed.isUserInteractionEnabled = true

                self.buttonConnect.tintColor = UIColor.init(red: 0, green: 0.7, blue: 0, alpha: 1)
                self.buttonConnect.setTitle("Connected", for: .normal)
            } else {
                self.pickerSelectorRobot.isUserInteractionEnabled = true

                self.buttonFWL.isUserInteractionEnabled = false
                self.buttonBWL.isUserInteractionEnabled = false
                self.buttonFWR.isUserInteractionEnabled = false
                self.buttonBWR.isUserInteractionEnabled = false
                self.sliderSpeed.isUserInteractionEnabled = false

                self.buttonConnect.tintColor = UIColor.init(red: 0.7, green: 0, blue: 0, alpha: 1)
                self.buttonConnect.setTitle("Disconnected", for: .normal)
            }
        }
    }
    
    
    
    
    /*
     * Delegated function (method) of the MiniBotBLEConnect class that notifies us
     * of the battery charge level. Through this function we update the battery
     * charge indicator ('batteryLevel' element).
     */
    func batteryLevel(level: Int) {
        print("ViewController.batteryLevel --> Robot battery = \(level)%")
        DispatchQueue.main.async {
            self.batteryLevel.text = "Robot battery: \(level)%"
        }
    }
    

    
    /*
     * Picker element configuration function.
     *
     * Tells the picker how many columns
     * to display. In this case only one.
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /*
     * Picker element configuration function.
     *
     * Tells the picker how many items
     * in each column to display. In this case there are 13 items. We use the
     * count function to obtain the number of elements (13 in this case) of the
     * 'elementsPicker' array that stores the texts to be displayed in the picker.
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return elementsPicker.count
    }

    /*
     * Picker element configuration function.
     *
     * This function is used by the picker
     * to obtain what should be shown in each position. The picker iterates the 'row'
     * variable (0, 1, 2, ... 11, 12) in order to select the texts to display stored
     * in the 'elementsPicker' array.
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return elementsPicker[row]
    }
    

    
    // ****************************************************
    // ************** Bluetooth button action *************
    // ****************************************************

    /*
     * Action that connect and disconnect bluetooth from the robot.
     */
    @IBAction func actionButtonConnect(_ sender: Any) {
        if !miniBotBleConnect.connected {
            bot_selected = pickerSelectorRobot.selectedRow(inComponent: 0) + 1
            UserDefaults.standard.setValue(bot_selected, forKey: "BOT_SELECTED")
            miniBotBleConnect.selectBot(bot: bot_selected)
            miniBotBleConnect.connectServer()
        } else {
            miniBotBleConnect.disconnectServer()
        }
    }
    
    
    
    
    // ****************************************************
    // **************** Motor control functions ***********
    // ****************************************************
    
    /*
     * Send command to motors.
     */
    func sendMotorCommand() {
        // Example of command.
        // CC+D+PPP+D+PPP -> 0101501080 -> 01 1 050 0 080
        // CC: 01 -> command type (motor control command).
        // D: 1 -> backward rotation.
        // PPP: 050 -> power 50%.
        
       
    
        var str_comm:String = "01"
            
        // Check 'dir' value [0 <= dir <= 1].
        var dr_l = dir_l
        if dr_l < 0 {
        dr_l = 0
            print("Error in sendMotorCommand: 'dir' value < 0")
        } else if dr_l > 1 {
            dr_l = 1
            print("Error in sendMotorCommand: 'dir' value > 1")
        }
        
        // Check 'dir_r' value [0 <= dir <= 1].
        var dr_r = dir_r
        if dr_r < 0 {
        dr_r = 0
            print("Error in sendMotorCommand: 'dir' value < 0")
        } else if dr_r > 1 {
            dr_r = 1
            print("Error in sendMotorCommand: 'dir' value > 1")
        }
        
        // Check 'power_l' value [0 <= power <= 100].
        var pwr_l = power_l
        if pwr_l < 0 {
            pwr_l = 0
            print("Error in sendMotorCommand: 'power' value < 0")
        } else if pwr_l > 100 {
            pwr_l = 100
            print("Error in sendMotorCommand: 'power' value > 100")
        }
        
        // Check 'power_r' value [0 <= power <= 100].
        var pwr_r = power_r
        if pwr_r < 0 {
            pwr_r = 0
            print("Error in sendMotorCommand: 'power' value < 0")
        } else if pwr_r > 100 {
            pwr_r = 100
            print("Error in sendMotorCommand: 'power' value > 100")
        }
        
        
        // Appending dir_l to the command string.
        str_comm = str_comm + String(dr_l)
        
        // Appending power_l to the command string.
        if (pwr_l < 100) && (pwr_l > 10) {
            // Appending an extra '0' to keep the total number of characters.
            str_comm = str_comm + "0" + String(pwr_l)
        } else if (pwr_l < 10) {
            // Appending an extra '00' to keep the total number of characters.
            str_comm = str_comm + "00" + String(pwr_l)
        } else {
            str_comm = str_comm + String(pwr_l)
        }

        // Appending dir_r to the command string.
        str_comm = str_comm + String(dr_r)

        // Appending power_r to the command string.
        if (pwr_r < 100) && (pwr_r > 10) {
            // Appending an extra '0' to keep the total number of characters.
            str_comm = str_comm + "0" + String(pwr_r)
        } else if (pwr_r < 10) {
            // Appending an extra '00' to keep the total number of characters.
            str_comm = str_comm + "00" + String(pwr_r)
        } else {
            str_comm = str_comm + String(pwr_r)
        }


        // Check if BLE connection is alive before sending.
        if miniBotBleConnect.connected {
            // Sending command.
            miniBotBleConnect.send(str: str_comm)
            print("Sending command: \(str_comm)")
        } else {
            print("Error in sendMotorCommand: bluetooth not connected !!")
        }
    } // End 'sendMotorCommand' function block.
    
} // End 'ViewController' class block.


