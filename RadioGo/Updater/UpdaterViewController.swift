import UIKit
import SnapKit
import XCGLogger

class UpdaterViewController: UIViewController {
    let log = XCGLogger.default

    var label:        UILabel!
    var progressView: UIProgressView!
    var progress = Float(0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        self.label = UILabel()
        self.label.text = Strings.WaitingForUpdate
        self.view.addSubview(self.label)
        self.label.snp.makeConstraints {
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.bottom.equalTo(self.view.snp.centerY).offset(-10)
        }
     
        self.progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 3))
        self.progressView.tintColor = UIColor.blue
        //self.progressView.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        self.progressView.setProgress(0, animated: true)
        self.view.addSubview(self.progressView)
        self.progressView.snp.makeConstraints {
            $0.left.equalTo(self.view.snp.left).offset(10)
            $0.right.equalTo(self.view.snp.right).offset(-10)
            $0.top.equalTo(self.view.snp.centerY).offset(10)
            $0.height.equalTo(10)
        }
        
        self.performSelector(onMainThread: #selector(UpdaterViewController.progressUpdate), with: nil, waitUntilDone: false)
    }
    
    func progressUpdate() {
        if self.progress < 1 {
            self.log.info("progress = \(self.progress)")
            self.progressView.progress = self.progress
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(UpdaterViewController.progressUpdate), userInfo: nil, repeats: false)
        }
    }
    
    func startUpdater() {
        DispatchQueue.global(qos: .background).async {
            let version = 1
            let countryUpdater = CountryUpdater(version: version)
            let categoryUpdater = CategoryUpdater(version: version)
            let stationUpdater = StationUpdater(version: version)
            let categoryStationUpdater = CategoryStationUpdater(version: version)
                        
            let totalOfRecords = countryUpdater.size + categoryUpdater.size + stationUpdater.size + categoryStationUpdater.size
            
            if totalOfRecords > 0 {
                for index in 0..<totalOfRecords {
                    self.progress = Float(index) / Float(totalOfRecords)
                    self.log.info("progress = \(self.progress)")
                }
            }
            self.progress = 1.0
            self.dismiss(animated: true, completion: nil)
        }
    }
}
