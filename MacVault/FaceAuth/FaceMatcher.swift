import Foundation

/// Compares live face embeddings against enrolled reference embeddings
/// using cosine similarity to determine identity match.
final class FaceMatcher {
    /// Matching result with details.
    struct MatchResult {
        let isMatch: Bool
        let bestSimilarity: Float
        let threshold: Float
    }

    /// Default similarity threshold — tuned for balanced security/convenience.
    private var threshold: Float

    init(threshold: Float = FGConstants.defaultFaceUnlockThreshold) {
        self.threshold = threshold
    }

    /// Update the matching threshold (e.g., from user settings).
    func setThreshold(_ newThreshold: Float) {
        self.threshold = max(0.0, min(1.0, newThreshold))
    }

    /// Check if a live face embedding matches any enrolled embedding.
    /// - Parameters:
    ///   - liveEmbedding: The embedding generated from the current camera frame.
    ///   - enrolledEmbeddings: The set of reference embeddings from enrollment.
    /// - Returns: A MatchResult indicating whether the face matches and the best similarity score.
    func match(liveEmbedding: [Float], against enrolledEmbeddings: [[Float]]) -> MatchResult {
        guard !enrolledEmbeddings.isEmpty else {
            return MatchResult(isMatch: false, bestSimilarity: -1.0, threshold: threshold)
        }

        var bestSimilarity: Float = -1.0

        for enrolled in enrolledEmbeddings {
            let similarity = VectorMath.cosineSimilarity(liveEmbedding, enrolled)
            if similarity > bestSimilarity {
                bestSimilarity = similarity
            }
        }

        return MatchResult(
            isMatch: bestSimilarity >= threshold,
            bestSimilarity: bestSimilarity,
            threshold: threshold
        )
    }

    /// Check match using the average embedding (centroid) of all enrolled embeddings.
    /// This can be more robust than matching against individual embeddings.
    /// - Parameters:
    ///   - liveEmbedding: The embedding generated from the current camera frame.
    ///   - enrolledEmbeddings: The set of reference embeddings from enrollment.
    /// - Returns: A MatchResult.
    func matchAgainstCentroid(liveEmbedding: [Float], enrolledEmbeddings: [[Float]]) -> MatchResult {
        guard !enrolledEmbeddings.isEmpty,
              let first = enrolledEmbeddings.first else {
            return MatchResult(isMatch: false, bestSimilarity: -1.0, threshold: threshold)
        }

        let dimension = first.count
        var centroid = [Float](repeating: 0, count: dimension)

        // Sum all embeddings.
        for embedding in enrolledEmbeddings {
            for i in 0..<dimension {
                centroid[i] += embedding[i]
            }
        }

        // Average.
        let count = Float(enrolledEmbeddings.count)
        for i in 0..<dimension {
            centroid[i] /= count
        }

        // Normalize the centroid.
        centroid = VectorMath.normalize(centroid)

        let similarity = VectorMath.cosineSimilarity(liveEmbedding, centroid)

        return MatchResult(
            isMatch: similarity >= threshold,
            bestSimilarity: similarity,
            threshold: threshold
        )
    }
}
