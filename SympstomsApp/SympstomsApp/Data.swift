//
//  Data.swift
//  SympstomsApp
//
//  Created by Alexey Nikitin on 04.05.2020.
//  Copyright © 2020 Alexey Nikitin. All rights reserved.
//

import SwiftUI

struct Post: Codable, Identifiable {
    let id = UUID()
    var diagnosys: String
}

class Api {
    func getDiagnosys() {
        guard let url = URL(string: "http://127.0.0.1:5000/") else  {return}
        // localhost
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let posts = try! JSONDecoder().decode([Post].self, from: data!)
            print(posts)
        }.resume()
    }
    
}

