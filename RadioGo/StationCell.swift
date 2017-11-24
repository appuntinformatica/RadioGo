import UIKit
import SnapKit

class StationCell: UITableViewCell {
    
    static let Identifier = "UITableViewCell"
    static let Height = CGFloat(70)
    
    var stationImageView: UIImageView!
    var stationNameLabel: UILabel!
    var streamUrlLabel:   UILabel!
    var countryImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let frame = CGRect(x: 0, y: 0, width: StationCell.Height - 10, height: StationCell.Height - 10)
        let overlay = UIView(frame: frame)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        self.stationImageView = UIImageView(frame: frame)
        self.stationImageView.image = UIImage(named: "no_logo")
        overlay.addSubview(self.stationImageView)
        self.contentView.addSubview(overlay)
        overlay.snp.makeConstraints {
            $0.top.equalTo(self.contentView.snp.top).offset(5)
            $0.left.equalTo(self.contentView.snp.left).offset(5)
            $0.right.equalTo(self.contentView.snp.right)
            $0.centerY.equalTo(self.contentView.snp.centerY).offset(0)
        }
        
        self.stationNameLabel = UILabel()
        self.contentView.addSubview(self.stationNameLabel)
        self.stationNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.contentView.snp.centerY).offset(-10)
            $0.left.equalTo(self.stationImageView.snp.right).offset(5)
        }
        
        self.streamUrlLabel = UILabel()
        self.streamUrlLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightRegular)
        self.contentView.addSubview(self.streamUrlLabel)
        self.streamUrlLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.contentView.snp.centerY).offset(10)
            $0.left.equalTo(self.stationImageView.snp.right).offset(5)
        }
        
        let frame2 = CGRect(x: 0, y: 0, width: 21, height: 15)
        let overlay2 = UIView(frame: frame2)
        overlay2.translatesAutoresizingMaskIntoConstraints = false
        self.countryImageView = UIImageView(frame: frame2)
        overlay2.addSubview(self.countryImageView)
        self.contentView.addSubview(overlay2)
        overlay2.snp.makeConstraints {
            $0.top.equalTo(self.contentView.snp.top).offset(5)
            $0.right.equalTo(self.contentView.snp.right).offset(-5)
            $0.width.equalTo(21)
            $0.height.equalTo(15)
        }
    }
}
