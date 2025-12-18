import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var csvPath: String = ""
    @State private var outputPath: String = ""
    @State private var logText: String = ""
    @State private var isRunning: Bool = false

    @State private var showingCSVImporter: Bool = false
    @State private var selectedPlatform: Platform = .ios

    // Calculated repo root where `python/analytics_codegen` lives
    // Assumes the repo is at `~/Desktop/Lalafo-Analyric-Cursor`
    private var projectRoot: String {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home
            .appendingPathComponent("Desktop")
            .appendingPathComponent("Lalafo-Analyric-Cursor")
            .path
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analytics Tracking Generator")
                .font(.title2)
                .bold()

            // Platform selection (locked to iOS for now)
            Picker("", selection: $selectedPlatform) {
                Text("android").tag(Platform.android)
                Text("ios").tag(Platform.ios)
                Text("web").tag(Platform.web)
                Text("web-mobile").tag(Platform.webMobile)
            }
            .pickerStyle(.segmented)
            .disabled(true) // lock selection on iOS
            .frame(maxWidth: .infinity)

            HStack {
                Text("CSV file:")
                TextField("Select analytics.csv…", text: $csvPath)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Browse…") {
                    showingCSVImporter = true
                }
            }

            HStack {
                Text("Output Swift:")
                TextField("Swift/GeneratedTrackingFunctions.swift", text: $outputPath)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Browse…") {
                    pickOutput()
                }
            }

            HStack(spacing: 8) {
                Button(action: runGenerator) {
                    if isRunning {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Generate")
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: 120, height: 32)
                .buttonStyle(.borderedProminent)
                .tint(
                    isRunning || csvPath.isEmpty || outputPath.isEmpty
                    ? Color(nsColor: .systemGray)
                    : Color(nsColor: .systemGreen)
                )
                .disabled(isRunning || csvPath.isEmpty || outputPath.isEmpty)

                Button(action: {
                    NSApp.terminate(nil)
                }) {
                    Text("Exit")
                        .frame(maxWidth: .infinity)
                }
                .frame(width: 120, height: 32)
                .buttonStyle(.borderedProminent)
                .tint(Color(nsColor: .systemRed))

                Spacer()
            }

            Text("Log:")
            ScrollView {
                Text(logText)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(4)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(4)
            }
        }
        .padding(20)
        .onAppear {
            loadLastPaths()
        }
        .fileImporter(
            isPresented: $showingCSVImporter,
            allowedContentTypes: [UTType.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    csvPath = url.path
                }
            case .failure(let error):
                logText += "Failed to pick CSV: \(error.localizedDescription)\n"
            }
        }
    }

    // MARK: - Generator

    private func loadLastPaths() {
        if let lastCSV = PathPreferences.loadCSVPath() {
            csvPath = lastCSV
        }
        if let lastOutput = PathPreferences.loadOutputPath() {
            outputPath = lastOutput
        } else {
            // Default if nothing stored yet
            outputPath = "\(projectRoot)/Swift/GeneratedTrackingFunctions.swift"
        }
    }

    private func storeLastPaths() {
        PathPreferences.store(csvPath: csvPath, outputPath: outputPath)
    }

    @MainActor
    private func pickOutput() {
        let panel = NSSavePanel()
        if #available(macOS 12.0, *) {
            panel.allowedContentTypes = [UTType.swiftSource]
        } else {
            panel.allowedFileTypes = ["swift"]
        }
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "GeneratedTrackingFunctions.swift"

        if panel.runModal() == .OK, let url = panel.url {
            outputPath = url.path
        }
    }

    private func runGenerator() {
        guard !csvPath.isEmpty, !outputPath.isEmpty else { return }
        isRunning = true
        logText = "Running generator…\n"

        DispatchQueue.global(qos: .userInitiated).async {
            let result = runPythonGenerator(
                projectRoot: projectRoot,
                csvPath: csvPath,
                outputPath: outputPath
            )

            storeLastPaths()

            DispatchQueue.main.async {
                self.isRunning = false
                self.logText += result
            }
        }
    }
}

enum Platform: String, CaseIterable, Identifiable {
    case android
    case ios
    case web
    case webMobile

    var id: String { rawValue }
}


