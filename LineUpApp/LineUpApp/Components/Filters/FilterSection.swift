//
//  FilterSection.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct FilterSection: View {
    let title: String
    let icon: Image
    // dates catégories ou disponibilités
    let items: [String]
    // enfant de WorshopFilter qui contient la selection
    @Binding var selection: Set<String>

    private let columns = [
        GridItem(.adaptive(minimum: 120), spacing: AppToken.Spacing.s12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: AppToken.Spacing.s16) {
            FilterHeader(
                title: title,
                icon: icon,
                font: AppFont.Label.label.font
            )

            LazyVGrid(columns: columns, spacing: AppToken.Spacing.s12) {
                ForEach(items, id: \.self) { item in
                    FilterCapsule(
                        title: item,
                        isSelected: selection.contains(item)
                    )
                    .onTapGesture {
                        if selection.contains(item) {
                            selection.remove(item)
                        } else {
                            selection.insert(item)
                        }
                    }
                }
            }
            
            FilterButtonReset()
            
        }
    }
}

#Preview {

// déclare un state dans la preview
@Previewable @State var selection: Set<String> = ["Danse", "Musique"]

    ZStack {
        Color.ink
        .ignoresSafeArea()

        FilterSection(
            title: "test",
            icon: AppImage.Icon.check.image,
            items: ["Danse", "Yoga", "Musique", "Théâtre", "Cirque"],
            selection: $selection
        )
    }
}
