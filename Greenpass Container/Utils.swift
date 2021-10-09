//
//  Utils.swift
//  Pizza List
//
//  Created by Marcello Catelli
//  Copyright © Swift srl. All rights reserved.
//

import SwiftUI
import UIKit
// metodi utili
func cartellaDocuments() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    debugPrint(paths[0])
    return paths[0]
}

func loc(_ localizedKey:String) -> String {
    return NSLocalizedString(localizedKey, comment: "")
}

func delay(_ delay:Double, closure:  @escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

/// MODIFICA WATCH
#if !os(watchOS)
extension UIApplication {
    
    func visibleViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return nil }
        guard let rootViewController = window.rootViewController else { return nil }
        return UIApplication.getVisibleViewControllerFrom(vc: rootViewController)
    }
    
    private static func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController,
            let visibleController = navigationController.visibleViewController  {
            return UIApplication.getVisibleViewControllerFrom( vc: visibleController )
        } else if let tabBarController = vc as? UITabBarController,
            let selectedTabController = tabBarController.selectedViewController {
            return UIApplication.getVisibleViewControllerFrom(vc: selectedTabController )
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIApplication.getVisibleViewControllerFrom(vc: presentedViewController)
            } else {
                return vc
            }
        }
    }
}

struct DisableModalDismiss: ViewModifier {
    let disabled: Bool
    func body(content: Content) -> some View {
        disableModalDismiss()
        return AnyView(content)
    }
    
    func disableModalDismiss() {
        guard let visibleController = UIApplication.shared.visibleViewController() else { return }
        visibleController.isModalInPresentation = disabled
    }
}
#endif

/// MODIFICA WATCH
#if os(iOS)
var isPad : Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}
#endif

/// MODIFICA WATCH
var isWatch : Bool {
    #if os(watchOS)
        return true
    #else
        return false
    #endif
}

/// MODIFICA MAC
var isMac : Bool {
    #if targetEnvironment(macCatalyst)
    return true
    #else
    return false
    #endif
}

#if !os(watchOS)
struct NavigationBarModifier: ViewModifier {
    var color: Binding<Color>
    @ObservedObject var dm = DataManager.shared
    init(color: Binding<Color>) {
        self.color = color
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = .white
//
    }
    
    func body(content: Content) -> some View {
           ZStack{
               content
               VStack {
                   GeometryReader { geometry in
                    self.color.wrappedValue
                           .frame(height: geometry.safeAreaInsets.top)
                           .edgesIgnoringSafeArea(.top)
                       Spacer()
                   }
               }.edgesIgnoringSafeArea(.horizontal)
           }
       }
}
extension View {
 
    func navigationBarColor(color: Binding<Color>) -> some View {
        self.modifier(NavigationBarModifier(color: color))
    }

}

#endif
extension View {
public func asUIImage() -> UIImage {
    let controller = UIHostingController(rootView: self)
    
    controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
    UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
    
    let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
    controller.view.bounds = CGRect(origin: .zero, size: size)
    controller.view.sizeToFit()
    
// here is the call to the function that converts UIView to UIImage: `.asImage()`
    let image = controller.view.asUIImage()
    controller.view.removeFromSuperview()
    return image
}
}
extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.size.width
        let h = rect.size.height

        // Make sure we do not exceed the size of the rectangle
        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)

        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)

        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

        return path
    }
}
class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let errore = error {
            print(errore.localizedDescription)
        } else {
            TapticManager.shared.success()
        }
    }
}
enum SheetType {
    case scan, edit
}

