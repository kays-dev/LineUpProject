//
//  ScreenHeading.swift
//  LineUpApp
//
//  Created by Apprenant174 on 01/11/2026.
//

import SwiftUI

struct PageHeading<Trailing: View>: View {

    let mode: Mode
    @ViewBuilder let trailing: Trailing

    @Environment(\.dismiss) private var dismiss

    private var largeTitle: (heading: LocalizedStringResource, subtitle: LocalizedStringResource?)? {
        
        switch mode {
            
        case .primary:
            nil
            
        case .secondary(_, let heading, let subtitle), .tertiary(let heading, let subtitle):
            
            heading.map { ($0, subtitle) }
            
        }
        
    }

    var body: some View {
        
        VStack(alignment: .leading, spacing: Styles.gap) {

            // Barre du haut
            HStack(spacing: Styles.actionsGap) {
                
                switch mode {
                    
                case .primary(let heading):
                    
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        
                        Text(heading)
                        Text(".").foregroundStyle(Styles.dotColor)
                        
                    }
                    .lineupFont(Styles.headingFont)
                    .textCase(.uppercase)

                    Spacer()

                case .secondary(_, _, _):
                    
                    AppButton(type: .back) { dismiss() }
                    
                    Spacer()

                case .tertiary:
                    
                    Spacer()
                    
                    AppButton(title: "common.close", icon: Styles.closeIcon, type: .iconOutline) { dismiss() }
                    
                }

                trailing
                
            }
            .frame(height: Styles.rowHeight)
            .overlay {
                if case .secondary(let title, _, _) = mode {
                    Text(title)
                        .lineupFont(Styles.titleFont)
                        .lineLimit(1)
                        .padding(.horizontal, Styles.titleInset)
                }
            }

            // Grand titre (Secondary / Tertiary)
            if let largeTitle {
                
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    
                    Text(largeTitle.heading)
                    
                    Text(".").foregroundStyle(Styles.dotColor)
                    
                }
                .lineupFont(Styles.headingFont)

                if let subtitle = largeTitle.subtitle {
                    
                    Text(subtitle)
                        .lineupFont(Styles.subtitleFont)
                    
                }
                
            }
            
        }
        .foregroundStyle(Styles.foreground)
        .padding(.horizontal, Styles.horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }

    enum Mode {
        
        case primary(heading: LocalizedStringResource)
        
        case secondary(title: LocalizedStringResource, heading: LocalizedStringResource? = nil, subtitle: LocalizedStringResource? = nil)
        
        case tertiary(heading: LocalizedStringResource? = nil, subtitle: LocalizedStringResource? = nil)
        
    }
    
}

fileprivate struct Styles {

    static let horizontalPadding: CGFloat = AppToken.Scale.primitive20
    static let rowHeight = AppToken.Scale.primitive44
    static let gap = AppToken.Spacing.s16
    static let actionsGap = AppToken.Spacing.s8
    static let titleInset = rowHeight * 2 + actionsGap * 2

    static let headingFont: AppFont = .Title.heading
    static let titleFont: AppFont = .Body.body
    static let subtitleFont: AppFont = .Body.body2

    static let foreground = AppColor.Text.primary
    static let dotColor = Color.redPrimary

    static let closeIcon = AppImage.Icon.close.image
}

#Preview("Français") {
    
    VStack(spacing: 28) {
        
        PageHeading(mode: .primary(heading: .agendaTitle)) {
            
            HStack {
                
                
            }
        }

        PageHeading(mode: .secondary(title: .settingsTitle)) {}

        PageHeading(mode: .tertiary(heading: .cancelBookingTitle)) {}
        
    }
}

#Preview("Italiano") {
    
    PageHeading(mode: .primary(heading: .programTitle)) {}
        .environment(\.locale, Locale(identifier: "it"))
    
}
