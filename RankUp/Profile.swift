//
//  Profile.swift
//  RankUp
//
//  Created by Omar Droubi on 1/16/17.
//  Copyright © 2017 Omar Droubi. All rights reserved.
//

import Foundation
import UIKit
import LLSlideMenu
import Firebase
import FirebaseDatabase
import SwiftGifOrigin
import Canvas

class Profile: UIViewController {

    //Slide menu variables
    var slideMenu: LLSlideMenu!
    var percent: UIPercentDrivenInteractiveTransition!
    var leftSwipe: UIPanGestureRecognizer!

    override func viewDidLoad() {

        //SLIDE MENU
        ////////////////////////////////////////////////
        self.slideMenu = LLSlideMenu()
        
        self.view.addSubview(slideMenu)
        
        slideMenu.ll_menuWidth = 200.0
        slideMenu.ll_menuBackgroundColor = UIColor(patternImage: UIImage(named: "menuBackground.png")!)
        slideMenu.ll_springDamping = 20
        slideMenu.ll_springVelocity = 15
        slideMenu.ll_springFramesNum = 60
        
        // Put Image in the MENU
        ////////////////////////////
        let img = UIImageView(frame: CGRect(x: CGFloat(10), y: CGFloat(35), width: CGFloat(180), height: CGFloat(180)))
        img.downloadedFrom(link: "https://graph.facebook.com/" + (UserDefaults.standard.object(forKey: "ID") as! String) + "/picture?type=large")
        img.setRounded()
        
        slideMenu.addSubview(img)
        /////////////////////
        
        //Put Images of the buttons
        
        /////////////////////////////
        
        // Name Label
        var nameLabel = UILabel(frame: CGRect(x: CGFloat(33), y: CGFloat(210), width: CGFloat(150), height: CGFloat(50)))
        nameLabel.text = "Omar Droubi"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 22)
        nameLabel.textColor = UIColor.white
        nameLabel.numberOfLines = 0
        slideMenu.addSubview(nameLabel)
        
        // Average Label
        var averageLabel = UILabel(frame: CGRect(x: CGFloat(163), y: CGFloat(250), width: CGFloat(150), height: CGFloat(50)))
        averageLabel.text = "4.2"
        averageLabel.font = UIFont.systemFont(ofSize: 22)
        averageLabel.textColor = UIColor.white
        averageLabel.numberOfLines = 0
        slideMenu.addSubview(averageLabel)
        
        
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
        buttonHome.titleLabel?.font = UIFont (name: "System", size: 40)
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
        
        // Button Crushes
        let buttonCrushes:UIButton = UIButton(frame: CGRect(x: CGFloat(80), y: CGFloat(420), width: CGFloat(150), height: CGFloat(50)))
        buttonCrushes.titleLabel?.textColor = .white
        buttonCrushes.titleLabel?.font = UIFont (name: "System", size: 40)
        buttonCrushes.setTitle("Crushes", for: .normal)
        buttonCrushes.addTarget(self, action:#selector(self.crushesPressed), for: .touchUpInside)
        slideMenu.addSubview(buttonCrushes)
        
        // Button Settings
        let buttonSettings:UIButton = UIButton(frame: CGRect(x: CGFloat(80), y: CGFloat(470), width: CGFloat(150), height: CGFloat(50)))
        buttonSettings.titleLabel?.textColor = .white
        buttonSettings.titleLabel?.font = UIFont (name: "System", size: 40)
        buttonSettings.setTitle("Settings", for: .normal)
        buttonSettings.addTarget(self, action:#selector(self.settingsPressed), for: .touchUpInside)
        slideMenu.addSubview(buttonSettings)
       
        
        /*
         //===================
         // Add full-screen side-slip gestures
         //===================
         self.leftSwipe = UIPanGestureRecognizer(target: self, action: #selector(self.swipeLeftHandle))
         self.leftSwipe.maximumNumberOfTouches = 1
         self.view.addGestureRecognizer(leftSwipe)
         */
        ////////////////////////////////////////////////////////////

    }
    
    // SLIDE MENU FUNCTIONS
    //////////////////////////////////////////////////
    // func used when button in the slide menu is pressed
    func buttonClicked() {
        print("Button Clicked")
    }
    
    func homePressed() {
        performSegue(withIdentifier: "toHome", sender: self)

    }
    
    func profilePressed() {
        //performSegue(withIdentifier: "toProfile", sender: self)
    }
    
    func rankingsPressed() {
        performSegue(withIdentifier: "toRankings", sender: self)
    }
    
    func crushesPressed() {
        performSegue(withIdentifier: "toCrushes", sender: self)
        
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
    


}
