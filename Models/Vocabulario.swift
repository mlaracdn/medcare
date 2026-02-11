//
//  Vocabulary.swift
//  MedCare
//
//  Created by Romi on 29/1/26.
//

import Foundation

struct Vocabulario: Decodable, Identifiable {
    let id: Int
    let nivel: Int
    let palabra: String
    let traduccion: String
    let definicion: String
    let oracion: String
}

