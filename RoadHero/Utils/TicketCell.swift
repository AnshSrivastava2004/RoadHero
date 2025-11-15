import UIKit

class TicketCell: UITableViewCell {

    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let statusSeverityLabel = UILabel()
    let ticketImageView = UIImageView()

    private let textStackView = UIStackView()
    private let topContentStackView = UIStackView()
    private let mainStackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        iconImageView.tintColor = UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])

        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
        titleLabel.numberOfLines = 0 // Wraps automatically

        statusSeverityLabel.font = UIFont.systemFont(ofSize: 14)
        statusSeverityLabel.textColor = .systemGray
        statusSeverityLabel.numberOfLines = 0
        
        ticketImageView.contentMode = .scaleAspectFill
        ticketImageView.layer.cornerRadius = 8
        ticketImageView.layer.masksToBounds = true
        ticketImageView.backgroundColor = .darkGray
        ticketImageView.translatesAutoresizingMaskIntoConstraints = false
        ticketImageView.heightAnchor.constraint(equalToConstant: 180).isActive = true

        textStackView.axis = .vertical
        textStackView.spacing = 5
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(statusSeverityLabel)

        topContentStackView.axis = .horizontal
        topContentStackView.spacing = 8
        topContentStackView.alignment = .top
        topContentStackView.addArrangedSubview(iconImageView)
        topContentStackView.addArrangedSubview(textStackView)

        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        mainStackView.addArrangedSubview(topContentStackView)
        mainStackView.addArrangedSubview(ticketImageView)

        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStackView)

        contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = nil
        statusSeverityLabel.text = nil
        ticketImageView.image = nil
        ticketImageView.url = nil
    }
}
