# Tijo Expense & Savings Tracker

A beautiful, glassmorphic Personal Expense & Savings Tracker built with Flutter (Frontend) and Flask (Backend), integrated with Google Sheets for advanced two-way real-time data synchronization.

---

## Project Structure

```
Tijo_Expense_Tracker/
├── backend/                  # Flask REST API server
│   ├── app.py                # Main backend logic & Sheets synchronization
│   ├── db.json               # Local backup storage database
│   └── requirements.txt      # Python dependencies list
└── frontend/                 # Flutter mobile application
    ├── lib/                  # Application source code
    ├── pubspec.yaml          # Flutter dependencies
    └── icons/                # App icon assets
```

---

## 1. Backend Setup & Deployment

### Local Development Setup
1. Open terminal and navigate to the backend folder:
   ```bash
   cd backend
   ```
2. Create a virtual environment and install dependencies:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```
3. Create a `.env` file inside the `backend` folder (you can use `.env.example` as a template and replace the placeholders with your actual Google Service Account credentials and credentials for authentication).
   
   To securely hash your password, navigate to the `backend` directory and run:
   ```bash
   python hash_password.py your_password
   ```
   
   Then add your username and the generated hash string to your `.env` file:
   ```env
   GOOGLE_CREDENTIALS={"type": "service_account", "project_id": "...", ...}
   APP_USERNAME=<your_username>
   APP_PASSWORD_HASH=<your_hashed_password_string>
   ```
4. Run the backend locally:
   ```bash
   python app.py
   ```
   *Your backend will be running at `http://127.0.0.1:5000`.*

### Deployment to Render / PythonAnywhere
1. Create a public or private GitHub repository and push your project.
2. Sign up on [Render.com](https://render.com) and create a **New Web Service**.
3. Connect your GitHub repository.
4. Set the build and start commands:
   - **Build Command:** `pip install -r backend/requirements.txt`
   - **Start Command:** `gunicorn --chdir backend app:app`
5. Go to **Environment Variables** settings in Render and add:
   - Key: `GOOGLE_CREDENTIALS`
   - Value: (Paste your exact JSON service account credentials string here)
6. Once deployed, Render will provide your public server URL, for example: `https://abc-1.onrender.com`.

---

## 2. Frontend Setup & Build

> [!IMPORTANT]
> You **must** deploy your backend separately first (either run it locally or host it online on Render/PythonAnywhere) before building the mobile app. Once you have your backend's URL, update it in the frontend's configuration file as described below.

### Local Configuration
1. Open `frontend/lib/api_service.dart` and update the `baseUrl` to point exactly to your newly deployed Render/PythonAnywhere server URL:
   ```dart
   static String baseUrl = 'https://abc-1.onrender.com';
   ```

2. Open terminal in the `frontend` folder and download the required Flutter packages:
   ```bash
   cd frontend
   flutter pub get
   ```

### To Generate/Update App Icons
1. Ensure your custom logo image is placed at `frontend/icons/logo.jpeg`.
2. Generate the app launcher icons using the following command:
   ```bash
   dart run flutter_launcher_icons
   ```

### Build & Install the Mobile App
1. Build the release APK package:
   ```bash
   flutter build apk --release
   ```
2. Retrieve the generated `.apk` file located at:
   `frontend/build/app/outputs/flutter-apk/app-release.apk`
3. Connect your Android phone to the computer via USB and copy the `app-release.apk` file into your phone's **Downloads** folder.
4. On your phone, open your File Manager, click on `app-release.apk`, allow installations from unknown sources if prompted, and click **Install**.
