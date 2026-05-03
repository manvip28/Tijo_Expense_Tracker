# TIJO Expense Tracker

**Tijo** is a premium personal expense and savings tracker built with a focus on intuitive design, smooth user experience, and seamless cloud synchronization via Google Sheets. It enables efficient financial tracking directly from your mobile device while maintaining real-time data consistency.

---

## Key Features

### Transaction Management  
- Supports both **credit (income)** and **debit (expenses)** tracking  
- Captures precise **date and time metadata** for every transaction  
- Enables structured financial logging for better analysis and history tracking  

---

### Detailed Transaction Records  
- Allows users to attach **custom notes and descriptions**  
- Supports **searchable transaction history** for quick retrieval  
- Designed for clarity, traceability, and long-term financial insights  

---

### Category-Based Budget Tracking  
- Define **custom spending limits per category**  
- Dynamically track **remaining balance and usage trends**  
- Helps enforce disciplined spending behavior  

---

### Goal Tracking and Milestone System  
- Set financial goals and monitor progress visually  
- Unlock milestone levels (Gold, Silver, Bronze) based on adherence to budget  
- Introduces a **gamified experience** to encourage consistent saving habits  

---

### Rewards and Savings Planning  
- Create personalized reward goals with **descriptions, links, and target amounts**  
- Align spending discipline with tangible incentives  
- Encourages structured saving alongside expense tracking  

---

### Google Sheets Integration  
- Implements **two-way synchronization** between the mobile app and Google Sheets  
- Ensures near real-time updates with a **15-second write-lock mechanism** to maintain data consistency  
- Provides a reliable, cloud-backed alternative to traditional database systems  

---

## Project Architecture

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

### Tech Stack
- **Frontend:** Flutter & Dart (Provider state management, Google Fonts)
- **Backend:** Flask & Python
- **Database / Cloud Sync:** Local JSON fallback + Google Sheets (via gspread)

---

## Setup & Deployment

To build the app for yourself or deploy the backend, please refer to our detailed **[Setup Guide (setup.md)](./setup.md)**.
