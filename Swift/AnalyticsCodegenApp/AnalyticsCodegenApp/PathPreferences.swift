import Foundation

enum PathPreferences {
    private static let defaults = UserDefaults.standard

    private enum Keys {
        static let lastCSVPath = "AnalyticsCodegen_lastCSVPath"
        static let lastOutputPath = "AnalyticsCodegen_lastOutputPath"
        static let lastInputMode = "AnalyticsCodegen_lastInputMode"
        static let lastGoogleSheetsURL = "AnalyticsCodegen_lastGoogleSheetsURL"
    }

    static func loadCSVPath() -> String? {
        defaults.string(forKey: Keys.lastCSVPath)
    }

    static func loadOutputPath() -> String? {
        defaults.string(forKey: Keys.lastOutputPath)
    }

    static func loadInputMode() -> InputMode? {
        guard let rawValue = defaults.string(forKey: Keys.lastInputMode) else {
            return nil
        }
        return InputMode(rawValue: rawValue)
    }

    static func loadGoogleSheetsURL() -> String? {
        defaults.string(forKey: Keys.lastGoogleSheetsURL)
    }

    static func store(csvPath: String, outputPath: String, inputMode: InputMode, googleSheetsURL: String) {
        defaults.set(csvPath, forKey: Keys.lastCSVPath)
        defaults.set(outputPath, forKey: Keys.lastOutputPath)
        defaults.set(inputMode.rawValue, forKey: Keys.lastInputMode)
        defaults.set(googleSheetsURL, forKey: Keys.lastGoogleSheetsURL)
    }
}


