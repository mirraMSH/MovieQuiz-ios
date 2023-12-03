import UIKit

final class MovieQuizViewController: UIViewController {
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
   
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
        noButton.isEnabled = true
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        presenter.questionFactory?.loadData()
        
        
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
        }
    
    private func showAlert (alertModel: AlertModel) {
        guard let alertPresenter = alertPresenter else { return }
        alertPresenter.showAlert()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        if isCorrect{
            presenter.correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
   private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            
            guard let statisticService = statisticService else {
                return
            }
            
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
            
            alertPresenter = AlertPresenter(appearingAlert: AlertModel(title: "Этот раунд окончен!", message: "Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)\n Количество сыгранных квизов: \(statisticService.gamesCount)\n Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%", buttonText: "Сыграть ещё раз", completion: {
                
                self.presenter.restartGame()
                self.presenter.questionFactory?.requestNextQuestion()
            }))
            
            alertPresenter?.controller = self
            alertPresenter?.showAlert()
            
        } else {
            presenter.switchToNextQuestion()
            presenter.questionFactory?.requestNextQuestion().self
            
        }
        
    }
    
   
    func hideLoadingIndicator() {
        activityIndicator.isHidden = false
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        alertPresenter = AlertPresenter(appearingAlert: AlertModel(title: "Ошибка",
                                                                   message: message,
                                                                   buttonText: "Попробовать еще раз", completion: { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            presenter.questionFactory?.requestNextQuestion()
            self.showLoadingIndicator()
            self.presenter.questionFactory?.loadData()
        }))
        
        alertPresenter?.controller = self
        alertPresenter?.showAlert()
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
                presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}

