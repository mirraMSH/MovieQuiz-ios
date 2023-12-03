//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Мария Шагина on 26.11.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? {get set}
    func requestNextQuestion()
    func loadData()
}
