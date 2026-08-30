import Foundation

/// Encrypted storage for face enrollment data.
/// Reads and writes the face embedding file using AES-256-GCM encryption via CryptoHelper.
final class FaceDataStore {
    static let shared = FaceDataStore()

    private let crypto = CryptoHelper.shared
    private let fileURL = FGConstants.faceDataFilePath

    private init() {}

    // MARK: - Read / Write

    /// Save a face enrollment to the encrypted data file.
    /// - Parameter enrollment: The face enrollment data to persist.
    func save(_ enrollment: FaceEnrollment) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(enrollment)

        // Ensure the parent directory exists before writing.
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)

        try crypto.encryptToFile(data, at: fileURL)

        // Update UserDefaults metadata.
        UserDefaults.standard.set(true, forKey: FGConstants.faceEnrolledKey)
    }

    /// Load the face enrollment from the encrypted data file.
    /// - Returns: The stored FaceEnrollment, or nil if no enrollment exists.
    func load() -> FaceEnrollment? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }

        do {
            let data = try crypto.decryptFromFile(at: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(FaceEnrollment.self, from: data)
        } catch {
            print("[FaceDataStore] Failed to load enrollment: \(error)")
            return nil
        }
    }

    /// Delete the stored face enrollment data.
    /// - Throws: If the file cannot be removed.
    func delete() throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }

        // Clear UserDefaults metadata.
        UserDefaults.standard.set(false, forKey: FGConstants.faceEnrolledKey)
        UserDefaults.standard.set(false, forKey: FGConstants.faceUnlockEnabledKey)
    }

    /// Whether a face enrollment exists on disk.
    var hasEnrollment: Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }
}
