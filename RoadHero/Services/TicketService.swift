import Foundation
import Supabase
import UIKit
import CoreLocation

class TicketService {
    
    private let supabase = SupabaseManager.shared.client
    
    // MARK: - Fetching Logic
    func fetchTickets(for user: User, status: String) async throws -> [Ticket] {
        do {
            let response = try await supabase
                .from("tickets")
                .select("*, pothole_metadata(*)")
                .eq("user_id", value: user.id.uuidString)
                .eq("status", value: status)
                .execute()
            
            let tickets = try JSONDecoder().decode([Ticket].self, from: response.data)
            
            if tickets.isEmpty {
                print("Fetch successful: 0 '\(status)' tickets found.")
            } else {
                print("Successfully fetched \(tickets.count) '\(status)' tickets.")
            }
            return tickets
            
        } catch {
            print("Supabase fetch/decode error: \(error)")
            throw error
        }
    }
    
    // MARK: - Fetching Counts
    func fetchTicketCounts(for user: User) async throws -> (active: Int, resolved: Int) {
        async let activeResponse = supabase
            .from("tickets")
            .select("id", count: .exact)
            .eq("user_id", value: user.id.uuidString)
            .eq("status", value: "ACTIVE")
            .execute()
        
        async let resolvedResponse = supabase
            .from("tickets")
            .select("id", count: .exact)
            .eq("user_id", value: user.id.uuidString)
            .eq("status", value: "COMPLETE")
            .execute()
        
        let (activeResult, resolvedResult) = try await (activeResponse, resolvedResponse)
        
        return (activeResult.count ?? 0, resolvedResult.count ?? 0)
    }

    // MARK: - Submitting Pothole
    func submitPothole(image: UIImage, location: CLLocation?, description: String, user: User) async throws {
        let url = URL(string: "https://sarcolemmous-roma-seborrheal.ngrok-free.app/detect_potholes")!
        let userId = user.id.uuidString

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateTaken = dateFormatter.string(from: Date())

        let latitude = String(location?.coordinate.latitude ?? 0.0)
        let longitude = String(location?.coordinate.longitude ?? 0.0)

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get JPEG data"])
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpBody = createMultipartBody(
            boundary: boundary,
            parameters: [
                "user_id": userId,
                "description": description,
                "date_taken": dateTaken,
                "latitude": latitude,
                "longitude": longitude
            ],
            fileData: imageData,
            fieldName: "file",
            fileName: "pothole.jpg",
            mimeType: "image/jpeg"
        )
        
        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NSError(domain: "NetworkError", code: status, userInfo: [NSLocalizedDescriptionKey: "Server returned \(status)"])
        }
        
        print("Pothole submitted to external server successfully.")
    }

    private func createMultipartBody(boundary: String, parameters: [String: String], fileData: Data, fieldName: String, fileName: String, mimeType: String) -> Data {
        var body = Data()
        let lineBreak = "\r\n"

        for (key, value) in parameters {
            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak)\(lineBreak)")
            body.append("\(value)\(lineBreak)")
        }

        body.append("--\(boundary)\(lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\(lineBreak)")
        body.append("Content-Type: \(mimeType)\(lineBreak)\(lineBreak)")
        body.append(fileData)
        body.append(lineBreak)
        body.append("--\(boundary)--\(lineBreak)")

        return body
    }
}
