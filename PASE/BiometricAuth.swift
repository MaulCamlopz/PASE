//
//  BiometricAuth.swift
//  PASE
//
//  Created by Maul Camlopz on 27/08/25.
//

import LocalAuthentication

enum BiometricAuthResult {
    case success
    case unavailable
    case failed
}

struct BiometricAuth {
    static func authenticate(reason: String = "Acceso a favoritos") async -> BiometricAuthResult {
        let context = LAContext()
        var error: NSError?
        
        // Si no hay biometría disponible
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .unavailable
        }
        
        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                continuation.resume(returning: success ? .success : .failed)
            }
        }
    }
}
