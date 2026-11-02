//
//  FormInput.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import SwiftUI

struct FormInput: View {
    
    let placeholder: LocalizedStringResource
    
    @Binding var input: String
    var icon: Image? = nil
    
    var validation: ValidationStage = .neutral
    private var isValidating: Bool {
        
        if case .neutral = validation {
            
            false
            
        } else {
            
            true
            
        }
        
    }
    
    @FocusState private var isFocused: Bool
    @Environment(\.isEnabled) private var isEnabled
    
    private var styles: Styles {
        Styles(validation: validation, isEnabled: isEnabled)
    }
    
    var body: some View {

        VStack(alignment: .leading, spacing: Styles.messageGap) {

            HStack(spacing: Styles.gap) {

                // Icône de gauche
                if let icon {

                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: Styles.iconSize, height: Styles.iconSize)

                }

                TextField(text: $input, prompt: Text(placeholder).foregroundStyle(styles.foreground.opacity(Styles.placeholderOpacity))) {
                    
                    Text(placeholder)
                    
                }
                .lineupFont(Styles.font)
                .focused($isFocused)

                // Icône de droite
                if !input.isEmpty, isFocused || !isValidating {

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

                } else if case .valid = validation {

                    Styles.validIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: Styles.iconSize, height: Styles.iconSize)
                        .foregroundStyle(Styles.validColor)

                } else if case .invalid = validation {

                    Styles.invalidIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: Styles.iconSize, height: Styles.iconSize)
                        .foregroundStyle(Styles.invalidColor)

                }

            }
            .padding(Styles.padding)
            .foregroundStyle(styles.foreground)
            .background {
                
                RoundedRectangle(cornerRadius: Styles.cornerRadius)
                    .fill(styles.fill)
                    .strokeBorder(styles.border, lineWidth: Styles.lineWidth)
                
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

            // Message d'erreur
            if case .invalid(let message) = validation {

                Text(message)
                    .lineupFont(Styles.messageFont)
                    .foregroundStyle(Styles.message)

            }

        }

    }
    
    enum ValidationStage {
        
        case neutral
        case valid
        case invalid(message: LocalizedStringResource)
        
    }
    
}

fileprivate struct Styles {

    // Styles variables
    let fill: Color
    let border: Color
    let foreground: Color
    
    // Styles fixes
    static let font: AppFont = .Input.fieldText
    static let messageFont: AppFont = .Body.caption
    
    static let cornerRadius = AppToken.Radius.small
    static let padding = AppToken.Padding.field
    static let gap = AppToken.Spacing.s8
    static let messageGap = AppToken.Spacing.s4
    static let lineWidth = AppToken.Border.thin
    
    static let focusRing = AppColor.Button.focusRing
    static let focusOffset = AppToken.FocusRing.offset
    static let focusLineWidth = AppToken.Border.medium

    static let validColor = Color.validationDark
    static let invalidColor = Color.dangerSaturated
    static let message = Color.dangerDark
    static let iconColor = AppColor.Text.tertiary
    static let placeholderOpacity: Double = 0.8

    static let iconSize = AppToken.Scale.primitive16
    static let clearIcon = AppImage.Icon.xCircled.image
    static let validIcon = AppImage.Icon.check.image
    static let invalidIcon = AppImage.Icon.close.image

    init(validation: FormInput.ValidationStage, isEnabled: Bool) {

        if !isEnabled {

            fill = AppColor.Card.Muted.background
            border = AppColor.Card.Muted.border
            foreground = AppColor.Text.tertiary

        } else {

            fill = AppColor.Card.Standard.background
            foreground = AppColor.Text.primary

            switch validation {
                
            case .neutral: border = AppColor.Card.Standard.border
            case .valid:   border = Styles.validColor
            case .invalid: border = Styles.invalidColor
                
            }

        }

    }

}

#Preview {

    @Previewable @State var name = ""
    @Previewable @State var email = "krystal@lineup.fr"

    VStack(spacing: 24) {

        FormInput(placeholder: .searchPlaceholder, input: $name, icon: AppImage.Icon.waiting.image)

        FormInput(placeholder: .searchPlaceholder, input: $email, icon: AppImage.Icon.waiting.image, validation: .valid)

        FormInput(placeholder: .searchPlaceholder, input: $email, icon: AppImage.Icon.waiting.image, validation: .invalid(message: "Message"))

        FormInput(placeholder: .searchPlaceholder, input: $name, icon: AppImage.Icon.waiting.image)
            .disabled(true)

    }
    .padding()

}
