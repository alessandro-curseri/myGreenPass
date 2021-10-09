//
//  EditView.swift
//  Greenpass Container
//
//  Created by Alessandro Curseri on 09/08/21.
//

import SwiftUI

struct EditView: View {
    @ObservedObject var dm = DataManager.shared
    @State var greenColor = Color.green
    @Binding var dismissFlag : Bool
    @State private var editMode = EditMode.active
    var body: some View {
        NavigationView {
            List {
                ForEach(self.dm.storage, id: \.self) { greenPass in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(greenPass.fullName)
                        Text(greenPass.dateOfBirth)
                            .foregroundColor(greenColor)
                            .font(.callout)
                    }.padding(.vertical, 5)
                    
                    
                }.onDelete(perform: delete)
                .onMove(perform: move)
            }
            .environment(\.editMode, $editMode)
                .navigationTitle(loc("EDTGPS"))
                .navigationBarColor(color: self.$greenColor)
                .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: customEditButton, trailing: dismissButton)
                
        }
        
    }
    var customEditButton : some View {
        Button {
            switch editMode {
            case .active: editMode = .inactive
            case .inactive: editMode = .active
            default: break
            }
        } label: {
            if let isEditing = editMode.isEditing, isEditing {
                Text(loc("DN"))
            } else {
                Text(loc("EDT"))
            }
        }
    }
    var dismissButton : some View {
        Button(action: {
            TapticManager.shared.lightImpact()
            self.dismissFlag = false
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 28))
            
        })
    }
    func delete(at offset: IndexSet) {
       guard let intindex = Array(offset).first else { return }
       self.dm.deleteGreenPass(self.dm.storage[intindex])
   }
    func move(source: IndexSet, destination: Int) {
       self.dm.moveGreenPass(source: source, destination: destination)
       }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(dismissFlag: .constant(true))
    }
}
