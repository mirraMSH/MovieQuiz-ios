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
    var correctAnswers: Int = 0
    var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
           currentQuestionIndex == questionsAmount - 1
       }
       
       func restartGame() {
           currentQuestionIndex = 0
           correctAnswers = 0
           
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

   
    
   
        
        func yesButtonClicked() {
            didAnswer(isCorrectAnswer: true)
        }
    
    func noButtonClicked() {
        didAnswer(isCorrectAnswer: false)
        }
    
    func didAnswer(isCorrectAnswer: Bool) {
            guard let currentQuestion = currentQuestion else {
                return
            }
        
            
            let givenAnswer = isCorrectAnswer
            
            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
}
