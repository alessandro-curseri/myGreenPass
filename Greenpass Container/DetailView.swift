//
//  DetailView.swift
//  Greenpass Container
//
//  Created by Alessandro Curseri on 08/08/21.
//

import SwiftUI
import UIKit
struct DetailView: View {
    @State var greenPass: GreenPassContainerModel
    @State var greenColor = Color.green
    @Binding var dismissFlag : Bool
    @ObservedObject var dm = DataManager.shared
    @State var items = [Any]()
    var body: some View {
        NavigationView {
            VStack {
                mainView
              
                Divider()
                buttons
            }
       
            .navigationTitle(Text(greenPass.fullName))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(color: self.$greenColor)
            .navigationBarItems(trailing: dismissButton)
        }
    }
    var mainView : some View {
    ScrollView {
        HStack {
        VStack(alignment: .leading, spacing: 1) {
        Text(loc("FLNAME"))
            .fontWeight(.bold)
        Text(greenPass.fullName)
            .font(.largeTitle)
            .fontWeight(.black)
            .foregroundColor(.green)
        }
            Spacer()
        }.padding(.leading, 20)
        HStack {
        VStack(alignment: .leading, spacing: 1) {
        Text(loc("GP:"))
            .fontWeight(.bold)
            .padding(.leading, 20)
            HStack {
                Spacer()
            Image(uiImage: greenPass.realQrcode ?? #imageLiteral(resourceName: "qrcode"))
                .resizable()
                .frame(minWidth: 0, maxWidth: .infinity)
                .scaledToFit()
                Spacer()
            }.padding(.top)
            .padding(.bottom)
            .padding(.leading, 10)
        }
            Spacer()
        }
        .padding(.top)
        HStack {
        VStack(alignment: .leading, spacing: 1) {
        Text(loc("DTBIRTH"))
            .fontWeight(.bold)
        Text(greenPass.dateOfBirth)
            .fontWeight(.bold)
            .font(.title3)
            .foregroundColor(.green)
        }
            Spacer()
        }.padding(.leading, 20)
        
        HStack {
        VStack(alignment: .leading, spacing: 1) {
        Text(loc("CTRTYPE"))
            .fontWeight(.bold)
            Text(greenPass.type)
            .fontWeight(.bold)
            .font(.title3)
            .foregroundColor(.green)
        }
            Spacer()
        }.padding(.leading, 20)
        .padding(.top)
    }.padding(.vertical)
}
    var buttons : some View {
        HStack {
            buttonTrash
            Spacer()
            buttonShare
            
        }.frame(height: 50)
        .padding(.horizontal, 20)
    }
    var buttonTrash : some View {
        Button(action: {
            self.dismissFlag = false
            TapticManager.shared.mediumImpact()
            self.dm.selection = 0
            
            
            delay(0.7) {
                self.dm.deleteGreenPass(greenPass)
            }
            
            
           
        }, label: {
            Image(systemName: "trash")
                .foregroundColor(.red)
                .font(.system(size: 28))
        })
    }
    var buttonShare : some View {
        Button(action: {
            TapticManager.shared.mediumImpact()
            self.items = [GreenPassRowView(greenPass: greenPass, isToSave: true).asUIImage()]
            self.share()
        }, label: {
            Image(systemName: "square.and.arrow.up")
                .foregroundColor(.blue)
                .font(.system(size: 28))
        })
    }
    func share() {
        let activityController = UIActivityViewController(activityItems: self.items,
                                                          applicationActivities: nil)
        UIApplication.shared.windows[1].rootViewController?.present(activityController, animated: true, completion: nil)
    }

    var dismissButton : some View {
        Button(action: {
            TapticManager.shared.lightImpact()
            self.dismissFlag = false
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 28))
//                .foregroundColor(.white)
            
        })
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(greenPass: GreenPassContainerModel(fullName: "Alessandro Curseri", dateOfBirth: "24/05/2006", qrcode: #imageLiteral(resourceName: "qrcode").pngData(), type: "Vaccination"), dismissFlag: .constant(true))
    }
}

