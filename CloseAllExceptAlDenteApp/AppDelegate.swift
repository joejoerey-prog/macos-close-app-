import Cocoa
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.prohibited)
        closeOtherApps()
        notifyAndExit()
    }

    private func closeOtherApps() {
        let workspace = NSWorkspace.shared
        let currentApp = NSRunningApplication.current
        let runningApps = workspace.runningApplications

        for app in runningApps {
            guard app.processIdentifier != currentApp.processIdentifier,
                  app.bundleIdentifier != "com.apple.finder",
                  !(app.localizedName?.localizedCaseInsensitiveContains("AlDente") ?? false),
                  app.activationPolicy != .prohibited
            else {
                continue
            }

            _ = app.terminate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if !app.isTerminated {
                    _ = app.forceTerminate()
                }
            }
        }
    }

    private func notifyAndExit() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in
            let content = UNMutableNotificationContent()
            content.title = "Closed other apps. Finder and AlDente left running."
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil
            )
            center.add(request) { _ in
                DispatchQueue.main.async {
                    NSApp.terminate(nil)
                }
            }
        }
    }
}
