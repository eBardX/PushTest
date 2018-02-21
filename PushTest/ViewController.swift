import UIKit

public class ViewController: UIViewController {

    // MARK: Public Instance Properties

    public var text: String? {
        get { return textView?.text }
        set { textView?.text = newValue }
    }

    // MARK: Private Instance Properties

    @IBOutlet private weak var textView: UITextView!

    // MARK: Overridden NSObject Methods

    override public func awakeFromNib() {
        super.awakeFromNib()

        textView?.text = nil
    }
}
