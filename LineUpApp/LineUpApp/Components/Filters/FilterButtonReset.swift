//
//  FilterButtonReset.swift
//  LineUpApp
//
//  Created by Apprenant131 on 31/10/2026.
//

import SwiftUI

struct FilterButtonReset: View {
    
let viewModel: WorkshopFiltersViewModel
    
    var body: some View {
        
        Button {
            viewModel.resetFilters()
            
            // Test
            print("Dates après réinitialisation :", viewModel.selectedPeriods)
            print("Catégories après réinitialisation :", viewModel.selectedCategories)
            print("Disponibilité après réinitialisation :", viewModel.selectedAvailability as Any)
            
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
    let viewModel = WorkshopFiltersViewModel(
        workshopStore: WorkshopStore(
            workshopService: WorkshopService(
                apiClient: APIClient(
                    baseURL: URL(string: "http://localhost:8080")!,
                    keychain: KeychainService()
                )
            )
        )
    )

    ZStack {
        Color.ink
            .ignoresSafeArea()

        FilterButtonReset(viewModel: viewModel)
    }
}
