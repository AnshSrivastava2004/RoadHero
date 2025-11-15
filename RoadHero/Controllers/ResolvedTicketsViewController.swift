import UIKit
import Supabase

class ResolvedTicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var NoResolvedTicketsLabel: UILabel!
    
    private let backgroundColor = UIColor.black
    private let accentColor = UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
    
    private let ticketService = TicketService()
    private let user = SessionManager.shared.user!
    
    private var tickets: [Ticket] = []
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Resolved Tickets"
        view.backgroundColor = backgroundColor
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if let navBar = navigationController?.navigationBar {
            navBar.barTintColor = backgroundColor
            navBar.titleTextAttributes = [.foregroundColor: accentColor]
            navBar.largeTitleTextAttributes = [.foregroundColor: accentColor]
            navBar.tintColor = accentColor
            navBar.isTranslucent = false
        }
        
        setupTableView()
        setupActivityIndicator()
        addCustomBackButton()
        
        view.bringSubviewToFront(NoResolvedTicketsLabel)
        
        fetchTickets()
    }
    
    // MARK: - UI Setup
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleBackButtonVisibility(for: scrollView)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 90),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = backgroundColor
        
        tableView.register(TicketCell.self, forCellReuseIdentifier: "TicketCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = accentColor
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // MARK: - Fetch tickets from service
    private func fetchTickets() {
        activityIndicator.startAnimating()
        
        Task {
            do {
                let fetchedTickets = try await ticketService.fetchTickets(for: user, status: "COMPLETE")
                
                await MainActor.run {
                    self.tickets = fetchedTickets
                    self.NoResolvedTicketsLabel.isHidden = !fetchedTickets.isEmpty
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                await MainActor.run {
                    self.tickets = []
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    // MARK: - Table View Delegate & Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return tickets.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TicketCell", for: indexPath) as? TicketCell else {
            return UITableViewCell()
        }
        
        let ticket = tickets[indexPath.section]
        
        cell.iconImageView.image = UIImage(systemName: "mappin.and.ellipse")
        cell.titleLabel.text = ticket.pothole_metadata.description ?? "No Description Provided"
        cell.statusSeverityLabel.text = "Status: \(ticket.status) | Severity: \(ticket.pothole_metadata.severity ?? "N/A")"
        
        if let imageURLString = ticket.pothole_metadata.image_url,
           let url = URL(string: imageURLString) {
            
            cell.ticketImageView.image = nil
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if cell.ticketImageView.url == url {
                            cell.ticketImageView.image = image
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.ticketImageView.image = UIImage(systemName: "photo.fill")?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
                    }
                }
            }.resume()
            cell.ticketImageView.url = url
            
        } else {
            cell.ticketImageView.image = UIImage(systemName: "photo.fill")?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 0
    }
}
