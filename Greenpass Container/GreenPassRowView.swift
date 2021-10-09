//
//  GreenPassRowView.swift
//  Greenpass Container
//
//  Created by Alessandro Curseri on 08/08/21.
//

import SwiftUI

struct GreenPassRowView: View {
   @State var isDetailOut = false
    @State var greenPass : GreenPassContainerModel
    @State var isToSave = false
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                if isToSave {
                    ZStack {
                        RoundedCorners(tl: 20, tr: 20, bl: 0, br: 0)
                            .frame(height: 60)
                            .foregroundColor(.green)
                            .padding(-20)
                        Text(loc("GP"))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }.padding(.bottom, 40)
                }
                Text(greenPass.fullName)
                    .font(.title)
                    .fontWeight(.bold)
                   
                Image(uiImage: greenPass.realQrcode ?? #imageLiteral(resourceName: "qrcode")) // todo
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.size.width/5*3)
                    .padding()
                HStack {
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(loc("DTBIRTH"))
                            .fontWeight(.bold)
                        Text(greenPass.dateOfBirth)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 1) {
                        Text(loc("CTRTYPE"))
                            .fontWeight(.bold)
                        Text(greenPass.type)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                }
                
                
            }
            .padding(20)
            .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.green, lineWidth: 1)
                    )
            
            .onTapGesture {
                TapticManager.shared.lightImpact()
                self.isDetailOut = true
            }
            .sheet(isPresented: self.$isDetailOut, content: {
                DetailView(greenPass: greenPass, dismissFlag: self.$isDetailOut)
            })
        }
        .padding(isToSave ? 15 : 30)
        
      
    }
}

struct GreenPassRowView_Previews: PreviewProvider {
    static var previews: some View {
        GreenPassRowView(greenPass: GreenPassContainerModel(fullName: "Alessandro Curseri", dateOfBirth: "24/05/2006", qrcode: #imageLiteral(resourceName: "qrcode").pngData(), type: "Vaccine"))
            .previewLayout(.sizeThatFits)
    }
}

