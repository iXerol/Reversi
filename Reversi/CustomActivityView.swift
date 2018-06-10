//
//  CustomActivityView.swift
//  Reversi
//
//  Created by bill harper on 3/9/17.
//  Copyright © 2017 bill harper. All rights reserved.
//

import UIKit

// A slightly modified version of what I used in project 7, I realized this 
// would probably be helpful if the computer moves slowly on higher AI levels
/// customActivityView: a simple class displaying a larger than usual UIActivityIndicatorView
class CustomActivityView: UIView {

	let actInd: UIActivityIndicatorView = UIActivityIndicatorView()

	/// Custom view initialization
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = .black
		self.alpha = 0.7

		// setup the activity indicator
		// its size will adjust to whatever frame size the UIView is given
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
		// add activity indicator

	}

	/// showActivityView: helper to start the spinner and display the view
	func showActivityView() {
		self.isHidden = false;
		actInd.startAnimating()
	}

	/// hideActivityView: helper func to hide the view
	func hideActivityView() {
		self.isHidden = true;
		actInd.stopAnimating()
	}
}
