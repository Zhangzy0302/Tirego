import SwiftUI
import Combine

@MainActor
final class BlazeNovaReportSheetHub: ObservableObject {
    @Published private(set) var blazeNovaShowsReportSheet = false

    private var blazeNovaReportAction: (() -> Void)?
    private var blazeNovaBlockAction: (() -> Void)?

    func blazeNovaShowReportSheet(
        blazeNovaReportAction: @escaping () -> Void,
        blazeNovaBlockAction: @escaping () -> Void
    ) {
        self.blazeNovaReportAction = blazeNovaReportAction
        self.blazeNovaBlockAction = blazeNovaBlockAction
        blazeNovaShowsReportSheet = true
    }

    func blazeNovaHideReportSheet() {
        blazeNovaShowsReportSheet = false
        blazeNovaReportAction = nil
        blazeNovaBlockAction = nil
    }

    func blazeNovaHandleReportAction() {
        let blazeNovaAction = blazeNovaReportAction
        blazeNovaHideReportSheet()
        blazeNovaAction?()
    }

    func blazeNovaHandleBlockAction() {
        let blazeNovaAction = blazeNovaBlockAction
        blazeNovaHideReportSheet()
        blazeNovaAction?()
    }
}
