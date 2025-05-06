//
//  APIClient+PushDevice.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/08/22.
//

import Foundation

extension APIClient {

    func register(pushDevice: PushDevice) async throws -> Bool {
        let url = URL(string: serverPath + "v1/push-device")!
        let _: PushDevice = try await post(to: url, body: pushDevice)
        return true
    }
}
