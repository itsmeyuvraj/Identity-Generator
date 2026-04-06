import Foundation

struct GeneratedPersona {
    let name: String
    let email: String
    let password: String
}

enum PersonaGenerator {

    static let firstNames: [String] = [
        "Arjun", "Priya", "Rohan", "Ananya", "Vikram",
        "Sneha", "Rahul", "Kavya", "Amit", "Pooja",
        "Ravi", "Divya", "Karan", "Meera", "Sanjay",
        "Nisha", "Aditya", "Swati", "Deepak", "Anjali",
        "Suresh", "Rekha", "Manish", "Sunita", "Rajesh",
        "Geeta", "Ashok", "Usha", "Vinod", "Poonam",
        "Nikhil", "Shweta", "Gaurav", "Preeti", "Mohit",
        "Ritu", "Aman", "Kritika", "Dev", "Sakshi",
        "Harsh", "Ishaan", "Tanya", "Yash", "Simran",
        "Akash", "Neha", "Siddharth", "Varsha", "Pranav",
        "Varun", "Shruti", "Kunal", "Pallavi", "Abhinav",
        "Tanvi", "Raghav", "Isha", "Sameer", "Nandini"
    ]

    static let lastNames: [String] = [
        "Sharma", "Patel", "Singh", "Kumar", "Gupta",
        "Verma", "Joshi", "Mehta", "Nair", "Reddy",
        "Rao", "Iyer", "Pillai", "Choudhary", "Mishra",
        "Agarwal", "Bhat", "Malhotra", "Chauhan", "Pandey",
        "Tiwari", "Shukla", "Yadav", "Banerjee", "Mukherjee",
        "Chatterjee", "Das", "Sen", "Bose", "Ghosh",
        "Shah", "Jain", "Sinha", "Trivedi", "Desai",
        "Kapoor", "Khanna", "Chopra", "Bhatia", "Sethi",
        "Saxena", "Mathur", "Kulkarni", "Hegde", "Menon",
        "Naidu", "Venkat", "Swamy", "Rajan", "Krishnan"
    ]

    static func generateName() -> (first: String, last: String) {
        (firstNames.randomElement()!, lastNames.randomElement()!)
    }

    static func generateEmail(first: String, last: String, domain: String) -> (email: String, password: String) {
        let tag      = Int.random(in: 1000...9999)
        let email    = "\(first.lowercased())\(last.lowercased())\(tag)@\(domain)"
        let password = String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(12)) + "Aa1!"
        return (email, password)
    }
}
