# TIJO Expense Tracker 📈💰

**Tijo** is a highly premium, glassmorphic Personal Expense and Savings Tracker. Designed with rich visual aesthetics, smooth animations, and advanced **Google Sheets integration**, it keeps your finances organized right on your phone!

---

## ✨ Key Features

- 💳 **Credit & Debit Logging:** Record any income (Credit) or spending (Debit) with precise date and time tracking.
- 📓 **Detailed Transactions:** Add customized notes and searchable descriptions to any logged transaction.
- 🎯 **Visual Financial Goals:** Track your financial limit metrics across custom categories.
- 🏆 **Dynamic Milestones:** Achieve Gold, Silver, and Bronze badges directly on the milestones tab as you adhere to your budget goals.
- 🎁 **Gifts & Treats Dashboard:** Add specific gifts with custom descriptions, links, and target savings goals. 
- 🔄 **Two-Way Google Sheets Sync:** Changes automatically reflect between your Flutter app and your Excel sheet (Google Sheets) on a 15-second write-safety lock.

---

## 🏗️ Project Architecture

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

## 🚀 Setup & Deployment

To build the app for yourself or deploy the backend, please refer to our detailed **[Setup Guide (setup.md)](./setup.md)**.
