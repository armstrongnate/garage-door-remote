//
//  ViewController.swift
//  GarageDoorRemote
//
//  Created by Nate Armstrong on 6/29/14.
//  Copyright (c) 2014 Nate Armstrong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GDRFirebaseManagerDelegate {
  @IBOutlet var mainButton : UIButton!
  @IBOutlet weak var closedConstraint: NSLayoutConstraint!
  @IBOutlet weak var closedImage: UIImageView!
  let firebaseManager = GDRFirebaseManager()
  let backgroundColor = UIColor(red: 74/255.0, green: 144/255.0, blue: 226/255.0, alpha: 1.0)
  let workingColor = UIColor(red: 85/255.0, green: 98/255.0, blue: 112/255.0, alpha: 1.0)
  var door: Door!

  override func viewDidLoad() {
    super.viewDidLoad()
    firebaseManager.delegate = self
    view.backgroundColor = backgroundColor
    closedImage.superview!.clipsToBounds = true
    let upPosition = closedConstraint.constant - closedImage.frame.size.height
    let downPosition: CGFloat = 0.0
    door = Door(upPosition: upPosition, downPosition: downPosition, state: nil, waiting: false)
  }

  func garageStateDidChange(state: GarageState)  {
    door.state = state
    setDoorToState(state)
  }

  func piStateDidChange() {
    UIView.animateWithDuration(0.75, delay: 0.0, options: .CurveEaseOut, animations: {
      self.view.backgroundColor = self.backgroundColor
    }, completion: nil)
    if door.state != nil && door.state! == GarageState.Closed && door.waiting {
      setDoorToState(.Open)
    }
  }

  @IBAction func mainButtonPressed(sender : UIButton) {
    door.waiting = true
    firebaseManager.togglePhoneState()
    UIView.animateWithDuration(0.75, delay: 0.0, options: .CurveEaseOut, animations: {
      self.view.backgroundColor = self.workingColor
    },
    completion: nil)
  }

  func setDoorToState(state: GarageState) {
    view.layoutIfNeeded()
    let options: UIViewAnimationOptions = .CurveEaseInOut
    let position = state == GarageState.Open ? door.upPosition : door.downPosition
    UIView.animateWithDuration(2.0, delay: 0.0, options: options, animations: {
      self.closedConstraint.constant = position
      self.view.layoutIfNeeded()
    }, completion: { completed in
      self.mainButton.setTitle((!state).asAction().uppercaseString, forState: .Normal)
    })
  }

}

