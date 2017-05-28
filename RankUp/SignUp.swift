//
//  SignUp.swift
//  RankUp
//
//  Created by Omar Droubi on 12/29/16.
//  Copyright © 2016 Omar Droubi. All rights reserved.
//

////////////////////////////////////////////
// This class is used in the sign up page //
////////////////////////////////////////////

import UIKit
import Firebase
import FirebaseDatabase



class SignUp: UIViewController, UITextFieldDelegate {

    // Add to Database when done
    var eventRef = FIRDatabase.database().reference().child("Users")
    ////////////////////////
    
    // Read from Database
    var eventRefRead: FIRDatabaseReference!
    var listOfUsers: [(String, String)] = []
    /////////////////////////////////////////
    
    
    var nameGiven: String = ""
    
    var idGiven: String = ""

    var workGiven: String = ""
    
    @IBOutlet var displayPicture: UIImageView! //display picture
    
    @IBOutlet var name: UITextField! // edit given name by FB
    
    @IBOutlet var work: UITextField! // edit given work by FB
    
    @IBOutlet var newUsername: UITextField! // new username text
    
    @IBOutlet var newPassword: UITextField! // new password text
    
    @IBOutlet var newPasswordCheck: UITextField! // check new password text
    
    override func viewDidAppear(_ animated: Bool) {
        //Alert about correct work/email
        let alert = UIAlertController(title: "Check if Work/School Name is correct", message: "Make sure that your work or school name is written exactly like on Facebook", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBOutlet var tempImageView: UIImageView!
    // First Method Called
    override func viewDidLoad() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        //Depending on your image, it might look better to use UIBlurEffect(style: UIBlurEffectStyle.ExtraLight) or UIBlurEffect(style: UIBlurEffectStyle.Dark).
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = tempImageView.bounds
        
        tempImageView.addSubview(blurView)

        // Edit the placeholders in the textfield (Color + Keyboard Next)
        let placeholder1 = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName:UIColor.white])
        
        let placeholder2 = NSAttributedString(string: "Work/School", attributes: [NSForegroundColorAttributeName:UIColor.white])

        let placeholder3 = NSAttributedString(string: "New Username", attributes: [NSForegroundColorAttributeName:UIColor.white])

        let placeholder4 = NSAttributedString(string: "New Password", attributes: [NSForegroundColorAttributeName:UIColor.white])

        let placeholder5 = NSAttributedString(string: "Enter Password again", attributes: [NSForegroundColorAttributeName:UIColor.white])

        name.attributedPlaceholder = placeholder1
        work.attributedPlaceholder = placeholder2
        newUsername.attributedPlaceholder = placeholder3
        newPassword.attributedPlaceholder = placeholder4
        newPasswordCheck.attributedPlaceholder = placeholder5
        
        name.delegate = self
        name.tag = 0 //Increment accordingly
        
        work.delegate = self
        work.tag = 1

        newUsername.delegate = self
        newUsername.tag = 2

        newPassword.delegate = self
        newPassword.tag = 3

        newPasswordCheck.delegate = self
        newPasswordCheck.tag = 4

        name.text = nameGiven
        
        work.text = workGiven
        
        print("Name Given: " + nameGiven)
        print("ID Given: " + idGiven)
        print("Work Given: " + workGiven)
        
        // Show Facebook Image
        displayPicture.downloadedFrom(link: "https://graph.facebook.com/" + self.idGiven + "/picture?type=large")
        displayPicture.setRounded()

        // Read DATABASE
        eventRefRead = FIRDatabase.database().reference()
        eventRefRead.child("Users").queryOrderedByKey().observe(.childAdded, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as? NSDictionary
            let username = snapshotValue!["Username"] as! String
            let password = snapshotValue!["Password"] as! String
            self.listOfUsers.append((username, password))
            
        })
        
        print(listOfUsers)

    }
    
    // Change picture method
    @IBAction func changePicture(_ sender: Any) {
    }
    
    // Orange Login Button Pressed (DONE)
    @IBAction func loginPressed(_ sender: Any) {

        // Alert about field left empty
        if name.text! == "" || newPassword.text! == "" || newUsername.text! == "" || work.text! == ""{
            
            let alert = UIAlertController(title: "Some fields are empty", message: "Please fill all required fields", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        
            
        } else {
            
            var alreadyThere: Bool = false
            
            for (user, pass) in listOfUsers {
                if newUsername.text! == user {
                    alreadyThere = true
                    
                    let alert = UIAlertController(title: "Username already exists", message: "Try another username", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)

                    break
                }
            }

            if alreadyThere == false {
                let eventRef = self.eventRef.child(self.idGiven)
        
        
                eventRef.setValue(["Name": name.text!, "Password": newPassword.text!, "ID": self.idGiven, "Username": newUsername.text!, "Display Picture": "https://graph.facebook.com/" + self.idGiven + "/picture?type=large", "Work or School": work.text!, "Ratings": "", "Crushes": "", "Average": "5", "isPrivate": "true", "Recommendations": ""])
        
            
                UserDefaults.standard.set(true, forKey: "LoggedIn")

        
                performSegue(withIdentifier: "toHome", sender: self)
            }
        }
    }
    
    // To remove keyboard when finished writing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    // Used for Keyboard Next & Done from a textfield to the other
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            loginPressed(Any)
        }
        // Do not add a line break
        return true
    }
    
}
