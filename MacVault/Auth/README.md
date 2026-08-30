# Fallback Authentication

The `Auth` module provides secure alternatives when Face Unlock is unavailable, fails, or is disabled by the user.

## Components

- **`AuthenticationManager`**: The unified interface that orchestrates the flow between primary and fallback authentication methods.
- **`TouchIDAuth`**: Integrates with the `LocalAuthentication` framework (`LAContext`) to prompt for fingerprint validation on supported Macs.
- **`PasswordAuth`**: A custom implementation that securely hashes (SHA-256 + salt) and compares a user-defined emergency PIN against a Keychain-stored value.

## Threat Model Consideration

Fallback mechanisms are critical because Face Unlock can fail in poor lighting or on devices without cameras. The custom password is the ultimate fallback and its hash must strictly remain within the encrypted macOS Keychain via the `Security` framework.
