//
//  SoundDataProvider.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/04/24.
//

import Combine

protocol SoundDataProvider {
    var sounds: [Sound] { get }
    var soundsPublisher: AnyPublisher<[Sound], Never> { get }
}
