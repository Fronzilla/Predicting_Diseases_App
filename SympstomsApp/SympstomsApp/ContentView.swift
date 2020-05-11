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
    
    // store here every symptom we work with
    @State private var diagsosysList: [String] = ["abdominal pain", "abnormal menstruation", "acidity", "acute liver failure", "altered sensorium", "anxiety", "back pain", "belly pain", "blackheads", "bladder discomfort", "blister", "blood in sputum", "bloody stool", "blurred and distorted vision", "breathlessness", "brittle nails", "bruising", "burning micturition", "chest pain", "chills", "cold hands and feets", "coma", "congestion", "constipation", "continuous feel of urine", "continuous sneezing", "cough", "cramps", "dark urine", "dehydration", "depression", "diarrhoea", "dischromic  patches", "distention of abdomen", "dizziness", "drying and tingling lips", "enlarged thyroid", "excessive hunger", "extra marital contacts", "family history", "fast heart rate", "fatigue", "fluid overload", "foul smell of urine", "headache", "high fever", "hip joint pain", "history of alcohol consumption", "increased appetite", "indigestion", "inflammatory nails", "internal itching", "irregular sugar level", "irritability", "irritation in anus", "itching", "joint pain", "knee pain", "lack of concentration", "lethargy", "loss of appetite", "loss of balance", "loss of smell", "malaise", "mild fever", "mood swings", "movement stiffness", "mucoid sputum", "muscle pain", "muscle wasting", "muscle weakness", "nausea", "neck pain", "nodal skin eruptions", "obesity", "pain behind the eyes", "pain during bowel movements", "pain in anal region", "painful walking", "palpitations", "passage of gases", "patches in throat", "phlegm", "polyuria", "prominent veins on calf", "puffy face and eyes", "pus filled pimples", "receiving blood transfusion", "receiving unsterile injections", "red sore around nose", "red spots over body", "redness of eyes", "restlessness", "runny nose", "rusty sputum", "scurring", "shivering", "silver like dusting", "sinus pressure", "skin peeling", "skin rash", "slurred speech", "small dents in nails", "spinning movements", "spotting  urination", "stiff neck", "stomach bleeding", "stomach pain", "sunken eyes", "sweating", "swelled lymph nodes", "swelling joints", "swelling of stomach", "swollen blood vessels", "swollen extremeties", "swollen legs", "throat irritation", "toxic look (typhos)", "ulcers on tongue", "unsteadiness", "visual disturbances", "vomiting", "watering from eyes", "weakness in limbs", "weakness of one body side", "weight gain", "weight loss", "yellow crust ooze", "yellow urine", "yellowing of eyes", "yellowish skin"]


    var body: some View {
        List{
            Rectangle()
                .frame(width: 150, height: 5)
                .foregroundColor(.gray)
                .cornerRadius(10)
                .opacity(50)
            HStack{
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                
                Text("How does diagnostic prediction work?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(25)

            }
            Text("This app tries to predict medical diagnosys by given symptoms. Add some of following symptoms and click button 'Get Diagnosys'. Be careful while adding symptoms to list, don't make gramma mistakes, since it works only with sypmtoms from the list. The more symptoms you add, more accurate prediction will be. It currently works with the given symptoms:")
            
            ForEach(diagsosysList, id: \.self) { symptom in
                Text(symptom)
                 
            }
            
                .multilineTextAlignment(.leading)
                .lineSpacing(10)
            Spacer()
        }
        .padding(20)
    }
}

struct SheetView_Previews: PreviewProvider {
    static var previews: some View {
        SheetView()
    }
}


struct Diagnosys: Codable{
       var status: String
        var diagnosis: String
       
}

struct DiagnosisView: View {
    let text: Text
    var body: some View {
        text
    }
}

struct ContentView: View {
    
    @State private var usedWord = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var showDiagnosys = ""
    @State private var showSheet = false
    @State private var showDetail = false
    
    
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
                        
                }.sheet(isPresented: $showSheet, content: {DiagnosisView(text: Text(self.showDiagnosys))})
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(.infinity)
            
            }
                    
        .navigationBarTitle(rootWord)
            .navigationBarItems(trailing: Button(action: { self.showDetail = true
            }) {
            Text("How it works?")
            Image(systemName: "ellipses.bubble")
            .imageScale(.large)
                }.sheet(isPresented: $showDetail, content: {SheetView()}))
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
