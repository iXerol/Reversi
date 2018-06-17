import UIKit

class HelpViewController: UIViewController {
	
	@IBOutlet weak var webView: UIWebView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// 载入 rules.html
		let url = Bundle.main.url(forResource: "rules", withExtension: "html")
		let request = NSURLRequest(url: url!)
		webView.loadRequest(request as URLRequest)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	@IBAction func dismiss(sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: {});
	}
	
}
