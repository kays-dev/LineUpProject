//
//  FilterButtonReset.swift
//  LineUpApp
//
//  Created by Apprenant131 on 31/10/2026.
//

import SwiftUI

struct FilterButtonReset: View {
    var body: some View {
        
        Button {
            
        } label : {
            
            HStack(spacing: AppToken.Spacing.s4) {
                Spacer()
                
                Text("Reinitialiser".uppercased())
                    .foregroundStyle(AppColor.Text.secondary)
                AppImage.Icon.trash.image
                    .foregroundStyle(AppColor.ModalFilters.Delete.icon)
            }
        }
        .font(AppFont.Body.section.font)
    }
}

#Preview {
    ZStack {
        Color.ink.ignoresSafeArea()
        FilterButtonReset()
    }
}
