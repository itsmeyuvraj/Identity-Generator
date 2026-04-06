Identity Generator for macOS
A "Liquid Glass" Utility for QA & Privacy
Identity Generator is a lightweight, native macOS Menu Bar app designed for QA Engineers, developers, and privacy-conscious users. In a single click, it generates a complete "Test Persona" featuring a random Indian name and a fully functional, real-time temporary email inbox.

<p align="center">
<img src="screenshots/main_ui.png" width="350" title="Identity Generator Main UI">


<em>The "Liquid Glass" Interface in action.</em>
</p>

✨ Features
One-Click Persona: Instantly generates a random Indian name and unique email address.

Auto-Copy to Clipboard: The email is copied to your clipboard the moment you click "Generate."

Real-time Inbox: Integrated with the Mail.tm API to receive verification codes and OTPs directly in the app.

"Liquid Glass" UI: A modern, frosted-glass aesthetic that fits perfectly with the macOS Control Center design.

Background Notifications: Get a macOS system alert when a new email arrives, even if the popover is closed.

Native Performance: Built with 100% SwiftUI—minimal RAM and CPU footprint.

🛠 Why I Built This (The QA Perspective)
As a QA Engineer, I found myself wasting hours every week manually creating test accounts and managing "disposable" email tabs in my browser. I wanted a tool that:

Lived in the Menu Bar for zero-friction access.

Handled the Email Polling automatically so I never have to leave my testing environment.

Provided Instant Data (Name + Email) to speed up regression testing.

🚀 Installation & Usage
Method 1: The App (Recommended)
Download the latest .pkg from the Releases page.

Right-click the .pkg and select Open (to bypass the unidentified developer warning).

Follow the installation steps and find the icon in your Menu Bar.

Method 2: Build from Source
If you have Xcode installed:

Bash
git clone https://github.com/your-username/IdentityGenerator.git
cd IdentityGenerator
open IdentityGenerator.xcodeproj
Press Cmd + R to run.

⚙️ Technical Details
Language: Swift 5.10 / SwiftUI

API: Mail.tm

Architecture: MVVM (Model-View-ViewModel)

Design: Glassmorphism / Material Design

👤 Developer
Yuvraj Sharma QA Engineer & AI-Assisted Developer ---

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
