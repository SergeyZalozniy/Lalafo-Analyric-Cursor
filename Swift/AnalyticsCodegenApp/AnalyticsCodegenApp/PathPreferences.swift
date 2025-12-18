import Foundation

enum PathPreferences {
    private static let defaults = UserDefaults.standard

    private enum Keys {
        static let lastCSVPath = "AnalyticsCodegen_lastCSVPath"
        static let lastOutputPath = "AnalyticsCodegen_lastOutputPath"
    }

    static func loadCSVPath() -> String? {
        defaults.string(forKey: Keys.lastCSVPath)
    }

    static func loadOutputPath() -> String? {
        defaults.string(forKey: Keys.lastOutputPath)
    }

    static func store(csvPath: String, outputPath: String) {
        defaults.set(csvPath, forKey: Keys.lastCSVPath)
        defaults.set(outputPath, forKey: Keys.lastOutputPath)
    }
}


