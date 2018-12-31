import Foundation

public struct Transition {
    let style: Style
    enum Style {
        case none
        case fadeIn(duration: TimeInterval)
    }

    private init(style: Style) {
        self.style = style
    }

    public static var none: Transition {
        return Transition(style: .none)
    }

    public static var fadeIn: Transition {
        return fadeIn()
    }

    public static func fadeIn(duration: TimeInterval = 0.2) -> Transition {
        return Transition(style: .fadeIn(duration: duration))
    }
}
