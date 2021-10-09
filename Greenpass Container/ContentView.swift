//
//  ContentView.swift
//  Greenpass Container
//
//  Created by Alessandro Curseri on 08/08/21.
//

import SwiftUI
import SwiftDGC
struct ContentView: View {
    @ObservedObject var dm = DataManager.shared
    @State var isActionSheetPresented = false
    @State var isPresentingScanner = false
    @State var isPresentingPhotos = false
    @State var isPresentingFile = false
    @State var isPresentingEdit = false
    @State var scannedCode: String?
    @State var greenColor = Color.green
    @State var image : UIImage = UIImage()
    var body: some View {
        NavigationView {
            Group {
            if self.isPresentingEdit == false {
            TabView(selection: self.$dm.selection) {
                if !self.dm.storage.isEmpty {
                        ForEach(Array(self.dm.storage.enumerated()), id: \.1) { index, greenPass in

                            GreenPassRowView(greenPass: greenPass)
                                
                                .tag(index)
                            
                        }
                } else {
                    Button(action: {
                        TapticManager.shared.mediumImpact()
                        self.isActionSheetPresented = true
                    }, label: {
                        Label(
                            title: {
                                Text(loc("IMPTGP"))
                                .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            },
                            icon: {
                                Image(systemName: "plus")
                                    .font(.system(size: 22))
                                .foregroundColor(.white)
                                
                            }
                        ).padding(20)
                        
                        .background(
                            RoundedRectangle(cornerRadius: 15.0).foregroundColor(.green)
                        )
                    })
                }
                
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: self.dm.storage.count < 2 ? .never : .always))
                    .id(self.dm.storage.count)
                    .sheet(isPresented: $isPresentingScanner) {
                        self.scannerSheet
                       
                    }
            }
            }.actionSheet(isPresented: self.$isActionSheetPresented, content: {
                ActionSheet(title: Text(loc("IMPTGP")), message: Text("SLCTWY"),  buttons: [
                    .default(Text(loc("CMR")), action: {
                        TapticManager.shared.lightImpact()
                        self.isPresentingScanner = true
                    }),
                    .default(Text(loc("PHTS")), action: {
                        TapticManager.shared.lightImpact()
                        self.isPresentingPhotos = true
                    }),
                    .default(Text(loc("FLS")), action: {
                        TapticManager.shared.lightImpact()
                        self.isPresentingFile = true
                    }),
                    .cancel()
                ])
            })
            .fileImporter(isPresented: $isPresentingFile, allowedContentTypes: [.image]) { (res) in
                do{
                    let fileUrl = try res.get()
                    print(fileUrl)
                    
                    guard fileUrl.startAccessingSecurityScopedResource() else { return }
                    if let imageData = try? Data(contentsOf: fileUrl),
                    let image = UIImage(data: imageData) {
                        self.dm.detectQRCode(image)
                        
                    }
                    fileUrl.stopAccessingSecurityScopedResource()
                } catch{
                    print ("error reading")
                    print (error.localizedDescription)
                }
            }
                    .navigationTitle(Text(loc("MYGP")))
            .navigationBarItems(leading: editButton, trailing: addButton)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarColor(color: self.$greenColor)
                }
    }
    var addButton : some View {
        Button(action: {
            TapticManager.shared.lightImpact()
            self.isActionSheetPresented = true
        }, label: {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 28))
            
        }).sheet(isPresented: self.$isPresentingPhotos, content: {
            ImagePickerView(sourceType: .photoLibrary) { image in
                self.dm.detectQRCode(image)
            }
        })
    }
    var editButton : some View {
        Button(action: {
            TapticManager.shared.lightImpact()
            self.isPresentingEdit = true
        }, label: {
           Text(loc("EDT"))
            .fontWeight(.bold)
            
        }).sheet(isPresented: self.$isPresentingEdit, content: {
            EditView(dismissFlag: self.$isPresentingEdit)
        })
    }
    var dismissButton : some View {
        Button(action: {
            TapticManager.shared.lightImpact()
            self.isPresentingScanner = false
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 28))
//                .foregroundColor(.white)
            
        })
    }
    var scannerSheet : some View {
        NavigationView {
            ZStack {
               
            CodeScannerView(
                codeTypes: [.qr],
                completion: { result in
                    if case let .success(code) = result {
                        self.dm.hCert = HCert(from: code)
                        self.dm.draw()
                        self.isPresentingScanner = false
                    }
                }
            ).edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                Image("scanner")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color("LightGray"))
                    .scaledToFit()
                    .padding(18)
                    
                    Spacer()
                }
                    
            }
            .navigationTitle(loc("QRCODERDR"))
            .navigationBarColor(color: self.$greenColor)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: dismissButton)
        }
            .edgesIgnoringSafeArea(.all)
        }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
