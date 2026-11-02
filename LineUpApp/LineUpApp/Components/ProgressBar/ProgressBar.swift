//
//  ProgressBar.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import SwiftUI

struct ProgressBar: View {

    let status: ReservationStatus
    var levels: Levels = .two

    private var steps: [ReservationStatus] {

        switch levels {

        case .two:   [.pending, .validated]
        case .three: [.pending, .validated, .cancelled]

        }

    }

    private var currentIndex: Int {
        steps.firstIndex(of: status) ?? 0
    }

    var body: some View {

        VStack(alignment: .leading, spacing: Styles.labelGap) {

            HStack(alignment: .top, spacing: Styles.gap) {

                ForEach(steps.indices, id: \.self) { index in

                    let styles = Styles(step: steps[index], state: state(of: index))

                    // Ligne entre deux étapes
                    if index > 0 {

                        Capsule()
                            .fill(index <= currentIndex ? Styles.completedLine : Styles.pendingLine)
                            .frame(height: index <= currentIndex ? Styles.completedLineHeight : Styles.pendingLineHeight)
                            .frame(maxWidth: .infinity)
                            .frame(height: Styles.circleSize)

                    }

                    // Étape
                    VStack(spacing: Styles.stepGap) {

                        Styles.icon(for: steps[index])
                            .resizable()
                            .scaledToFit()
                            .frame(width: Styles.iconSize, height: Styles.iconSize)
                            .foregroundStyle(styles.iconColor)
                            .padding(Styles.iconPadding)
                            .background {

                                Circle()
                                    .fill(styles.fill)
                                    .strokeBorder(styles.border, lineWidth: styles.lineWidth)

                            }

                        Text(Styles.title(for: steps[index]))
                            .lineupFont(styles.font)
                            .opacity(styles.labelOpacity)
                            .fixedSize()

                    }
                    .frame(width: Styles.stepWidth)

                }

            }
            .padding(.horizontal, Styles.horizontalPadding)
            .foregroundStyle(Styles.foreground)

        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(Styles.title(for: status)))

    }

    private func state(of index: Int) -> StepState {

        if index < currentIndex {
            .passed
        } else if index == currentIndex {
            .current
        } else {
            .upcoming
        }

    }

    enum Levels {

        case two
        case three

    }

    enum StepState {

        case passed
        case current
        case upcoming

    }

}

fileprivate struct Styles {

    // Styles variables
    let fill: Color
    let border: Color
    let lineWidth: CGFloat
    let iconColor: Color
    let font: AppFont
    let labelOpacity: Double

    // Styles fixes
    static let labelFont: AppFont = .Label.label
    static let foreground = AppColor.Text.primary

    static let horizontalPadding = AppToken.Spacing.s8
    static let gap = AppToken.Spacing.s8
    static let stepGap = AppToken.Spacing.s8
    static let labelGap = AppToken.Spacing.s8

    static let stepWidth: CGFloat = 52
    static let iconSize = AppToken.Scale.primitive32
    static let iconPadding = AppToken.Spacing.s8
    static let circleSize = iconSize + iconPadding * 2

    static let completedLine = Color.ink
    static let pendingLine = Color.greenPrimary
    static let completedLineHeight: CGFloat = 4
    static let pendingLineHeight: CGFloat = 2

    static func icon(for status: ReservationStatus) -> Image {

        switch status {

        case .pending:   AppImage.InterfaceIcon.ellipsisDuotone.image
        case .validated: AppImage.InterfaceIcon.ticketDuotone.image
        case .cancelled: AppImage.InterfaceIcon.xMark.image

        }

    }

    static func title(for status: ReservationStatus) -> LocalizedStringResource {

        switch status {

        case .pending:   .bookingStatusPending
        case .validated: .bookingStatusApproved
        case .cancelled: .bookingStatusCancelled

        }

    }

    init(step: ReservationStatus, state: ProgressBar.StepState) {

        switch state {

        case .passed:

            fill = Color.ink
            border = Color.ink
            lineWidth = AppToken.Border.medium
            iconColor = AppColor.Text.secondary
            font = .Component.progressBar
            labelOpacity = 1

        case .current:

            lineWidth = AppToken.Border.medium
            font = .Component.progressBar
            labelOpacity = 1

            switch step {

            case .pending:
                fill = Color.grayLight
                border = Color.grayDarker
                iconColor = Color.grayDarker

            case .validated:
                fill = Color.validationLight
                border = Color.validationDark
                iconColor = Color.validationDark

            case .cancelled:
                fill = Color.dangerLight
                border = Color.dangerDark
                iconColor = Color.dangerDark

            }

        case .upcoming:

            fill = AppColor.Card.Standard.background
            border = Color.ink
            lineWidth = AppToken.Border.thin
            iconColor = Color.ink
            font = .Body.caption
            labelOpacity = 0.75

        }

    }

}

#Preview {

    VStack(spacing: 28) {

        ProgressBar(status: .pending, levels: .three)

        ProgressBar(status: .validated, levels: .three)

        ProgressBar(status: .cancelled, levels: .three)

        ProgressBar(status: .pending)

        ProgressBar(status: .validated)

    }
    .padding()

}
