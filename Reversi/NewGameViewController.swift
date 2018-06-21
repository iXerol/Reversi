import UIKit

// 用 PickerView 选择难度
class NewGameViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
	
	@IBOutlet weak var dropDown: UIPickerView!
	
	weak var difficultyDelegate: DetailDifficultyDelegate?
	
	// 缺省难度
	var difficulty = 0
	
	// 显示 list
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
			difficulty = 0
		case 1:
			difficulty = 2
		case 2:
			difficulty = 6
		default:
			break
		}
	}
	
	// 关闭 pop
	@IBAction func closepop(sender: UIButton) {
		difficultyDelegate?.passedDifficulty(difficulty: difficulty)
		dismiss(animated: true, completion: nil)
	}
}

protocol DetailDifficultyDelegate: class {
	func passedDifficulty(difficulty: Int) -> Void
}
