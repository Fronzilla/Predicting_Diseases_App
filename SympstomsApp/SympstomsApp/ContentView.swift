//
//  ContentView.swift
//  SympstomsApp
//
//  Created by Alexey Nikitin on 02.05.2020.
//  Copyright © 2020 Alexey Nikitin. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @State private var usedWord = [String]()
    @State private var  rootWord = ""
    @State private var newWord = ""
    
    
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
                    
                    let dictionary = Dictionary(uniqueKeysWithValues: zip(self.usedWord.indices, self.usedWord))
                    
                    let converted = dictionary.map{[String($0) : String($1)]}

                    
                    let jsonData = try? JSONSerialization.data(withJSONObject: converted, options: [])
                    
                    print(jsonData)
                    
                    guard let url = URL(string: "http://127.0.0.1:5000/getdiagnosis") else {return}
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.httpBody = jsonData
                    
                    let session = URLSession.shared
                    session.dataTask(with: request) { (data, response, error ) in
                        
                        if let data = data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                                print(json)
                            } catch {
                                print(error)
                            }
                        }
                    }.resume()
                        
                    print(dictionary)
                }
            }
        .navigationBarTitle(rootWord)
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



