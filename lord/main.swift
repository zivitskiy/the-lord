//
//  main.swift
//  lord - little console tool for devs
//
//  Created by dev on 03.07.2024.
//

import Foundation

func readFileContent(file: String) -> String? {
    do {
        let content = try String(contentsOfFile: file)
        return content
    } catch {
        print("Failed to read file: \(error.localizedDescription)")
        return nil
    }
}

func checkDRY(file: String) {
    guard let content = readFileContent(file: file) else {
        return
    }

    let lines = content.components(separatedBy: .newlines)
    var lineOccurrences = [String: [Int]]()
    let minBlockSize = 3
    
    for (index, line) in lines.enumerated() {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        if trimmedLine.isEmpty { continue }
        
        if lineOccurrences[trimmedLine] != nil {
            lineOccurrences[trimmedLine]?.append(index)
        } else {
            lineOccurrences[trimmedLine] = [index]
        }
    }

    var blocks = [String: [[Int]]]()
    
    for (line, indexes) in lineOccurrences where indexes.count > 1 {
        for i in 0..<indexes.count {
            for j in i+1..<indexes.count {
                var k = 0
                while indexes[i] + k < lines.count && indexes[j] + k < lines.count && lines[indexes[i] + k] == lines[indexes[j] + k] {
                    k += 1
                }
                if k >= minBlockSize {
                    let block = lines[indexes[i]..<(indexes[i] + k)].joined(separator: "\n")
                    if blocks[block] != nil {
                        blocks[block]?.append([indexes[i], indexes[j]])
                    } else {
                        blocks[block] = [[indexes[i], indexes[j]]]
                    }
                }
            }
        }
    }

    print("Repeated blocks in file \(file):")
    for (block, occurrences) in blocks {
        print("Block:\n\(block)\noccurs \(occurrences.count) times at lines:")
        for occurrence in occurrences {
            print(occurrence.map { "\($0 + 1)" }.joined(separator: ", "))
        }
        print("\n")
    }
}

func checkComment(file: String) {
    guard let content = readFileContent(file: file) else {
        return
    }
    
    let lines = content.components(separatedBy: .newlines)
    var comments : Int = 0
    
    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("//") {
            comments += 1
        }
    }
    print("Commented lines \(comments)")
}


func checkKISS(file: String) {
    
    print("Checking KISS for file \(file)")
}

func checkSecurity(file: String) {
    
    print("Checking security for file \(file)")
}

func createVersion(file: String) {
    let versionsDirectory = URL(fileURLWithPath: "./versions")
    let fileURL = URL(fileURLWithPath: file)
    let version = UUID().uuidString
    let destinationURL = versionsDirectory.appendingPathComponent("\(file)-\(version)")
    
    do {
        if !FileManager.default.fileExists(atPath: versionsDirectory.path) {
            try FileManager.default.createDirectory(at: versionsDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        try FileManager.default.copyItem(at: fileURL, to: destinationURL)
        print("File saved as version: \(version)")
    } catch {
        print("Failed to save file version: \(error.localizedDescription)")
    }
}

func restoreVersion(file: String) {
    let versionsDirectory = URL(fileURLWithPath: "./versions")
    let fileURL = URL(fileURLWithPath: file)
    
    do {
        let versions = try FileManager.default.contentsOfDirectory(atPath: versionsDirectory.path)
        let fileVersions = versions.filter { $0.hasPrefix(file) }
        
        guard let latestVersion = fileVersions.last else {
            print("No versions found for file \(file).")
            return
        }
        
        let versionURL = versionsDirectory.appendingPathComponent(latestVersion)
        try FileManager.default.copyItem(at: versionURL, to: fileURL)
        print("File restored from version: \(latestVersion)")
    } catch {
        print("Failed to restore file: \(error.localizedDescription)")
    }
}

func main() {
    let arguments = CommandLine.arguments
    guard arguments.count > 2 else {
        print("Specify a command and a file.")
        return
    }
    
    let command = arguments[1]
    let file = arguments[2]
    
    switch command {
    case "dry":
        checkDRY(file: file)
    case "kiss":
        checkKISS(file: file)
    case "protect":
        checkSecurity(file: file)
    case "beg":
        createVersion(file: file)
    case "retreat":
        restoreVersion(file: file)
    case "doc":
        checkComment(file: file)
    default:
        print("Impossible.")
    }
}

main()
