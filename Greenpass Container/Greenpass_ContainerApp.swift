//
//  Greenpass_ContainerApp.swift
//  Greenpass Container
//
//  Created by Alessandro Curseri on 08/08/21.
//

import SwiftUI

@main
struct Greenpass_ContainerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().onAppear {
                UIPageControl.appearance().currentPageIndicatorTintColor = .systemGreen
                    UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
            }
        }
    }
}
