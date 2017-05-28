//
//  Home.swift
//  RankUp
//
//  Created by Omar Droubi on 1/11/17.
//  Copyright © 2017 Omar Droubi. All rights reserved.
//

import Foundation
import UIKit
import LLSlideMenu
import Firebase
import FirebaseDatabase
import Canvas

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    func setRounded() {
        let radius = self.frame.width/2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
}

class Home: UIViewController {
    
    @IBOutlet var animView: CSAnimationView!
    @IBOutlet var textAnimView: CSAnimationView!
    
    var rating: Int = 0
    
    var userAverage: Double = 0
    var userID: String = UserDefaults.standard.object(forKey: "ID") as! String
    
    var friendsListIDs: [String] = []
    var listOfFriends: [String] = [] // Array [name1, work1, name2, work2]
    
    // Stars
    var buttonArray:NSMutableArray! = NSMutableArray()
    @IBOutlet var firstStar: UIButton!
    @IBOutlet var secondStar: UIButton!
    @IBOutlet var thirdStar: UIButton!
    @IBOutlet var fourthStar: UIButton!
    @IBOutlet var fifthStar: UIButton!
    
    // Read from Database
    var eventRefRead: FIRDatabaseReference!
    /////////////////////////////////////////

    // FRIEND VISUAL VARIABLES
    @IBOutlet var friendPicture: UIImageView!
    @IBOutlet var friendName: UILabel!
    @IBOutlet var friendWork: UILabel!
    

    //Slide menu variables
    var slideMenu: LLSlideMenu!
    var percent: UIPercentDrivenInteractiveTransition!
    var leftSwipe: UIPanGestureRecognizer!

    
    // BUTTON FOR TESTING ONLY
/*    @IBAction func signOut(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "LoggedIn")
        dismiss(animated: true, completion: nil)
    }
  */
    
    override func viewDidAppear(_ animated: Bool) {
        
        let imageData = try! Data(contentsOf: Bundle.main.url(forResource: "Loading-Top-Wallpapers", withExtension: "gif")!)
        self.friendPicture.image = UIImage.gif(data: imageData)
        
        friendsListIDs = UserDefaults.standard.object(forKey: "Facebook Friends List IDs") as! [String]

        // Read DATABASE
        eventRefRead = FIRDatabase.database().reference()
        eventRefRead.child("Users").queryOrderedByKey().observe(.childAdded, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as? NSDictionary
            let name = snapshotValue!["Name"] as! String
            let work = snapshotValue!["Work or School"] as! String
            let id = snapshotValue!["ID"] as! String
            let average = snapshotValue!["Average"] as! String
            
            if (id == self.userID) {
                self.userAverage = NumberFormatter().number(from: average) as! Double
                print(self.userAverage)
            }
            
            // check if name is in the friends list and add it to friends List
            for idCheck in self.friendsListIDs {
                if id == idCheck {
                    self.listOfFriends.append(name)
                    self.listOfFriends.append(work)
                    // First friend is shown
                    if (!self.friendsListIDs.isEmpty) {
                        self.friendPicture.downloadedFrom(link: "https://graph.facebook.com/" + self.friendsListIDs[0] + "/picture?type=large")
                        self.friendPicture.setRounded()
                        self.friendName.text = self.listOfFriends[0]
                        self.friendWork.text = self.listOfFriends[1]
                        
                    }

                }
            }
            
        })
        
        print("List of Friendss ", listOfFriends)

        print("List of remaining friends: ")
    }
    

    
    override func viewDidLoad() {
        

        //SLIDE MENU
        ////////////////////////////////////////////////
        self.slideMenu = LLSlideMenu()
        
        self.view.addSubview(slideMenu)
        
        slideMenu.ll_menuWidth = self.view.frame.size.width/1.8
        slideMenu.ll_menuBackgroundColor = UIColor(patternImage: UIImage(named: "menuBackground.png")!)
        slideMenu.ll_springDamping = 20
        slideMenu.ll_springVelocity = 15
        slideMenu.ll_springFramesNum = 60

        // Put Profile Image in the MENU
        ////////////////////////////
        let img = UIImageView(frame: CGRect(x: CGFloat(10), y: CGFloat(35), width: CGFloat(self.view.frame.size.width/2), height: CGFloat(self.view.frame.size.width/1.8)))
        img.downloadedFrom(link: "https://graph.facebook.com/" + (UserDefaults.standard.object(forKey: "ID") as! String) + "/picture?type=large")
        img.setRounded()

        slideMenu.addSubview(img)
        /////////////////////
        
        //Put Images of the buttons
        // Home Button Icon
        var homeIcon = UIImageView(frame: CGRect(x: CGFloat(40), y: CGFloat(35), width: CGFloat(50), height: CGFloat(50)))
        homeIcon.image = UIImage(named: "homeIcon")
        
        homeIcon.setRounded()
        
        slideMenu.addSubview(homeIcon)

        // Rankings Button Icon
        var rankingsButtonIcon = UIImageView(frame: CGRect(x: CGFloat(40), y: CGFloat(35), width: CGFloat(50), height: CGFloat(50)))
        rankingsButtonIcon.image = UIImage(named: "Ranking_icon")
        
        rankingsButtonIcon.setRounded()
        
        slideMenu.addSubview(rankingsButtonIcon)

        // Settings Button Icon
        var settingsIcon = UIImageView(frame: CGRect(x: CGFloat(40), y: CGFloat(35), width: CGFloat(50), height: CGFloat(50)))
        settingsIcon.image = UIImage(named: "Settings")
        
        settingsIcon.setRounded()
        
        slideMenu.addSubview(settingsIcon)

        /////////////////////////////
        
        
        // Button Profile
        let buttonProfile:UIButton = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(50), width: CGFloat(150), height: CGFloat(260)))
        buttonProfile.titleLabel?.textColor = .white
        buttonProfile.titleLabel?.font = UIFont (name: "System", size: 40)
        buttonProfile.setTitle("", for: .normal)
        buttonProfile.addTarget(self, action:#selector(self.profilePressed), for: .touchUpInside)
        slideMenu.addSubview(buttonProfile)
        
        // Button Home
        let buttonHome:UIButton = UIButton(frame: CGRect(x: CGFloat(80), y: CGFloat(320), width: CGFloat(150), height: CGFloat(50)))
        buttonHome.titleLabel?.textColor = .white
        buttonHome.titleLabel?.font = UIFont (name: "System", size: 70)
        buttonHome.setTitle("Home", for: .normal)
        buttonHome.addTarget(self, action:#selector(self.homePressed), for: .touchUpInside)
        slideMenu.addSubview(buttonHome)
        
        // Button Rankings
        let buttonRankings:UIButton = UIButton(frame: CGRect(x: CGFloat(80), y: CGFloat(370), width: CGFloat(150), height: CGFloat(50)))
        buttonRankings.titleLabel?.textColor = .white
        buttonRankings.titleLabel?.font = UIFont (name: "System", size: 40)
        buttonRankings.setTitle("Rankings", for: .normal)
        buttonRankings.addTarget(self, action:#selector(self.rankingsPressed), for: .touchUpInside)
        slideMenu.addSubview(buttonRankings)
        buttonRankings.isSelected = true

        // Button Settings
        let buttonSettings:UIButton = UIButton(frame: CGRect(x: CGFloat(80), y: CGFloat(470), width: CGFloat(150), height: CGFloat(50)))
        buttonSettings.titleLabel?.textColor = .white
        buttonSettings.titleLabel?.font = UIFont (name: "System", size: 40)
        buttonSettings.setTitle("Settings", for: .normal)
        buttonSettings.addTarget(self, action:#selector(self.settingsPressed), for: .touchUpInside)
        slideMenu.addSubview(buttonSettings)

        // Read DATABASE
        eventRefRead = FIRDatabase.database().reference()
        eventRefRead.child("Users").queryOrderedByKey().observe(.childAdded, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as? NSDictionary
            let id = snapshotValue!["ID"] as! String
            let average = snapshotValue!["Average"] as! String
            
            if (id == self.userID) {
                self.userAverage = NumberFormatter().number(from: average) as! Double
                print(self.userAverage)
                
                // Stars Icons
                // Star1 Button Icon
                var star1 = UIImageView(frame: CGRect(x: CGFloat(40), y: CGFloat(35), width: CGFloat(50), height: CGFloat(50)))
                
                self.slideMenu.addSubview(star1)
                
                // Star2 Button Icon
                var star2 = UIImageView(frame: CGRect(x: CGFloat(40), y: CGFloat(35), width: CGFloat(50), height: CGFloat(50)))
                
                self.slideMenu.addSubview(star2)
                
                // Star3 Button Icon
                var star3 = UIImageView(frame: CGRect(x: CGFloat(40), y: CGFloat(35), width: CGFloat(50), height: CGFloat(50)))
                
                self.slideMenu.addSubview(star3)
                
                // Star4 Button Icon
                var star4 = UIImageView(frame: CGRect(x: CGFloat(40), y: CGFloat(35), width: CGFloat(50), height: CGFloat(50)))
                
                
                self.slideMenu.addSubview(star4)
                
                // Star5 Button Icon
                var star5 = UIImageView(frame: CGRect(x: CGFloat(40), y: CGFloat(35), width: CGFloat(50), height: CGFloat(50)))
                
                self.slideMenu.addSubview(star5)
                
                // Set pictures according to the user's average rating:
                if (self.userAverage < 0.5) {
                    star1.image = UIImage(named: "emptyStar")
                    star2.image = UIImage(named: "emptyStar")
                    star3.image = UIImage(named: "emptyStar")
                    star4.image = UIImage(named: "emptyStar")
                    star5.image = UIImage(named: "emptyStar")
                }
                else if (self.userAverage < 1.5 && self.userAverage >= 0.5) {
                    star1.image = UIImage(named: "redStar")
                    star2.image = UIImage(named: "emptyStar")
                    star3.image = UIImage(named: "emptyStar")
                    star4.image = UIImage(named: "emptyStar")
                    star5.image = UIImage(named: "emptyStar")
                }
                else if (self.userAverage < 2.5 && self.userAverage >= 1.5) {
                    star1.image = UIImage(named: "redStar")
                    star2.image = UIImage(named: "redStar")
                    star3.image = UIImage(named: "emptyStar")
                    star4.image = UIImage(named: "emptyStar")
                    star5.image = UIImage(named: "emptyStar")
                }
                else if (self.userAverage < 3.5 && self.userAverage >= 2.5) {
                    star1.image = UIImage(named: "redStar")
                    star2.image = UIImage(named: "redStar")
                    star3.image = UIImage(named: "redStar")
                    star4.image = UIImage(named: "emptyStar")
                    star5.image = UIImage(named: "emptyStar")
                }
                else if (self.userAverage < 4.5 && self.userAverage >= 3.5) {
                    star1.image = UIImage(named: "redStar")
                    star2.image = UIImage(named: "redStar")
                    star3.image = UIImage(named: "redStar")
                    star4.image = UIImage(named: "redStar")
                    star5.image = UIImage(named: "emptyStar")
                }
                else if (self.userAverage <= 5 && self.userAverage >= 4.5) {
                    star1.image = UIImage(named: "redStar")
                    star2.image = UIImage(named: "redStar")
                    star3.image = UIImage(named: "redStar")
                    star4.image = UIImage(named: "redStar")
                    star5.image = UIImage(named: "redStar")
                }
                
                // Name Label
                var nameLabel = UILabel(frame: CGRect(x: CGFloat(33), y: CGFloat(210), width: CGFloat(150), height: CGFloat(50)))
                nameLabel.text = UserDefaults.standard.object(forKey: "Name") as! String?
                nameLabel.font = UIFont.boldSystemFont(ofSize: 22)
                nameLabel.textColor = UIColor.white
                nameLabel.numberOfLines = 0
                self.slideMenu.addSubview(nameLabel)
                
                // Average Label
                var averageLabel = UILabel(frame: CGRect(x: CGFloat(163), y: CGFloat(250), width: CGFloat(150), height: CGFloat(50)))
                averageLabel.text = String(self.userAverage)
                averageLabel.font = UIFont.systemFont(ofSize: 22)
                averageLabel.textColor = UIColor.white
                averageLabel.numberOfLines = 0
                self.slideMenu.addSubview(averageLabel)
                
            }
        })
        

        /*
        //===================
        // Add full-screen side-slip gestures
        //===================
        self.leftSwipe = UIPanGestureRecognizer(target: self, action: #selector(self.swipeLeftHandle))
        self.leftSwipe.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(leftSwipe)
         */
        ////////////////////////////////////////////////////////////
        
        // Stars swipe recognizer
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureMethod(gesture:)))
        self.view.addGestureRecognizer(swipeGesture)
        /////
        
        
        
        // FACEBOOK FRIENDS
        print("FRIENDS AT HOME ", UserDefaults.standard.object(forKey: "Facebook Friends List IDs"))
        
        
        friendsListIDs = UserDefaults.standard.object(forKey: "Facebook Friends List IDs") as! [String]
        
        print(friendsListIDs)
    
    }


    // Stars swiped Function
    func panGestureMethod(gesture:UIPanGestureRecognizer) {
        
        // Initialize and empty array to hold the buttons at the
        // start of the gesture
        if gesture.state == UIGestureRecognizerState.began {
            buttonArray = NSMutableArray()
        }
        
        // Get the gesture's point location within its view
        // (This answer assumes the gesture and the buttons are
        // within the same view, ex. the gesture is attached to
        // the view controller's superview and the buttons are within
        // that same superview.)
        let pointInView = gesture.location(in: gesture.view)
        
        // For each button, if the gesture is within the button and
        // the button hasn't yet been added to the array, add it to the
        // array. (This example uses 4 buttons instead of 9 for simplicity's
        // sake
        if !buttonArray.contains(firstStar) && firstStar.frame.contains(pointInView){
            //buttonArray.add(firstStar)
            firstStar.sendActions(for: UIControlEvents.touchUpInside)
        }
        if !buttonArray.contains(secondStar) && secondStar.frame.contains(pointInView){
            //buttonArray.add(secondStar)
            secondStar.sendActions(for: UIControlEvents.touchUpInside)
        }
        if !buttonArray.contains(thirdStar) && thirdStar.frame.contains(pointInView){
            //buttonArray.add(thirdStar)
            thirdStar.sendActions(for: UIControlEvents.touchUpInside)
        }
        if !buttonArray.contains(fourthStar) && fourthStar.frame.contains(pointInView){
            //buttonArray.add(fourthStar)
            fourthStar.sendActions(for: UIControlEvents.touchUpInside)
        }
        if !buttonArray.contains(fifthStar) && fifthStar.frame.contains(pointInView){
           // buttonArray.add(fifthStar)
            fifthStar.sendActions(for: UIControlEvents.touchUpInside)
        }
        
       /* // Once the gesture ends, trigger the buttons within the
        // array using whatever control event would otherwise trigger
        // the button's method.
        if gesture.state == UIGestureRecognizerState.ended && buttonArray.count > 0 {
            for button in buttonArray {
                (button as! UIButton).sendActions(for: UIControlEvents.touchUpInside)
            }
        }
        
        buttonArray.removeAllObjects()*/
    }
    // Stars Pressed Functions

    @IBAction func firstStarPressed(_ sender: Any) {
        rating = 1
        
        firstStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)
        secondStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        thirdStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        fourthStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        fifthStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        
    }
    
    @IBAction func secondStarPressed(_ sender: Any) {
        rating = 2
        
        firstStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)
        secondStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)
        thirdStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        fourthStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        fifthStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
    }
    
    @IBAction func thirdStarPressed(_ sender: Any) {
        rating = 3

        firstStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)
        secondStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)
        thirdStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)
        fourthStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        fifthStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
    }
    
    @IBAction func fourthStarPressed(_ sender: Any) {
        rating = 4
        
        firstStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)
        secondStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)
        thirdStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)
        fourthStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)
        fifthStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
    }
    
    
    @IBAction func fifthStarPressed(_ sender: Any) {
        rating = 5
        
        firstStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)
        secondStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)
        thirdStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)
        fourthStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)
        fifthStar.setBackgroundImage(UIImage(named: "redStar"), for: .normal)

    }
    /////////////////////////////////
    
    
    
    // Green checkmark button pressed
    @IBAction func checkButtonPressed(_ sender: Any) {
        //reset stars
        firstStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        secondStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        thirdStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        fourthStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        fifthStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)

        //update arrays lists
        if(!listOfFriends.isEmpty) {
            listOfFriends.removeFirst()
            listOfFriends.removeFirst()
            
        }
        
        if(!friendsListIDs.isEmpty) {
            friendsListIDs.removeFirst()
        }
        
        if(!listOfFriends.isEmpty && !friendsListIDs.isEmpty) {
            let imageData = try! Data(contentsOf: Bundle.main.url(forResource: "Loading-Top-Wallpapers", withExtension: "gif")!)
            self.friendPicture.image = UIImage.gif(data: imageData)

            self.friendPicture.downloadedFrom(link: "https://graph.facebook.com/" + self.friendsListIDs[0] + "/picture?type=large")
            self.friendPicture.setRounded()
            self.friendName.text = self.listOfFriends[0]
            self.friendWork.text = self.listOfFriends[1]
        }
        
        animView.startCanvasAnimation()

    }
    
    // Skip button pressed
    @IBAction func skipButtonPressed(_ sender: Any) {
        //reset stars
        firstStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        secondStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        thirdStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        fourthStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        fifthStar.setBackgroundImage(UIImage(named: "emptyStar"), for: .normal)
        
        //update arrays lists
        if(!listOfFriends.isEmpty) {
            listOfFriends.removeFirst()
            listOfFriends.removeFirst()
            
        }
        
        if(!friendsListIDs.isEmpty) {
            friendsListIDs.removeFirst()
        }
        
        if(!listOfFriends.isEmpty) {
            let imageData = try! Data(contentsOf: Bundle.main.url(forResource: "Loading-Top-Wallpapers", withExtension: "gif")!)
            self.friendPicture.image = UIImage.gif(data: imageData)
            
            self.friendPicture.downloadedFrom(link: "https://graph.facebook.com/" + self.friendsListIDs[0] + "/picture?type=large")
            self.friendPicture.setRounded()
            self.friendName.text = self.listOfFriends[0]
            self.friendWork.text = self.listOfFriends[1]
        }
        animView.startCanvasAnimation()

    }
        
    
    // SLIDE MENU FUNCTIONS
    //////////////////////////////////////////////////
    // func used when button in the slide menu is pressed
    func buttonClicked() {
        print("Button Clicked")
    }
    
    func homePressed() {
        //performSegue(withIdentifier: "toHome", sender: self)
    }
    
    func profilePressed() {
        performSegue(withIdentifier: "toProfile", sender: self)

    }
    
    func rankingsPressed(sender: UIButton) {
        sender.isSelected = true
        //performSegue(withIdentifier: "toRankings", sender: self)
    }
    

    func settingsPressed() {
        performSegue(withIdentifier: "toSettings", sender: self)
    }
    
    func swipeLeftHandle(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        //Slide is disabled if the menu is open
        if slideMenu.ll_isOpen || slideMenu.ll_isAnimating {
            return
        }
        // Calculate the physical distance of the finger slip (how far it slides, regardless of the starting position)
        var progress: CGFloat = recognizer.translation(in: self.view).x / (self.view.bounds.size.width * 1.0)
        // This percentage is limited to between 0 and 1
        progress = min(1.0, max(0.0, progress))

        if recognizer.state == .began {
            self.percent = UIPercentDrivenInteractiveTransition()
        }
        else if recognizer.state == .changed {
            // When the hand is moved slowly, we tell the UIPercentDrivenInteractiveTransition object the progress of the overall gesture.
            self.percent.update(progress)
            self.slideMenu.ll_distance = recognizer.translation(in: self.view).x
        }
        else if recognizer.state == .cancelled || recognizer.state == .ended {
            // When the gesture ends, we determine whether the transition should be completed or canceled and call the finishInteractiveTransition or cancelInteractiveTransition methods, depending on the user's gesture progress.
            if progress > 0.4 {
                self.percent.finish()
                slideMenu.ll_open()
            }
            else {
                self.percent.cancel()
                slideMenu.ll_close()
            }
            self.percent = nil
        }
        
    }
    
    @IBAction func openLLSlideMenuAction(_ sender: Any) {
        if slideMenu.ll_isOpen {
            slideMenu.ll_close()
        }
        else {
            slideMenu.ll_open()
        }

    }
    ////////////////////////////////////////////////////////
    // To remove keyboard when finished writing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }

}
