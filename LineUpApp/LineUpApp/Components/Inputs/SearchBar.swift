//
//  SearchBar.swift
//  LineUpApp
//
//  Created by Apprenant174 on 01/11/2026.
//

import SwiftUI

struct SearchBar: View {

    @Binding var input: String
    var placeholder: LocalizedStringResource = .searchPlaceholder

    @FocusState private var isFocused: Bool

    private var isIdle: Bool {
        input.isEmpty && !isFocused
    }

    var body: some View {

        HStack(spacing: Styles.gap) {

            Styles.searchIcon
                .resizable()
                .scaledToFit()
                .frame(width: Styles.iconSize, height: Styles.iconSize)

            TextField(text: $input, prompt: Text(placeholder).foregroundStyle(Styles.idleForeground.opacity(Styles.placeholderOpacity))) {
                
                Text(placeholder)
                
            }
            .lineupFont(Styles.textFont)
            .focused($isFocused)
            .submitLabel(.search)
            .autocorrectionDisabled()

            if !input.isEmpty {

                Button {
                    
                    input = ""
                    
                } label: {
                    
                    Styles.clearIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: Styles.iconSize, height: Styles.iconSize)
                        .foregroundStyle(Styles.iconColor)
                    
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("common.clear"))

            }

        }
        .padding(Styles.padding)
        .foregroundStyle(isIdle ?  Styles.idleForeground : Styles.foreground)
        .background {
            
            RoundedRectangle(cornerRadius: Styles.cornerRadius)
                .fill(isIdle ? Styles.idleFill : Styles.fill)
                .strokeBorder(Styles.border, lineWidth: Styles.lineWidth)
            
        }
        .overlay {
            
            RoundedRectangle(cornerRadius: Styles.cornerRadius + Styles.focusOffset)
                .strokeBorder(Styles.focusRing, lineWidth: Styles.focusLineWidth)
                .padding(-Styles.focusOffset)
                .opacity(isFocused ? 1 : 0)
            
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }

    }

}

fileprivate struct Styles {

    static let cornerRadius = AppToken.Radius.small
    static let padding = AppToken.Padding.field
    static let gap = AppToken.Spacing.s8
    static let lineWidth = AppToken.Border.thin

    static let focusRing = AppColor.Button.focusRing
    static let focusOffset = AppToken.FocusRing.offset
    static let focusLineWidth = AppToken.Border.medium

    static let textFont: AppFont = .Input.fieldText
    static let placeholderOpacity: Double = 0.8

    static let idleFill = Color.tealPrimary
    static let fill = Color.ink
    static let border = Color.inkLight.opacity(placeholderOpacity)
    static let idleForeground = Color.inkLight
    static let foreground = AppColor.Text.secondary
    static let iconColor = foreground
    
    static let iconSize = AppToken.Scale.primitive16
    static let searchIcon = AppImage.Icon.search.image
    static let clearIcon = AppImage.Icon.xCircled.image

}

#Preview {

    @Previewable @State var query = ""

    SearchBar(input: $query)
        .padding()

}
