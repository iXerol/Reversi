import UIKit

// A simple popover to display when creating a new game to select difficulty using a pickerview
class NewGameViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

	// difficulty selector
	@IBOutlet weak var dropDown: UIPickerView!

	// delegate for passing difficulty around
	weak var difficultyDelegate: DetailDifficultyDelegate?

	// default difficulty setting
	var difficulty = 0

	// List to diaplay
	var list = ["Easy", "Medium", "Hard"]

	override func viewDidLoad() {
		super.viewDidLoad()

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return list.count
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		self.view.endEditing(true)
		return list[row]
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		print(row)
		switch row {
		case 0:
			difficulty = 1
		case 1:
			difficulty = 4
		case 2:
			difficulty = 6
		default:
			break   // default to braindead in case of some weird error
		}
	}

	// closepop: close the new game popup
	@IBAction func closepop(sender: UIButton) {
		difficultyDelegate?.passedDifficulty(difficulty: difficulty)
		dismiss(animated: true, completion: nil)
	}
}

// Our delegate to pass the url back to the detailview
protocol DetailDifficultyDelegate: class {
	func passedDifficulty(difficulty: Int) -> Void
}
