# Face Authentication Pipeline

This module contains the primary Unique Selling Proposition (USP) of MacVault: local, neural-engine-accelerated face recognition.

## Pipeline Overview

Face authentication runs as a 4-stage real-time pipeline:

1. **Capture (`CameraManager`)**: Ingests live frames via `AVFoundation`.
2. **Detect (`FaceDetector`)**: Uses Apple's `Vision` framework (`VNDetectFaceRectanglesRequest`) to locate bounding boxes and crop the face.
3. **Embed (`FaceEmbedder`)**: Runs the cropped frame through a quantized MobileFaceNet Core ML model via the Apple Neural Engine (ANE) to generate a 128-dimensional mathematical representation (embedding) of the face.
4. **Match (`FaceMatcher`)**: Calculates the cosine similarity between the live embedding and the securely stored enrollment embeddings.

## Security Context

This implementation relies on a 2D camera. It is structurally not equivalent to Apple's Face ID depth-sensing hardware. It provides a frictionless convenience layer, not a high-security vault. 

## Performance

The embedding process is routed explicitly to the Apple Neural Engine using `MLModelConfiguration.computeUnits = .all`. On Apple Silicon, inference takes ~2-5ms, allowing the pipeline to run flawlessly in real-time without stalling the main thread.
