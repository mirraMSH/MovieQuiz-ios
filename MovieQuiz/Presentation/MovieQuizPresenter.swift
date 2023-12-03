//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Мария Шагина on 03.12.2023.
//

import UIKit

final class MovieQuizPresenter {
    
    private var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    
    func isLastQuestion() -> Bool {
           currentQuestionIndex == questionsAmount - 1
       }
       
       func resetQuestionIndex() {
           currentQuestionIndex = 0
       }
       
       func switchToNextQuestion() {
           currentQuestionIndex += 1
       }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

   
    
    var currentQuestion: QuizQuestion?
        weak var viewController: MovieQuizViewController?
        
        func yesButtonClicked() {
            didAnswer(isYes: true)
        }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
        }
    
    private func didAnswer(isYes: Bool) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            
            let givenAnswer = isYes
            
            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
}
