🌾 AI-Powered Wheat Rust Detection Application

An integrated, AI-driven platform for early detection and management of wheat rust diseases—designed for farmers, researchers, and agricultural experts in Ethiopia and beyond.

📌 Overview

The Wheat Rust Detection Application leverages deep learning and mobile-first technology to detect and classify wheat rust diseases (brown rust, yellow rust,black rust and healthy wheat) from leaf images. This cross-platform solution supports offline functionality, Amharic language, expert engagement, and real-time recommendations for effective disease control and management.

🧠 Functional Highlights

✅ Disease Detection

Utilizes MobileNetV2, a lightweight CNN model, to identify:
Yellow Rust
Black Rust
Brown Rust
Healthy Wheat
Trained on a labeled Kaggle dataset(https://www.kaggle.com/datasets/kushagra3204/wheat-plant-diseases) with enhanced accuracy via data augmentation (flipping, contrast, rotation).
🖼️ Image Processing

Accepts image uploads and applies pre-processing to improve prediction accuracy.
Compatible with both camera-captured and gallery-uploaded images.
💊 Treatment Recommendations

Offers tailored recommendations for identified diseases.
🌐 Offline Functionality

Enables disease detection without an active internet connection by using on-device AI inference.
👥 Community Engagement

Community forum for discussions, collaboration, and shared knowledge.
Experts and researchers can post insights and articles.
🎓 Expert Support

Farmers can connect with verified agricultural experts for guidance.
Admin-reviewed certification process ensures expert authenticity.
🤖 AI Chatbot Assistance

Integrated chatbot to support queries from farmers, researchers, and agricultural officers.
📈 Feedback and Data Collection

Gathers interaction data to improve disease detection.
Built-in feedback system enhances user experience over time.
🌍 Amharic Language Support

Full UI translation
Toggle between English ↔ Amharic
⚙️ Non-Functional Requirements

Performance:Optimized for speed and efficiency with concurrent user support.
Scalability:Easily scalable infrastructure using Docker and RESTful APIs.
Security:Encrypted data handling, secure login, and role-based access.
Reliability:High uptime with fallback mechanisms and error handling.
Compatibility:Works across Android and iOS, optimized for rural connectivity.
User Experience:Intuitive, clean interface tailored for agricultural users.
Compliance:Adheres to privacy regulations and ethical data collection.
Maintainability: Modular architecture with clear APIs for future extensions.
💻 Tech Stack

Layer	Tech
Mobile App	Flutter
Backend	Python, Django, Django REST Framework
Admin Panel	React, Mantine
Database	PostgreSQL
ML Model	MobileNetV2
APIs	RESTful APIs with Postman
Deployment	Docker, Render
Version Control	Git, GitHub
IDE	Visual Studio Code
🛠️ Features Breakdown

Feature	Description
Expert Approval	Admin reviews expert credentials and approves them via admin page
Voice Input	Farmers can ask questions and get responses without typing in the communitz bz recording their queries and posting them along with the picture
Data Logging	Tracks predictions and feedback for continuous ML improvement
Community Forum	Platform for agricultural discussions and Q&A
Chatbot Assistant	Provides quick, AI-driven help to users
📂 Project Structure

├── backend/
│ ├── api/
│ └── rust_model/
├── mobile_app/
├── admin_dashboard/
│ ├── components/
│ └── pages/

📋 Development Setup

▶️ Backend (Django)

cd backend/
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
📱 Mobile App (Flutter)

cd mobile_app/
flutter pub get
flutter run
🖥️ Admin Panel (React)
cd adminPage/
npm install
npm start
AI Model
https://www.kaggle.com/code/redietgebrecherkos/notebookf940171ee2

🧪 Testing & Documentation

Postman-used for API testing
📚 Dataset Source

Labeled dataset sourced from Kaggle, featuring:

Healthy wheat
Yellow rust
Brown rust
Black rust
Data Augmentation used to improve robustness against real-world variations.

🧑‍🌾 Field Validation

Conducted a structured interview with a senior expert from the Ethiopian Agricultural Transformation Institute (ATI) to align the solution with local wheat disease challenges and agronomic practices.

👨‍💻 Project Team

Role	Name
Mobile Developer	Etsubdink Hayelom
Admin Dashboard Developer	Bethelhem Habtamu
Backend Developer	Bethelhem Gebeyehu
Machine Learning Engineer	Rediet Teklay
Under the supervision of Eleni Teshome

📬 Contact

Feel free to reach out for collaboration, questions, or suggestions:
📧 bettynuriye@gmail.com 📧 bethelhemgebeyehu@gmail.com 📧 Etsubhayelom@gmail.com 📧 redietteklay8@gmail.com# Wheat-Rust-Detection-Application
