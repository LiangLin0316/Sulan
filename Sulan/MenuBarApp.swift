import AppKit

@main
@MainActor
final class MenuBarApp: NSObject, NSApplicationDelegate {
    private let downloadItem = NSMenuItem()
    private let uploadItem = NSMenuItem()
    private var statusItem: NSStatusItem?
    private var timer: Timer?
    private var monitor = TrafficMonitor()

    static func main() {
        let app = NSApplication.shared
        let delegate = MenuBarApp()
        app.delegate = delegate
        withExtendedLifetime(delegate) { app.run() }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.imagePosition = .imageOnly
        item.button?.setAccessibilityLabel("实时网速")

        let menu = NSMenu()
        menu.autoenablesItems = false
        downloadItem.isEnabled = false
        uploadItem.isEnabled = false
        menu.addItem(downloadItem)
        menu.addItem(uploadItem)
        menu.addItem(.separator())

        let quit = NSMenuItem(title: "退出速栏", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quit.target = NSApp
        menu.addItem(quit)
        item.menu = menu
        statusItem = item

        refresh()
        let timer = Timer(timeInterval: 1, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
    }

    @objc private func refresh() {
        let rate = monitor.sample()
        let download = rate.map { Self.format($0.download) } ?? "—"
        let upload = rate.map { Self.format($0.upload) } ?? "—"
        let details = "下载 \(download)\n上传 \(upload)"
        downloadItem.title = "下载  \(download)"
        uploadItem.title = "上传  \(upload)"

        let button = statusItem?.button
        button?.image = Self.statusImage(download: download, upload: upload)
        button?.toolTip = details
        button?.setAccessibilityValue(details)
    }

    private static func format(_ bytesPerSecond: Double) -> String {
        let units = ["B/s", "KB/s", "MB/s", "GB/s", "TB/s", "PB/s"]
        var value = bytesPerSecond
        var unit = 0
        while value >= 999.5 && unit < units.count - 1 {
            value /= 1_000
            unit += 1
        }
        let number = String(format: unit == 0 || value >= 100 ? "%.0f" : "%.1f", value)
        return "\(number) \(units[unit])"
    }

    private static func statusImage(download: String, upload: String) -> NSImage {
        let font = NSFont.monospacedSystemFont(ofSize: 10, weight: .medium)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.black]
        let width = ceil(("↓ 100.0 MB/s" as NSString).size(withAttributes: attributes).width)
        let image = NSImage(size: NSSize(width: width, height: 22), flipped: true) { _ in
            ("↓ \(download)" as NSString).draw(at: NSPoint(x: 0, y: 0), withAttributes: attributes)
            ("↑ \(upload)" as NSString).draw(at: NSPoint(x: 0, y: 10), withAttributes: attributes)
            return true
        }
        image.isTemplate = true
        return image
    }
}
