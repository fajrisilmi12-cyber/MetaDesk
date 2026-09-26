//go:build (linux || darwin) && !cgo

package main

// runApp requires cgo on Linux (GTK/WebKit) and macOS (Cocoa/WebKit).
// This stub keeps the pure-Go surface (init script guards, checksum,
// updater, settings serialization) testable on headless VPS/CI hosts
// without GTK/WebKit dev headers. Windows stays CGO-free via WebView2.
func runApp() {
	panic("runApp requires cgo on this platform")
}
