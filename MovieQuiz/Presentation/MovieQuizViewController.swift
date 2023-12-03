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
        
        showLoadingIndicator()
        presenter.questionFactory?.loadData()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func showAlert () {
        let textAlert = presenter.makeResultsMessage()
        
        alertPresenter = AlertPresenter(appearingAlert: AlertModel.init(title: "Этот раунд окончен!", message: textAlert, buttonText: "Сыграть ещё раз", completion: {
            self.presenter.restartGame()
        }))
        
        alertPresenter?.controller = self
        alertPresenter?.showAlert()
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = false
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        alertPresenter = AlertPresenter(appearingAlert: AlertModel.init(title: "Ошибка",
                                                                        message: message,
                                                                        buttonText: "Попробовать еще раз", completion: { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
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

