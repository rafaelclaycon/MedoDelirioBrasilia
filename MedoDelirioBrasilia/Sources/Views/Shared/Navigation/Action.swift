//
//  Action.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/07/24.
//

import Foundation

struct Action<Input, Output> {

    let action: (Input) -> Output

    init(_ action: @escaping (Input) -> Output) {
        self.action = action
    }

    func callAsFunction(_ input: Input) -> Output {
        action(input)
    }

    func callAsFunction() -> Output where Input == Void {
        action(())
    }
}
