import SwiftUI

// MARK: - Book Icon (Schedule)
struct BookIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        // Left page
        p.move(to: CGPoint(x: w * 0.5, y: h * 0.15))
        p.addLine(to: CGPoint(x: w * 0.08, y: h * 0.2))
        p.addLine(to: CGPoint(x: w * 0.08, y: h * 0.85))
        p.addLine(to: CGPoint(x: w * 0.5, y: h * 0.9))
        p.closeSubpath()
        // Right page
        p.move(to: CGPoint(x: w * 0.5, y: h * 0.15))
        p.addLine(to: CGPoint(x: w * 0.92, y: h * 0.2))
        p.addLine(to: CGPoint(x: w * 0.92, y: h * 0.85))
        p.addLine(to: CGPoint(x: w * 0.5, y: h * 0.9))
        p.closeSubpath()
        // Spine
        p.move(to: CGPoint(x: w * 0.5, y: h * 0.1))
        p.addLine(to: CGPoint(x: w * 0.5, y: h * 0.92))
        return p
    }
}

// MARK: - Checklist Icon (Tasks)
struct ChecklistIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        // Check mark 1
        p.move(to: CGPoint(x: w * 0.1, y: h * 0.25))
        p.addLine(to: CGPoint(x: w * 0.2, y: h * 0.35))
        p.addLine(to: CGPoint(x: w * 0.35, y: h * 0.15))
        // Line 1
        p.move(to: CGPoint(x: w * 0.45, y: h * 0.25))
        p.addLine(to: CGPoint(x: w * 0.9, y: h * 0.25))
        // Check mark 2
        p.move(to: CGPoint(x: w * 0.1, y: h * 0.55))
        p.addLine(to: CGPoint(x: w * 0.2, y: h * 0.65))
        p.addLine(to: CGPoint(x: w * 0.35, y: h * 0.45))
        // Line 2
        p.move(to: CGPoint(x: w * 0.45, y: h * 0.55))
        p.addLine(to: CGPoint(x: w * 0.9, y: h * 0.55))
        // Box 3
        p.addRect(CGRect(x: w * 0.1, y: h * 0.75, width: w * 0.2, height: h * 0.15))
        // Line 3
        p.move(to: CGPoint(x: w * 0.45, y: h * 0.825))
        p.addLine(to: CGPoint(x: w * 0.9, y: h * 0.825))
        return p
    }
}

// MARK: - Clock Icon (Timer)
struct ClockIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) * 0.45
        // Circle
        p.addEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
        // Hour hand
        p.move(to: center)
        p.addLine(to: CGPoint(x: center.x, y: center.y - r * 0.55))
        // Minute hand
        p.move(to: center)
        p.addLine(to: CGPoint(x: center.x + r * 0.4, y: center.y))
        return p
    }
}

// MARK: - Chart Icon (Stats)
struct ChartIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        // Bars
        p.addRect(CGRect(x: w * 0.1, y: h * 0.5, width: w * 0.15, height: h * 0.4))
        p.addRect(CGRect(x: w * 0.3, y: h * 0.2, width: w * 0.15, height: h * 0.7))
        p.addRect(CGRect(x: w * 0.5, y: h * 0.35, width: w * 0.15, height: h * 0.55))
        p.addRect(CGRect(x: w * 0.7, y: h * 0.1, width: w * 0.15, height: h * 0.8))
        // Base line
        p.move(to: CGPoint(x: w * 0.05, y: h * 0.9))
        p.addLine(to: CGPoint(x: w * 0.95, y: h * 0.9))
        return p
    }
}

// MARK: - Pencil Icon (Notes)
struct PencilIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        // Pencil body
        p.move(to: CGPoint(x: w * 0.7, y: h * 0.05))
        p.addLine(to: CGPoint(x: w * 0.9, y: h * 0.15))
        p.addLine(to: CGPoint(x: w * 0.3, y: h * 0.85))
        p.addLine(to: CGPoint(x: w * 0.1, y: h * 0.75))
        p.closeSubpath()
        // Tip
        p.move(to: CGPoint(x: w * 0.1, y: h * 0.75))
        p.addLine(to: CGPoint(x: w * 0.3, y: h * 0.85))
        p.addLine(to: CGPoint(x: w * 0.08, y: h * 0.95))
        p.closeSubpath()
        return p
    }
}

// MARK: - Plus Icon
struct PlusIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX
        let cy = rect.midY
        let s = min(rect.width, rect.height) * 0.35
        p.move(to: CGPoint(x: cx, y: cy - s))
        p.addLine(to: CGPoint(x: cx, y: cy + s))
        p.move(to: CGPoint(x: cx - s, y: cy))
        p.addLine(to: CGPoint(x: cx + s, y: cy))
        return p
    }
}

// MARK: - Tab Icon View
struct TabIconView: View {
    let shape: AnyShape
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            shape
                .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .frame(width: 24, height: 24)
            Text(label)
                .font(.caption2)
        }
    }
}

// Type-erased shape wrapper for iOS 15
struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    
    init<S: Shape>(_ shape: S) {
        _path = { rect in shape.path(in: rect) }
    }
    
    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

// MARK: - Shape to UIImage renderer
func shapeToImage<S: Shape>(_ shape: S, size: CGSize = CGSize(width: 28, height: 28), lineWidth: CGFloat = 1.8) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { ctx in
        let rect = CGRect(origin: .zero, size: size)
        let path = shape.path(in: rect).cgPath
        ctx.cgContext.setStrokeColor(UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1).cgColor)
        ctx.cgContext.setLineWidth(lineWidth)
        ctx.cgContext.setLineCap(.round)
        ctx.cgContext.setLineJoin(.round)
        ctx.cgContext.addPath(path)
        ctx.cgContext.strokePath()
    }.withRenderingMode(.alwaysTemplate)
}

// Pre-rendered tab icons
struct TabIcons {
    static let schedule = shapeToImage(BookIcon())
    static let tasks = shapeToImage(ChecklistIcon())
    static let timer = shapeToImage(ClockIcon())
    static let stats = shapeToImage(ChartIcon())
    static let notes = shapeToImage(PencilIcon())
}
