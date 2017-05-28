//
//  SignIn.swift
//  RankUp
//
//  Created by Omar Droubi on 12/28/16.
//  Copyright © 2017 Omar Droubi. All rights reserved.
//

//////////////////////////////////////////////////////////////////////
// This class is used in the first screen which is the sign in page //
//////////////////////////////////////////////////////////////////////

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignIn: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate  {

    // Read from Database
    var eventRef: FIRDatabaseReference!
    var listOfUsers: [(String, String)] = []
    var listOfIds: [String] = []
    /////////////////////////////////////
    
    //SignUp Variables used to transfer it to the SignUp Page
    var name: String = ""
    var id: String = ""
    var friendsListIDs: [String] = []
    var work: String = ""
    var goOn: Bool = false
    /////////////////////////////////////////////////////////
    
    var checkIfExists: Bool = false

    @IBOutlet var yourImageView: UIImageView! //used to get the FB Login Button
    @IBOutlet var username: UITextField! //username text
    
    @IBOutlet var password: UITextField! //password text
    
    @IBOutlet var backgroundImage: UIImageView! // background image (used to animate it)
    
/*    override func viewDidAppear(_ animated: Bool) {
        self.logUserData()

        //Check if LoggedIn already
        print("Already Logged In? ", UserDefaults.standard.bool(forKey: "LoggedIn"))
        
        if UserDefaults.standard.bool(forKey: "LoggedIn") == true {
            performSegue(withIdentifier: "toHome", sender: self)
        }

    }
 */
    @IBOutlet var tempImageView: UIImageView!
    
    override func viewDidLoad() {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        //Depending on your image, it might look better to use UIBlurEffect(style: UIBlurEffectStyle.ExtraLight) or UIBlurEffect(style: UIBlurEffectStyle.Dark).
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = tempImageView.bounds
        
        tempImageView.addSubview(blurView)

        
        // Edit the placeholders in the textfield (Color + Keyboard Next)
        let placeholder1 = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName:UIColor.white])
        
        let placeholder2 = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:UIColor.white])

        username.attributedPlaceholder = placeholder1
        password.attributedPlaceholder = placeholder2
        
        username.delegate = self
        username.tag = 0 //Increment accordingly
        
        password.delegate = self
        password.tag = 1
        
        // Facebook Login Button
        let facebookButton = FBSDKLoginButton()
        
        let screenSize = UIScreen.main.bounds.size
        let width = screenSize.width
        let height = screenSize.height
        
        facebookButton.frame = CGRect(x: width/7, y: height/1.16, width: view.frame.width - 100, height: 50)
        facebookButton.titleLabel?.font = UIFont(name: (facebookButton.titleLabel?.font.fontName)!, size: 18)
        
        facebookButton.readPermissions = ["public_profile", "user_friends", "user_education_history", "user_work_history"]
        self.view.addSubview(facebookButton)
        facebookButton.delegate = self
        /////////////////////////////////////////////////
        // Read DATABASE
        eventRef = FIRDatabase.database().reference()
        eventRef.child("Users").queryOrderedByKey().observe(.childAdded, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as? NSDictionary
            let username = snapshotValue!["Username"] as! String
            let password = snapshotValue!["Password"] as! String
            self.listOfUsers.append((username, password))

            let idHot = snapshotValue!["ID"] as! String
            self.listOfIds.append(idHot)
        })
        
        print(listOfUsers)
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("Successfully Logged In to Facebook")
        if (FBSDKAccessToken.current() != nil) {
            print("No Token yet")
         
            // Get friendsList(id; name) + totalCount, id, name
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, friends, education, work"]).start(completionHandler: { (connection, result, err) in

                if err != nil {
                    print("Failed to start Graph Request")
                    return
                }
                print("Facebook Info: ", String(describing: result))

                
                var facebookInfo: String = String(describing: result)
                let table = result as! NSDictionary

                //GET NAME
                
                self.name = table["name"] as! String //name is obtained from Facebook
                print("NAME FROM TABLE ", self.name)
                
                
                //GET ID
                
                self.id = table["id"] as! String //ID is obtained from Facebook
                print(self.id)
                
                UserDefaults.standard.set(table["id"], forKey: "ID")
                
                
                //GET current Work/Uni
                if facebookInfo.contains("work") {
                    
                    var indexOfWork = 0
                    //search for the first "name = "
                    
                    for i in 0..<facebookInfo.characters.count {
                        
                        let startWork = facebookInfo.index(facebookInfo.startIndex, offsetBy: i)
                        let endWork = facebookInfo.index(facebookInfo.endIndex, offsetBy: -(facebookInfo.characters.count - i - 4))
                        let rangeWork = startWork..<endWork
                        
                        print(facebookInfo.substring(with: rangeWork))
                        
                        if facebookInfo.substring(with: rangeWork) == "name" {
                            //get the number of letters of the school
                            
                            var counter: Int = 0
                            
                            for j in i+8..<facebookInfo.characters.count {
                                let index = facebookInfo.index(facebookInfo.startIndex, offsetBy: j)
                                
                                print(facebookInfo.substring(from: index))
                                
                                if facebookInfo.substring(from: index).characters.first == "\"" {
                                    break
                                }
                                
                                if facebookInfo.substring(from: index).contains("\"") {
                                    counter += 1
                                }
                            }
                            
                            print(counter)
                            
                            
                            let start = facebookInfo.index(facebookInfo.startIndex, offsetBy: i + 8)
                            let end = facebookInfo.index(facebookInfo.endIndex, offsetBy: -(facebookInfo.characters.count - i-8 - counter))
                            let range = start..<end
                            
                            
                            
                            self.work = facebookInfo.substring(with: range)
                            print(self.work)
                            break
                        }
                        
                    }
                    
                }

                else if facebookInfo.contains("education") {
                    
                    var indexOfWork = 0
                    //search for the first "name = "
                    
                    for i in 0..<facebookInfo.characters.count {
                    
                        let startWork = facebookInfo.index(facebookInfo.startIndex, offsetBy: i)
                        let endWork = facebookInfo.index(facebookInfo.endIndex, offsetBy: -(facebookInfo.characters.count - i - 4))
                        let rangeWork = startWork..<endWork
                        
                        print(facebookInfo.substring(with: rangeWork))
                        
                        if facebookInfo.substring(with: rangeWork) == "name" {
                            //get the number of letters of the school
                            
                            var counter: Int = 0
                            
                            for j in i+8..<facebookInfo.characters.count {
                                let index = facebookInfo.index(facebookInfo.startIndex, offsetBy: j)
                                
                                print(facebookInfo.substring(from: index))

                                if facebookInfo.substring(from: index).characters.first == "\"" {
                                    break
                                }
                                
                                if facebookInfo.substring(from: index).contains("\"") {
                                    counter += 1
                                }
                            }
                            
                            print(counter)
                            
                            
                            let start = facebookInfo.index(facebookInfo.startIndex, offsetBy: i + 8)
                            let end = facebookInfo.index(facebookInfo.endIndex, offsetBy: -(facebookInfo.characters.count - i-8 - counter))
                            let range = start..<end

                            
                            
                            self.work = facebookInfo.substring(with: range)
                            print(self.work)
                            break
                        }
                    
                    }
                
                }
                
                
                // Get Friends: Fills the Array friendsListIDs containing strings of the user's friends' IDs and saves it to UserDefaults
                if facebookInfo.contains("friends") {
                    
                    // {(id = 32424, name = "Omar Droubi"), (id = 43242, name = "Khaled Droubi")}
                    let listFriends = table["friends"] as! NSDictionary
                    
                    for friend in listFriends["data"] as! NSArray {

                        let pers = friend as! NSDictionary
                        
                        
                        print(pers["id"])
                        self.friendsListIDs.append(pers["id"] as! String)
                    }
                    
                    UserDefaults.standard.set(self.friendsListIDs, forKey: "Facebook Friends List IDs")
                    
                }
                
                
                // Firebase Login
                let accessToken = FBSDKAccessToken.current()
                
                guard let accessTokenString = accessToken?.tokenString else
                { return }
                
                let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
                
                FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                    if error != nil {
                        print("Something went wrong with our FB user: ", error)
                        return
                    }
                    
                    print("Successfully logged in to Firebase with our user: ", user)
                })
                
                
                //Check if account already exists
                for idSearched in self.listOfIds {
                    if idSearched == self.id {
                        self.checkIfExists = true
                        
                        UserDefaults.standard.set(true, forKey: "LoggedIn")
                        
                        self.performSegue(withIdentifier: "toHome", sender: self)
                        break
                    }
                }

                
                if self.checkIfExists == false {
                    self.goOn = true
                    print("GoOn after ",self.goOn)

                    print(self.name)
                    
                    UserDefaults.standard.set(table["id"] as! String, forKey: "ID")
                    UserDefaults.standard.set(self.work, forKey: "Work")
                    UserDefaults.standard.set(self.name, forKey: "Name")

            
                    self.performSegue(withIdentifier: "toSignUp", sender: self)
                }
            })
            print("GoOn after ",self.goOn)
            print(self.name)

            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSignUp" && self.goOn == true{
            print("Go On after ", self.goOn)

            let signUp = segue.destination as! SignUp
            signUp.nameGiven = UserDefaults.standard.object(forKey: "Name") as! String
            signUp.idGiven = UserDefaults.standard.object(forKey: "ID") as! String
            signUp.workGiven = UserDefaults.standard.object(forKey: "Work") as! String
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged Out")
    }
    
    func logUserData() {
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        
        graphRequest?.start(completionHandler: { (connection, result, error) in
            if error != nil {
                print(error)
            } else {
                print(result)
            }
        })
    }
    //////////////////////////////////////////////////////////////
    
    
    // Orange Login Button Pressed
    @IBAction func loginPressed(_ sender: Any) {
        
        var loggedIn: Bool = false
        
        for (user, pass) in listOfUsers {
            if username.text! == user && password.text! == pass {
                loggedIn = true
                
                UserDefaults.standard.set(true, forKey: "LoggedIn")
                
                performSegue(withIdentifier: "toHome", sender: self)
                break
            }
        }
        if loggedIn == false {
            let alert = UIAlertController(title: "Incorrect Username/Password", message: "Make sure that your username or password are correct", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
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
