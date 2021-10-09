//
//  GreenPassContainerModel.swift
//  Greenpass Container
//
//  Created by Alessandro Curseri on 08/08/21.
//

import SwiftUI
import Combine

class GreenPassContainerModel: Codable, Identifiable, Equatable, Hashable {
   
    var id: UUID = UUID()
    var fullName : String
    var dateOfBirth : String
    var qrcode : Data?
    var type : String
    var realQrcode : UIImage? {
        let realImg = UIImage(data: qrcode ?? Data())
        return realImg
    }
    
    init(fullName : String, dateOfBirth : String, qrcode : Data?, type: String) {
        self.fullName = fullName
        self.dateOfBirth = dateOfBirth
        self.qrcode = qrcode
        self.type = type
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: GreenPassContainerModel, rhs: GreenPassContainerModel) -> Bool {
        lhs.id.uuidString == rhs.id.uuidString
    }
    
}
