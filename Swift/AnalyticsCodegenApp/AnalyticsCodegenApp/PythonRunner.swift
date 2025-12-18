import Foundation

func runPythonGenerator(projectRoot: String, inputPath: String, outputPath: String) -> String {
    let process = Process()
    let pipe = Pipe()
    let errorPipe = Pipe()

    process.standardOutput = pipe
    process.standardError = errorPipe
    process.currentDirectoryURL = URL(fileURLWithPath: projectRoot)
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = [
        "python3",
        "-m", "python.analytics_codegen.cli",
        "--input", inputPath,
        "--output", outputPath
    ]

    var output = ""
    do {
        try process.run()
        process.waitUntilExit()

        let outData = pipe.fileHandleForReading.readDataToEndOfFile()
        let errData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        if let outStr = String(data: outData, encoding: .utf8), !outStr.isEmpty {
            output += outStr
        }
        if let errStr = String(data: errData, encoding: .utf8), !errStr.isEmpty {
            output += errStr
        }

        output += "\nExit status: \(process.terminationStatus)\n"
    } catch {
        output += "Failed to run generator: \(error.localizedDescription)\n"
    }

    return output
}


