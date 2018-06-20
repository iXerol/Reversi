import UIKit

class CustomActivityView: UIView {
	
	let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = .black
		self.alpha = 0.7
		
		// 创建图像
		actInd.frame = CGRect(x: 0, y: 0, width: frame.size.width / 2, height: frame.size.width / 2);
		actInd.activityIndicatorViewStyle =
			UIActivityIndicatorViewStyle.whiteLarge
		actInd.center = CGPoint(x: frame.size.width / 2,
								y: frame.size.height / 2);
		addSubview(actInd)
		self.isHidden = true;
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
	}
	
	// showActivityView: 显示
	func showActivityView() {
		self.isHidden = false;
		actInd.startAnimating()
	}
	
	// hideActivityView: 隐藏
	func hideActivityView() {
		self.isHidden = true;
		actInd.stopAnimating()
	}
}
