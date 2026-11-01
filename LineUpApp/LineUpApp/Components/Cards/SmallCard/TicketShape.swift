//
//  TicketShape.swift
//  LineUpApp
//
//  Created by Apprenant174 on 01/11/2026.
//

import SwiftUI

struct Ticket: View {
    
    let stubWidth: CGFloat
    let isMuted: Bool
    
    var body: some View {
        
        TicketShape(
            stubWidth: stubWidth,
            cornerRadius: Styles.cornerRadius,
            junctionRadius: Styles.junctionRadius
        )
        .fill(isMuted ? Styles.fillMuted : Styles.fill)
        .strokeBorder(isMuted ? Styles.borderMuted : Styles.border, lineWidth: Styles.lineWidth)
        .overlay {
            TicketPerforation(x: stubWidth, inset: Styles.perforationInset)
                .stroke(Styles.perforationColor, style: StrokeStyle(lineWidth: Styles.lineWidth, dash: Styles.perforationDash))
        }
        
    }
    
}

// MARK: Formes
fileprivate struct TicketShape: InsettableShape {
    
    let stubWidth: CGFloat
    let cornerRadius: CGFloat
    let junctionRadius: CGFloat
    var insetAmount: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        let x = rect.minX + stubWidth
        let r = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let all = max(0, cornerRadius - insetAmount)
        
        var path = Path()
        path.move(to: CGPoint(x: r.minX, y: r.midY))
        
        // Haut : coin du talon, pincement, coin du corps
        path.addArc(tangent1End: CGPoint(x: r.minX, y: r.minY), tangent2End: CGPoint(x: x, y: r.minY), radius: all)
        path.addArc(tangent1End: CGPoint(x: x, y: r.minY), tangent2End: CGPoint(x: x, y: r.maxY), radius: all)
        path.addArc(tangent1End: CGPoint(x: x, y: r.minY), tangent2End: CGPoint(x: r.maxX, y: r.minY), radius: all)
        path.addArc(tangent1End: CGPoint(x: r.maxX, y: r.minY), tangent2End: CGPoint(x: r.maxX, y: r.maxY), radius: all)
        
        // Bas : coin du corps, pincement, coin du talon
        path.addArc(tangent1End: CGPoint(x: r.maxX, y: r.maxY), tangent2End: CGPoint(x: x, y: r.maxY), radius: all)
        path.addArc(tangent1End: CGPoint(x: x, y: r.maxY), tangent2End: CGPoint(x: x, y: r.minY), radius: all)
        path.addArc(tangent1End: CGPoint(x: x, y: r.maxY), tangent2End: CGPoint(x: r.minX, y: r.maxY), radius: all)
        path.addArc(tangent1End: CGPoint(x: r.minX, y: r.maxY), tangent2End: CGPoint(x: r.minX, y: r.minY), radius: all)
        
        path.closeSubpath()
        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}

fileprivate struct TicketPerforation: Shape {
    
    let x: CGFloat
    let inset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX + x, y: rect.minY + inset))
            path.addLine(to: CGPoint(x: rect.minX + x, y: rect.maxY - inset))
        }
    }
}

// MARK: Style
fileprivate struct Styles {
    
    // Forme
    static let cornerRadius = AppToken.Radius.small
    static let junctionRadius: CGFloat = 16
    
    // Perforation
    static let perforationInset: CGFloat = 12
    static let perforationDash: [CGFloat] = [6, 4]
    static let perforationColor: Color = AppColor.Text.tertiary // gris clair, à remplacer par ton token
    
    // Couleurs
    static let fill: Color = AppColor.Card.Standard.background
    static let fillMuted: Color = AppColor.Card.Muted.background
    static let border = AppColor.Card.Standard.border
    static let borderMuted = AppColor.Card.Muted.border
    static let lineWidth = AppToken.Border.thin
    
}

#Preview {
    VStack(spacing: 16) {
        Ticket(stubWidth: 80, isMuted: false)
            .frame(height: 125)
        Ticket(stubWidth: 80, isMuted: true)
            .frame(height: 125)
    }
    .padding()
}
