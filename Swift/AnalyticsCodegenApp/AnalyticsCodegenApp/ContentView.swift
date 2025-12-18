import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var csvPath: String = ""
    @State private var outputPath: String = ""
    @State private var logText: String = ""
    @State private var isRunning: Bool = false

    @State private var showingCSVImporter: Bool = false

    // Adjust to where your repo with python/analytics_codegen lives
    private let projectRoot = "/Users/s.zalozniy/Desktop/Lalafo-Analyric-Cursor"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analytics Tracking Generator")
                .font(.title2)
                .bold()

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

            HStack {
                Button(action: runGenerator) {
                    if isRunning {
                        ProgressView().scaleEffect(0.7)
                    } else {
                        Text("Generate")
                    }
                }
                .disabled(isRunning || csvPath.isEmpty || outputPath.isEmpty)

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
            if outputPath.isEmpty {
                outputPath = "\(projectRoot)/Swift/GeneratedTrackingFunctions.swift"
            }
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

    @MainActor
    private func pickOutput() {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["swift"]
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

            DispatchQueue.main.async {
                self.isRunning = false
                self.logText += result
            }
        }
    }
}

