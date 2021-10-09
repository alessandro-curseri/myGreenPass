//
//  TapticManager.swift
//  Taptic Engine
//
//  Created by Marcello Catelli
//  Copyright © Swift srl. All rights reserved.
//

import UIKit

class TapticManager {
	
	static let shared = TapticManager()
	
    let lightGen = UIImpactFeedbackGenerator(style: .light)
    let mediumGen = UIImpactFeedbackGenerator(style: .medium)
    let heavyGen = UIImpactFeedbackGenerator(style: .heavy)
   let not = UINotificationFeedbackGenerator()
    func lightImpact() {
        lightGen.impactOccurred()
    }
    
    func mediumImpact() {
        mediumGen.impactOccurred()
    }
    
    func heavyImpact() {
        heavyGen.impactOccurred()
    }
    
    func customImpact(_ inten: CGFloat) {
        heavyGen.impactOccurred(intensity: inten)
    }
    func success() {
        not.notificationOccurred(.success)
    }
    func error() {
        not.notificationOccurred(.error)
    }
}
