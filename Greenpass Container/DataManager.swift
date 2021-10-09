//
//  ReadQR.swift
//  Greenpass Container
//
//  Created by Alessandro Curseri on 08/08/21.
//

//
//  ReadQR.swift
//  GreenPass Container
//
//  Created by Alessandro Curseri on 08/08/21.
//

import SwiftUI
import Foundation
import UIKit
import AVFoundation
import SwiftDGC
import CertLogic
import FloatingPanel
import Combine
class DataManager : ObservableObject {
    static let shared = DataManager()
    
    init() {
        self.caricaDati()
    }
    
    let objectWillChange = ObservableObjectPublisher()
    var selection = 0 {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
                
            }
        }
    }
    var hCert = HCert(from: "")

    func draw() {
        
      guard let hCert = hCert else {
        TapticManager.shared.error()
        return
      }
        TapticManager.shared.success()
      var validity = hCert.validity
        validity = validateCertLogicRules()
        addGreenPass(hcert: hCert)
//        print(validity)
//        print(hCert.fullName)
//        print(hCert.appType)
//        print(hCert.body)
//        print(hCert.cryptographicallyValid)
//        print(hCert.dateOfBirth)
//        print(hCert.exp)
//        print(hCert.fullPayloadString)
//        print(hCert.info.map{$0})
//        print(hCert.issCode)
        
        
    }

    func getCertificationType(type: SwiftDGC.HCertType) -> CertificateType {
      var certType: CertificateType = .general
      switch type {
      case .recovery:
        certType = .recovery
      case .test:
        certType = .test
      case .vaccine:
        certType = .vaccination
      case .unknown:
        certType = .general
      }
      return certType
    }
    func validateCertLogicRules() -> HCertValidity {
        print("muuu")
              var validity: HCertValidity = .valid
      guard let hCert = hCert else {
        return validity
      }
      let certType = getCertificationType(type: hCert.type)
      if let countryCode = hCert.ruleCountryCode {
        let valueSets = ValueSetsDataStorage.sharedInstance.getValueSetsForExternalParameters()
        let filterParameter = FilterParameter(validationClock: Date(),
                                              countryCode: countryCode,
                                              certificationType: certType)
        let externalParameters = ExternalParameter(validationClock: Date(),
                                                   valueSets: valueSets,
                                                   exp: hCert.exp,
                                                   iat: hCert.iat,
                                                   issuerCountryCode: hCert.issCode,
                                                   kid: hCert.kidStr)
        let result = CertLogicEngineManager.sharedInstance.validate(filter: filterParameter, external: externalParameters,
                                                                    payload: hCert.body.description)
        let failsAndOpen = result.filter { validationResult in
          return validationResult.result != .passed
        }
        if failsAndOpen.count > 0 {
          validity = .ruleInvalid
          var section = InfoSection(header: "Possible limitation", content: "Country rules validation failed")
          var listOfRulesSection: [InfoSection] = []
          result.sorted(by: { vdResultOne, vdResultTwo in
            vdResultOne.result.rawValue < vdResultTwo.result.rawValue
          }).forEach { validationResult in
            if let error = validationResult.validationErrors?.first {
              switch validationResult.result {
              case .fail:
                listOfRulesSection.append(InfoSection(header: "CirtLogic Engine error",
                                                      content: error.localizedDescription,
                                                      countryName: hCert.ruleCountryCode,
                                                      ruleValidationResult: SwiftDGC.RuleValidationResult.error))
              case .open:
                listOfRulesSection.append(InfoSection(header: "CirtLogic Engine error",
                                                      content: l10n(error.localizedDescription),
                                                      countryName: hCert.ruleCountryCode,
                                                      ruleValidationResult: SwiftDGC.RuleValidationResult.open))
              case .passed:
                listOfRulesSection.append(InfoSection(header: "CirtLogic Engine error",
                                                      content: error.localizedDescription,
                                                      countryName: hCert.ruleCountryCode,
                                                      ruleValidationResult: SwiftDGC.RuleValidationResult.passed))
              }
            } else {
              let preferredLanguage = Locale.preferredLanguages[0] as String
              let arr = preferredLanguage.components(separatedBy: "-")
              let deviceLanguage = (arr.first ?? "EN")
              var errorString = ""
              if let error = validationResult.rule?.getLocalizedErrorString(locale: deviceLanguage) {
                errorString = error
              }
              var detailsError = ""
              if let rule = validationResult.rule {
                 let dict = CertLogicEngineManager.sharedInstance.getRuleDetailsError(rule: rule,
                                                                                  filter: filterParameter)
                dict.keys.forEach({ key in
                      detailsError += key + ": " + (dict[key] ?? "") + " "
                })
                
              }
              switch validationResult.result {
              case .fail:
                listOfRulesSection.append(InfoSection(header: errorString,
                                                      content: detailsError,
                                                      countryName: hCert.ruleCountryCode,
                                                      ruleValidationResult: SwiftDGC.RuleValidationResult.error))
              case .open:
                listOfRulesSection.append(InfoSection(header: errorString,
                                                      content: detailsError,
                                                      countryName: hCert.ruleCountryCode,
                                                      ruleValidationResult: SwiftDGC.RuleValidationResult.open))
              case .passed:
                listOfRulesSection.append(InfoSection(header: errorString,
                                                      content: detailsError,
                                                      countryName: hCert.ruleCountryCode,
                                                      ruleValidationResult: SwiftDGC.RuleValidationResult.passed))
              }
            }
          }
          section.sectionItems = listOfRulesSection
          self.hCert?.makeSectionForRuleError(infoSections: section, for: .verifier)
//          self.infoTable.reloadData()
        }
      }
      return validity
    }
    
    
    var storage: [GreenPassContainerModel] = [] {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send() /// dice all'interfaccia di aggiornarsi
            }
        }
    }
    
    /// questo trick serve per decodificare un array di PizzaModel
    typealias Storage = [GreenPassContainerModel]
    
    /// questa var serve per contenere il percorso al file di salvataggio delle pizze
    lazy var filePath : String = ""
    func caricaDati() {
        
        /// creiamo il percorso al file
        filePath = cartellaDocuments() + "/greenpasses.plist"
        
        /// usiamo NSFileManager per sapere se esiste un file a quel percorso
        if FileManager.default.fileExists(atPath: filePath) {
            
            /// se c'è de-archiviamo il file di testo nell'array
            /// serve il blocco do try catch
            do {
                /// proviamo (try) a caricare il file dal percorso creato in precedenza
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                /// creiamo il decoder
                let decoder = PropertyListDecoder()
                /// proviamo (try) a decodificare il file nell'array
                storage = try decoder.decode(Storage.self, from: data)
            } catch {
                /// se non ce la fa stampiamo l'errore in console
                debugPrint(error.localizedDescription)
            }
            

        
        }
        else {
            let alexanderEvans = GreenPassContainerModel(fullName: "Alexander Evans", dateOfBirth: "1999-06-14", qrcode: #imageLiteral(resourceName: "qrcode").pngData(), type: "Test")
            storage.append(alexanderEvans)
            salva()
        }
    }
    func detectQRCode(_ image: UIImage?) {
        if let image = image, let ciImage = CIImage.init(image: image){
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            } else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            if let myfeatures = features {
                if !myfeatures.isEmpty {
                for case let row as CIQRCodeFeature in myfeatures{
                    
                    self.hCert = HCert(from: row.messageString ?? "")
                    self.draw()
                }
                } else {
                    TapticManager.shared.error()
                }
            } else {
                TapticManager.shared.error()
            }

        }
    }
    func addGreenPass(hcert: HCert) {
        /// facciamo una nuova istanza
        let greenPass = GreenPassContainerModel(fullName: hcert.fullName, dateOfBirth: hcert.dateOfBirth, qrcode: hcert.qrCode?.pngData(), type: toLanguage(getCertificationType(type: hcert.type).rawValue))
        print(greenPass.fullName)
        print(greenPass.dateOfBirth)
        print(greenPass.type)
        
        /// aggiungiamo la nuova istanza nell'Array
        storage.append(greenPass)
        self.objectWillChange.send()
        self.selection = self.storage.count - 1
        /// salviamo i dati
        salva()
        
    
    }
    func toLanguage(_ str: String) -> String {
        if Locale.current.languageCode == "en" {
            return str
        } else {
            switch str {
            case "Vaccination": return "Vaccinazione"
            case "Recovery": return "Guarigione"
            case "Test": return "Test"
            default: return "Generale"
            }
        }
        
    }
    func deleteGreenPass(_ greenPass: GreenPassContainerModel) {
        if let index = self.storage.firstIndex(where: {$0.id == greenPass.id}) {
            storage.remove(at: index)
            salva()
            self.objectWillChange.send()
        }
    }
    func moveGreenPass(source: IndexSet, destination: Int) {
        self.storage.move(fromOffsets: source, toOffset: destination)
        self.objectWillChange.send()
        self.salva()
    }
    func salva() {
        /// creiamo l'encoder necessario per salvare
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml // impostiamo l'output corretto
        /// serve il blocco do try catch
        do {
            /// proviamo a codificare l'array
            let data = try encoder.encode(storage)
            /// proviamo a salvare l'array codificato nel file
            try data.write(to: URL(fileURLWithPath: filePath))
        } catch {
            /// se non ce la fa scriviamo in console l'errore
            debugPrint(error.localizedDescription)
        }
    }
}



// MARK: External CertType from HCert type

