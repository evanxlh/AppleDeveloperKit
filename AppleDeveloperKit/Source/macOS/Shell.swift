//
//  Shell.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/6.
//

#if os(macOS)

import Foundation

public enum ShellError: Error {
    case executableProgramNotFound(URL)
    case failToRun(_ underlyingError: Error)
    case commandErrorString(String)
}

/// Shell can run a shell command, and fetch the result from the target process.
/// Here are some examples: `ls`(`ls` is executable program, with no argument),
///  `open README.md`(`open` is executable program, `README.md` is argument).
public struct Shell {
    public let executableURL: URL
    public let arguments: [String]
    
    public init(executableURL: URL, arguments: [String] = []) {
        self.executableURL = executableURL
        self.arguments = arguments
    }
    
    /// Run given program, and wait until the result return back.
    public func run() -> Result<String, ShellError> {
        guard FileManager.default.fileExists(atPath: executableURL.path) else {
            return .failure(.executableProgramNotFound(executableURL))
        }
        
        let task = Process()
        task.executableURL = executableURL
        task.arguments = arguments
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus == 0 {
                let resultData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                return .success(String(data: resultData, encoding: .utf8) ?? "")
            } else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                return .failure(.commandErrorString(String(data: errorData, encoding: .utf8) ?? ""))
            }
        } catch {
            return .failure(.failToRun(error))
        }
    }
    
}

#endif
