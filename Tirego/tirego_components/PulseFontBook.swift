import SwiftUI

extension Font {
    static func pulseRobotoRegular(
        size: CGFloat,
        relativeTo textStyle: TextStyle = .body
    ) -> Font {
        .custom("Roboto-Regular", size: size, relativeTo: textStyle)
    }

    static func pulseRobotoBold(
        size: CGFloat,
        relativeTo textStyle: TextStyle = .body
    ) -> Font {
        .custom("Roboto-Bold", size: size, relativeTo: textStyle)
    }

    static func flexCarterDisplay(
        size: CGFloat,
        relativeTo textStyle: TextStyle = .largeTitle
    ) -> Font {
        .custom("CarterOne", size: size, relativeTo: textStyle)
    }

    static func pulseButtonLabel(size: CGFloat = 19) -> Font {
        .pulseRobotoBold(size: size, relativeTo: .headline)
    }

    static func pulseBodyCaption(size: CGFloat = 13) -> Font {
        .pulseRobotoRegular(size: size, relativeTo: .caption)
    }

    static func pulseInputText(size: CGFloat = 16) -> Font {
        .pulseRobotoRegular(size: size, relativeTo: .body)
    }

    static func pulsePlaceholderText(size: CGFloat = 16) -> Font {
        .pulseRobotoRegular(size: size, relativeTo: .body)
    }

    static func flexHeroTitle(size: CGFloat = 32) -> Font {
        .flexCarterDisplay(size: size, relativeTo: .largeTitle)
    }
}
