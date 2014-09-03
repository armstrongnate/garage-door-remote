//
//  GDRFirebaseManager.swift
//  GarageDoorRemote
//
//  Created by Nate Armstrong on 6/29/14.
//  Copyright (c) 2014 Nate Armstrong. All rights reserved.
//

import UIKit

protocol GDRFirebaseManagerDelegate {
  func garageStateDidChange(state: GarageState)
  func piStateDidChange()
}

enum GarageState: String {
  case Open = "open"
  case Closed = "closed"

  func asAction() -> String {
    switch self {
      case .Closed:
        return "close"
      default:
        return self.toRaw()
    }
  }
}

struct Door {
  let upPosition: CGFloat
  let downPosition: CGFloat
  var state: GarageState?
  var waiting = false
}

prefix func ! (state: GarageState) -> GarageState {
  switch state {
    case .Open:
      return .Closed
    case .Closed:
      return .Open
  }
}

class GDRFirebaseManager: NSObject {
  let baseUrl = "https://torid-fire-504.firebaseio.com"
  let rootRef: Firebase
  let garageRef: Firebase
  let phoneRef: Firebase
  let piRef: Firebase
  var delegate: GDRFirebaseManagerDelegate?
  var garageState: GarageState?
  var phoneState: GarageState?

  override init() {
    rootRef = Firebase(url: baseUrl)
    piRef = rootRef.childByAppendingPath("pi")
    garageRef = rootRef.childByAppendingPath("garage")
    phoneRef = rootRef.childByAppendingPath("phone")
    super.init()
    startObservingStates()
  }

  func togglePhoneState() {
    phoneRef.setValue(NSDate().description)
  }

  func startObservingStates() {
    garageRef.observeEventType(FEventTypeValue, withBlock: { snapshot in
      self.garageState = GarageState.fromRaw(snapshot.value as String)
      if self.delegate != nil {
        if let state = GarageState.fromRaw(snapshot.value as String) {
          self.delegate!.garageStateDidChange(state)
        }
      }
    })
    piRef.observeEventType(FEventTypeValue, withBlock: { snapshot in
      if self.delegate != nil && self.garageState != nil {
        self.delegate!.piStateDidChange()
      }
    })
  }
}
