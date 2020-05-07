//
//  ContentView.swift
//  SympstomsApp
//
//  Created by Alexey Nikitin on 02.05.2020.
//  Copyright © 2020 Alexey Nikitin. All rights reserved.
//

import SwiftUI
import Combine

struct SheetView: View {
    let text: Text
    var body: some View {
        text
    }
}
struct Diagnosys: Codable{
       var status: String
        var diagnosis: String

       
}
struct ContentView: View {
    
    @State private var usedWord = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var showDiagnosys = ""
    @State private var showSheet = false
    
    
    var body: some View {
        NavigationView{
            
            VStack{
                TextField("Enter your symptom", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none )
                    .padding()
                
                List {
                    ForEach(usedWord, id: \.self){
                    Text($0)
                    }
                    .onDelete(perform: deleteItem)
                }
                
                Button("Get diagnose"){
                    
                    // here we placed logic of sending request to API server
                    
                    self.showSheet.toggle()
                    
                    let dictionary = Dictionary(uniqueKeysWithValues: zip(self.usedWord.indices, self.usedWord))
                    
                    let converted = dictionary.map{[String($0) : String($1)]}

                    
                    let jsonData = try? JSONSerialization.data(withJSONObject: converted, options: [])
                    // localhost
                    guard let url = URL(string: "http://127.0.0.1:5000/getdiagnosis") else {return}
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.httpBody = jsonData
                    
                    let session = URLSession.shared
                    session.dataTask(with: request) { (data, response, error ) in
                        
                        if let data = data {
                            do {
                                _ = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                                
                                let decoder = JSONDecoder()
                                let model = try decoder.decode(Diagnosys.self, from:
                                             data)
                                
                                self.showDiagnosys = model.diagnosis
                                
                            } catch {
                                print(error)
                            }
                        }
                    }.resume()
                        
                }.sheet(isPresented: $showSheet, content: {SheetView(text: Text(self.showDiagnosys))})
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(.infinity)
            
            }
                    
        .navigationBarTitle(rootWord)
        .navigationBarItems(trailing: Button(action: {
        }) {
            Text("How it works?")
            Image(systemName: "ellipses.bubble")
            .imageScale(.large)
        })
            
        }
    }
     
    func addNewWord() {
        let answer = newWord.lowercased( ).trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {
            return
        }
        
        // extra validation to come
        usedWord.insert(answer, at: 0)
        newWord = ""
    }
    
     func deleteItem(at indexSet: IndexSet) {
        self.usedWord.remove(atOffsets: indexSet)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




