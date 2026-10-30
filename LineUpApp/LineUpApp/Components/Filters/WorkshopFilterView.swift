// xcode: set sdk=iOS

//
//  ActivityFilterBar.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct WorkshopFilterView: View {
    
    let dates : [String]
    let categories : [Category]
    let availabilities : [Availability]
    
    // ensemble de chaînes de caractères uniques
    @State private var selectedDates: Set<String> = []
    @State private var selectedCategories: Set<Category> = []
    @State private var selectedAvailabilities: Set<Availability> = []
    
    var body: some View {
        
        VStack {
            
            VStack {
                Text("Dates")
                
                          
            }
            
            VStack {
                Text("Catégories")

            }
            
            VStack {
                Text("Disponibilité")

            }
            
        }
    }
}

#Preview {
    
}
