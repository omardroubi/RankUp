//
//  SegueFromLeft.swift
//  RankUp
//
//  Created by Omar Droubi on 12/29/16.
//  Copyright © 2016 Omar Droubi. All rights reserved.
//

/////////////////////////////////////////////////////////////////////////////////
// This class is assigned to a segue to the view controller segue to the right //
/////////////////////////////////////////////////////////////////////////////////

import UIKit

class SegueFromLeft: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.27,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.curveEaseInOut,
                                   animations: {
                                    dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        },
                                   completion: { finished in
                                    src.present(dst, animated: false, completion: nil)
        }
        )
    }
}
