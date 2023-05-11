//
//  ContentView.swift
//  SimpleNotes
//
//  Created by Justin Hold on 5/11/23.
//

import SwiftUI
import KeychainAccess

extension Date: RawRepresentable {
	public var rawValue: Int {
		Int(self.timeIntervalSinceReferenceDate)
	}
	public init?(rawValue: Int) {
		self = Date(timeIntervalSinceReferenceDate: Double(rawValue))
	}
}

struct ContentView: View {
	@AppStorage("lastSaved") private var lastSaved = Date.now
	@AppStorage("fontSize") var fontSize = 20.0
	@State private var notes = ""
	@State private var saveTask: Task<Void, Error>?
	let keychain = Keychain(service: "com.lefthandedapps.SimpleNotes")
    var body: some View {
		VStack {
			TextEditor(text: $notes)
				.frame(width: 400, height: 400)
				.font(.system(size: fontSize))
			HStack {
				// MARK: Left side buttons; decrease, increase, reset font size
				ControlGroup {
					Button {
						fontSize -= 1
					} label: {
						Label("Small Text", systemImage: "textformat.size.smaller")
					}
					Button {
						fontSize += 1
					} label: {
						Label("Large Text", systemImage: "textformat.size.larger")
					}
					Button {
						fontSize = 20
					} label: {
						Label("Reset Size", systemImage: "arrow.counterclockwise")
					}
				}
				// MARK: Right side buttons; copy to clipboard, quit app
				ControlGroup {
					Button {
						notes = ""
					} label: {
						Label("Delete", systemImage: "delete.backward")
					}
					Button {
						NSPasteboard.general.clearContents()
						NSPasteboard.general.setString(notes, forType: .string)
					} label: {
						Label("Copy", systemImage: "doc.on.doc")
					}
					Button {
						NSApp.terminate(nil)
					} label: {
						Label("Quit", systemImage: "power")
					}
				}
			}
			Text("Last Saved: \(lastSaved.formatted(date: .abbreviated, time: .standard))")
				.foregroundStyle(.secondary)
		}
		.padding()
		.onAppear(perform: load)
		.onChange(of: notes, perform: save)
    }
	func load() {
		notes = keychain["notes"] ?? ""
	}
	func save(newValue: String) {
		saveTask?.cancel()
		saveTask = Task {
			try await Task.sleep(for: .seconds(3))
			keychain["notes"] = newValue
			lastSaved = .now
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
