import SwiftUI
import UIKit

enum EchoDriftFontPrinter {
    static func printAllFonts() {
        #if DEBUG
        let echoDriftFamilyNames = UIFont.familyNames.sorted()

        print("========== EchoDrift Font Families ==========")
        for echoDriftFamilyName in echoDriftFamilyNames {
            print("Family: \(echoDriftFamilyName)")

            let echoDriftFontNames = UIFont.fontNames(forFamilyName: echoDriftFamilyName).sorted()
            for echoDriftFontName in echoDriftFontNames {
                print("  - \(echoDriftFontName)")
            }
        }

        print("========== EchoDrift Custom Font Check ==========")
        let echoDriftCustomFontNames = [
            "Roboto-Regular",
            "Roboto-Bold",
            "CarterOne",
            "CarterOne-Regular"
        ]

        for echoDriftFontName in echoDriftCustomFontNames {
            let echoDriftFontExists = UIFont(name: echoDriftFontName, size: 16) != nil
            print("\(echoDriftFontName): \(echoDriftFontExists ? "loaded" : "missing")")
        }
        #endif
    }
}
