import Foundation

public enum Resources {
    public static let directory: URL = {
        URL(fileURLWithPath: String(#file))
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Resources")
    }()
    
    public static func file(_ name: String) -> URL {
        directory.appendingPathComponent(name)
    }
}
