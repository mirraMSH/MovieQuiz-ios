import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers = 0
    private let presenter = MovieQuizPresenter()
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
        presenter.viewController = self
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
    internal func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        
    }
    
    private func showAlert (alertModel: AlertModel) {
        guard let alertPresenter = alertPresenter else { return }
        alertPresenter.showAlert()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        if isCorrect {
            correctAnswers += 1
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
            
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            alertPresenter = AlertPresenter(appearingAlert: AlertModel(title: "Этот раунд окончен!", message: "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)\n Количество сыгранных квизов: \(statisticService.gamesCount)\n Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%", buttonText: "Сыграть ещё раз", completion: {
                
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }))
            
            alertPresenter?.controller = self
            alertPresenter?.showAlert()
            
            
            imageView.layer.borderWidth = 0
            imageView.layer.borderColor = UIColor.clear.cgColor
            
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion().self
            
        }
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        
    }
    
    internal func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    internal func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = false
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        alertPresenter = AlertPresenter(appearingAlert: AlertModel(title: "Ошибка",
                                                                   message: message,
                                                                   buttonText: "Попробовать еще раз", completion: { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
            self.questionFactory?.requestNextQuestion()
        }))
        
        alertPresenter?.controller = self
        alertPresenter?.showAlert()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
                presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
}

