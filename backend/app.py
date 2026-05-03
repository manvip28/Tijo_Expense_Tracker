import os
import json
import threading
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

# Load any environment variables from .env file
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

# Optional gspread import for Google Sheets Integration
try:
    import gspread
    from oauth2client.service_account import ServiceAccountCredentials
    GSPREAD_AVAILABLE = True
except ImportError:
    GSPREAD_AVAILABLE = False

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*", "allow_headers": ["Content-Type", "Authorization"]}})

DB_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'db.json')
db_lock = threading.Lock()
last_local_write_time = 0.0

# ----------------- gspread client setup -----------------
client = None
if GSPREAD_AVAILABLE:
    creds_str = os.getenv("GOOGLE_CREDENTIALS")
    if creds_str:
        try:
            creds_dict = json.loads(creds_str)
            scope = [
                "https://spreadsheets.google.com/feeds",
                "https://www.googleapis.com/auth/drive"
            ]
            credentials = ServiceAccountCredentials.from_json_keyfile_dict(creds_dict, scope)
            client = gspread.authorize(credentials)
            print("Successfully authenticated and authorized with Google Sheets via GOOGLE_CREDENTIALS environment variable.")
        except Exception as e:
            print(f"Failed to load GOOGLE_CREDENTIALS or authorize with gspread: {e}")

def load_local_db():
    with db_lock:
        if not os.path.exists(DB_FILE):
            # Initial seed data
            initial_data = {
                "expenses": [],
                "salary": 30000.0,
                "limits": {
                    "Monthly Budget": 10000.0,
                    "Food": 3000.0,
                    "Transport": 1500.0,
                    "Shopping": 2500.0,
                    "Health": 1500.0,
                    "Misc": 1500.0
                },
                "goals": [
                    {
                        "id": 1,
                        "title": "Stay within Budget",
                        "description": "Spend less than overall budget this month",
                        "target": "Overall Budget",
                        "status": "In Progress"
                    }
                ],
                "rewards": [],
                "savings": 0.0,
                "gifts": [
                    {
                        "id": 1001,
                        "title": "Bluetooth Speaker",
                        "target": 5000.0,
                        "unlocked": False
                    }
                ]
            }
            with open(DB_FILE, 'w') as f:
                json.dump(initial_data, f, indent=4)
            return initial_data

        with open(DB_FILE, 'r') as f:
            try:
                data = json.load(f)
                # Safe schema migrations for adding keys
                if "salary" not in data:
                    data["salary"] = 30000.0
                if "savings" not in data:
                    data["savings"] = 0.0
                if "gifts" not in data:
                    data["gifts"] = []
                if "limits" not in data:
                    data["limits"] = {
                        "Monthly Budget": 10000.0,
                        "Food": 3000.0,
                        "Transport": 1500.0,
                        "Shopping": 2500.0,
                        "Health": 1500.0,
                        "Misc": 1500.0
                    }
                if "expenses" not in data:
                    data["expenses"] = []
                if "goals" not in data:
                    data["goals"] = []
                if "rewards" not in data:
                    data["rewards"] = []
                return data
            except json.JSONDecodeError:
                return {}

def save_local_db(data):
    global last_local_write_time
    last_local_write_time = datetime.now().timestamp()
    with db_lock:
        with open(DB_FILE, 'w') as f:
            json.dump(data, f, indent=4)

# Dual Fallback Storage with Sync to Google Sheets in a non-blocking thread
def get_db():
    return load_local_db()

def _async_sheets_sync(data_copy):
    with open(os.path.join(os.path.dirname(__file__), "sync_log.txt"), "a") as log:
        log.write(f"[{datetime.now().isoformat()}] Started sync thread\n")
        
        # Authorize directly inside the thread to guarantee freshness and thread-safety
        local_client = None
        if GSPREAD_AVAILABLE:
            creds_str = os.getenv("GOOGLE_CREDENTIALS")
            if creds_str:
                try:
                    creds_dict = json.loads(creds_str)
                    scope = [
                        "https://spreadsheets.google.com/feeds",
                        "https://www.googleapis.com/auth/drive"
                    ]
                    credentials = ServiceAccountCredentials.from_json_keyfile_dict(creds_dict, scope)
                    local_client = gspread.authorize(credentials)
                    log.write(f"[{datetime.now().isoformat()}] Successfully authenticated inside sync thread\n")
                except Exception as ex:
                    log.write(f"[{datetime.now().isoformat()}] Error authenticating inside thread: {ex}\n")
                    
        if not local_client:
            log.write(f"[{datetime.now().isoformat()}] No client available for syncing\n")
            return

        try:
            # Sync to sheet "Tijo Expenses"
            try:
                sheet = local_client.open("Tijo Expenses")
                log.write(f"[{datetime.now().isoformat()}] Successfully opened Tijo Expenses\n")
            except gspread.exceptions.SpreadsheetNotFound:
                log.write(f"[{datetime.now().isoformat()}] SpreadsheetNotFound. Creating Tijo Expenses...\n")
                sheet = local_client.create("Tijo Expenses")
                try:
                    sheet.add_worksheet(title="Expenses", rows="1000", cols="10")
                    sheet.add_worksheet(title="Limits", rows="1000", cols="10")
                    sheet1 = sheet.worksheet("Sheet1")
                    sheet.del_worksheet(sheet1)
                except Exception as ex:
                    log.write(f"[{datetime.now().isoformat()}] Error initializing worksheets: {ex}\n")
                    pass

            # Try to share the spreadsheet if PERSONAL_EMAIL exists
            personal_email = os.getenv("PERSONAL_EMAIL")
            if personal_email:
                try:
                    sheet.share(personal_email, perm_type='user', role='writer')
                    log.write(f"[{datetime.now().isoformat()}] Shared with {personal_email}\n")
                except Exception as se:
                    log.write(f"[{datetime.now().isoformat()}] Error sharing spreadsheet: {se}\n")

            # Sync expenses
            try:
                try:
                    exp_ws = sheet.worksheet("Expenses")
                except Exception:
                    exp_ws = sheet.add_worksheet(title="Expenses", rows="1000", cols="10")
                
                exp_ws.clear()
                rows = [["Date", "Category", "Amount", "Type", "Description"]]
                for e in data_copy.get("expenses", []):
                    rows.append([str(e.get("date", "")), str(e.get("category", "")), float(e.get("amount", 0.0)), str(e.get("type", "Debit")), str(e.get("description", ""))])
                exp_ws.append_rows(rows)
                log.write(f"[{datetime.now().isoformat()}] Synced {len(rows)-1} expenses\n")
            except Exception as ex:
                log.write(f"[{datetime.now().isoformat()}] Error syncing Expenses worksheet: {ex}\n")

            # Sync limits
            try:
                try:
                    lim_ws = sheet.worksheet("Limits")
                except Exception:
                    lim_ws = sheet.add_worksheet(title="Limits", rows="1000", cols="10")
                    
                lim_ws.clear()
                rows = [["Category", "Limit"]]
                for k, v in data_copy.get("limits", {}).items():
                    rows.append([str(k), float(v)])
                lim_ws.append_rows(rows)
                log.write(f"[{datetime.now().isoformat()}] Synced {len(rows)-1} limits\n")
            except Exception as ex:
                log.write(f"[{datetime.now().isoformat()}] Error syncing Limits worksheet: {ex}\n")

            # Sync gifts & savings override
            try:
                try:
                    gift_ws = sheet.worksheet("Gifts_and_Savings")
                except Exception:
                    gift_ws = sheet.add_worksheet(title="Gifts_and_Savings", rows="1000", cols="10")
                    
                gift_ws.clear()
                rows = [["Type / ID", "Title", "Link", "Description", "Target Amount", "Unlocked / Current Balance"]]
                rows.append(["Total Savings", "Manual/Calculated Savings Override", "-", "-", "-", float(data_copy.get("savings", 0.0))])
                rows.append(["Monthly Salary", "Monthly base salary baseline", "-", "-", "-", float(data_copy.get("salary", 30000.0))])
                for g in data_copy.get("gifts", []):
                    rows.append([str(g.get("id")), str(g.get("title", "")), str(g.get("link", "")), str(g.get("description", "")), float(g.get("target", 0.0)), str(g.get("unlocked", False))])
                gift_ws.append_rows(rows)
                log.write(f"[{datetime.now().isoformat()}] Synced {len(rows)-1} gift, salary and savings rows\n")
            except Exception as ex:
                log.write(f"[{datetime.now().isoformat()}] Error syncing Gifts & Savings worksheet: {ex}\n")

            log.write(f"[{datetime.now().isoformat()}] Sync thread completed successfully\n")

        except Exception as e:
            log.write(f"[{datetime.now().isoformat()}] Sync thread encountered general error: {e}\n")

def _async_sheets_pull():
    if not GSPREAD_AVAILABLE:
        return
    with open(os.path.join(os.path.dirname(__file__), "sync_log.txt"), "a") as log:
        log.write(f"[{datetime.now().isoformat()}] Starting two-way pull from Excel\n")
        local_client = None
        creds_str = os.getenv("GOOGLE_CREDENTIALS")
        if creds_str:
            try:
                creds_dict = json.loads(creds_str)
                scope = [
                    "https://spreadsheets.google.com/feeds",
                    "https://www.googleapis.com/auth/drive"
                ]
                credentials = ServiceAccountCredentials.from_json_keyfile_dict(creds_dict, scope)
                local_client = gspread.authorize(credentials)
            except Exception as ex:
                log.write(f"[{datetime.now().isoformat()}] Pull thread auth error: {ex}\n")
                return

        if not local_client:
            return

        try:
            try:
                sheet = local_client.open("Tijo Expenses")
            except Exception:
                return

            db = load_local_db()
            has_changes = False

            # Pull Expenses
            try:
                exp_ws = sheet.worksheet("Expenses")
                all_rows = exp_ws.get_all_values()
                if len(all_rows) > 1:
                    new_expenses = []
                    for i, r in enumerate(all_rows[1:]):
                        if len(r) >= 4:
                            new_expenses.append({
                                "id": i + 1,
                                "date": r[0],
                                "category": r[1],
                                "amount": float(r[2]) if r[2] else 0.0,
                                "type": r[3] if len(r) > 3 else "Debit",
                                "description": r[4] if len(r) > 4 else ""
                            })
                    db["expenses"] = new_expenses
                    has_changes = True
            except Exception as e:
                log.write(f"[{datetime.now().isoformat()}] Error pulling Expenses: {e}\n")

            # Pull Limits
            try:
                lim_ws = sheet.worksheet("Limits")
                all_rows = lim_ws.get_all_values()
                if len(all_rows) > 1:
                    new_limits = {}
                    for r in all_rows[1:]:
                        if len(r) >= 2:
                            new_limits[r[0]] = float(r[1]) if r[1] else 0.0
                    db["limits"] = new_limits
                    has_changes = True
            except Exception as e:
                log.write(f"[{datetime.now().isoformat()}] Error pulling Limits: {e}\n")

            # Pull Gifts and Savings
            try:
                gift_ws = sheet.worksheet("Gifts_and_Savings")
                all_rows = gift_ws.get_all_values()
                if len(all_rows) > 1:
                    new_gifts = []
                    for r in all_rows[1:]:
                        if len(r) >= 4:
                            if r[0] == "Total Savings":
                                try:
                                    if datetime.now().timestamp() - last_local_write_time > 15:
                                        db["savings"] = float(r[5]) if len(r) > 5 and r[5] and r[5] != "-" else 0.0
                                except ValueError:
                                    pass
                            elif r[0] == "Monthly Salary":
                                try:
                                    if datetime.now().timestamp() - last_local_write_time > 15:
                                        db["salary"] = float(r[5]) if len(r) > 5 and r[5] and r[5] != "-" else 30000.0
                                except ValueError:
                                    pass
                            else:
                                new_gifts.append({
                                    "id": int(r[0]) if r[0].isdigit() else (len(new_gifts) + 2001),
                                    "title": r[1] if len(r) > 1 else "",
                                    "link": r[2] if len(r) > 2 else "",
                                    "description": r[3] if len(r) > 3 else "",
                                    "target": float(r[4]) if len(r) > 4 and r[4] else 0.0,
                                    "unlocked": r[5].lower() == "true" if len(r) > 5 else False
                                })
                    db["gifts"] = new_gifts
                    has_changes = True
            except Exception as e:
                log.write(f"[{datetime.now().isoformat()}] Error pulling Gifts & Savings: {e}\n")

            if has_changes:
                save_local_db(db)
                log.write(f"[{datetime.now().isoformat()}] Two-way sync successfully updated db from Excel changes!\n")
        except Exception as e:
            log.write(f"[{datetime.now().isoformat()}] General pull error: {e}\n")

def save_db(data):
    save_local_db(data)
    if GSPREAD_AVAILABLE:
        # Pass a completely disconnected deep copy to async daemon thread
        data_copy = json.loads(json.dumps(data))
        threading.Thread(target=_async_sheets_sync, args=(data_copy,), daemon=True).start()

# ----------------- API Endpoints -----------------
from werkzeug.security import generate_password_hash, check_password_hash

APP_USERNAME = os.getenv("APP_USERNAME", "manvi")
APP_PASSWORD_HASH = os.getenv("APP_PASSWORD_HASH")
if not APP_PASSWORD_HASH:
    plain_pw = os.getenv("APP_PASSWORD", "password123")
    APP_PASSWORD_HASH = generate_password_hash(plain_pw)

APP_TOKEN = "secret-tijo-token-abc"

@app.before_request
def before_request():
    if request.method == "OPTIONS":
        return
    if request.path == "/login":
        return
    auth_header = request.headers.get("Authorization")
    if not auth_header or auth_header != f"Bearer {APP_TOKEN}":
        return jsonify({"success": False, "message": "Unauthorized"}), 401

@app.route('/login', methods=['POST'])
def login():
    req = request.json or {}
    username = req.get('username')
    password = req.get('password')
    if username == APP_USERNAME and check_password_hash(APP_PASSWORD_HASH, password):
        return jsonify({"success": True, "token": APP_TOKEN})
    return jsonify({"success": False, "message": "Invalid username or password"}), 401

@app.route('/get-expenses', methods=['GET'])
def get_expenses():
    threading.Thread(target=_async_sheets_pull, daemon=True).start()
    db = get_db()
    return jsonify(db.get("expenses", []))

@app.route('/add-expense', methods=['POST'])
def add_expense():
    req = request.json or {}
    amount = float(req.get('amount', 0))
    category = req.get('category', 'Misc')
    description = req.get('description', '')
    type_val = req.get('type', 'Debit')
    date_str = req.get('date', datetime.now().strftime('%Y-%m-%d'))

    db = get_db()
    new_expense = {
        "id": len(db.get("expenses", [])) + 1,
        "amount": amount,
        "category": category,
        "description": description,
        "note": req.get('note', ''),
        "type": type_val,
        "date": date_str
    }
    db["expenses"].append(new_expense)

    # Evaluate goal conditions, rewards, and gifts
    evaluate_goals_and_rewards(db)

    save_db(db)
    return jsonify({"success": True, "expense": new_expense})

@app.route('/delete-expense', methods=['POST'])
def delete_expense():
    req = request.json or {}
    exp_id = req.get('id')
    db = get_db()
    original_len = len(db.get("expenses", []))
    db["expenses"] = [e for e in db.get("expenses", []) if e.get("id") != exp_id]
    
    if len(db["expenses"]) != original_len:
        evaluate_goals_and_rewards(db)
        save_db(db)
        return jsonify({"success": True, "message": "Expense deleted successfully"})
    return jsonify({"success": False, "message": "Expense not found"}), 404

@app.route('/update-expense', methods=['POST'])
def update_expense():
    req = request.json or {}
    exp_id = req.get('id')
    db = get_db()
    expenses = db.get("expenses", [])
    
    for e in expenses:
        if e.get("id") == exp_id:
            e["amount"] = float(req.get('amount', e.get("amount", 0.0)))
            e["category"] = req.get('category', e.get("category", "Misc"))
            e["description"] = req.get('description', e.get("description", ""))
            e["note"] = req.get('note', e.get("note", ""))
            e["type"] = req.get('type', e.get("type", "Debit"))
            e["date"] = req.get('date', e.get("date", ""))
            
            evaluate_goals_and_rewards(db)
            save_db(db)
            return jsonify({"success": True, "expense": e})
            
    return jsonify({"success": False, "message": "Expense not found"}), 404

@app.route('/get-limits', methods=['GET'])
def get_limits():
    db = get_db()
    return jsonify(db.get("limits", {}))

@app.route('/set-limits', methods=['POST'])
def set_limits():
    req = request.json or {}
    db = get_db()
    
    # Safe coercion to avoid any type crashes
    parsed_limits = {}
    for k, v in req.items():
        try:
            parsed_limits[str(k)] = float(v)
        except (ValueError, TypeError):
            continue

    db["limits"].update(parsed_limits)
    evaluate_goals_and_rewards(db)
    save_db(db)
    return jsonify({"success": True, "limits": db["limits"]})

@app.route('/delete-limit', methods=['POST'])
def delete_limit():
    req = request.json or {}
    category = req.get('category')
    db = get_db()
    
    if "limits" in db and category in db["limits"]:
        del db["limits"][category]
        evaluate_goals_and_rewards(db)
        save_db(db)
        return jsonify({"success": True, "limits": db["limits"]})
    return jsonify({"success": False, "message": "Category not found"}), 404

@app.route('/get-savings', methods=['GET'])
def get_savings():
    db = get_db()
    return jsonify({"savings": db.get("savings", 0.0)})

@app.route('/update-savings', methods=['POST'])
def update_savings():
    req = request.json or {}
    amount = float(req.get('savings', 0))
    db = get_db()
    db["savings"] = amount
    evaluate_goals_and_rewards(db)
    save_db(db)
    return jsonify({"success": True, "savings": db["savings"]})

@app.route('/get-salary', methods=['GET'])
def get_salary():
    db = get_db()
    return jsonify({"salary": db.get("salary", 30000.0)})

@app.route('/update-salary', methods=['POST'])
def update_salary():
    req = request.json or {}
    amount = float(req.get('salary', 30000.0))
    db = get_db()
    db["salary"] = amount
    save_db(db)
    return jsonify({"success": True, "salary": db["salary"]})

@app.route('/get-gifts', methods=['GET'])
def get_gifts():
    db = get_db()
    return jsonify(db.get("gifts", []))

@app.route('/add-gift', methods=['POST'])
def add_gift():
    req = request.json or {}
    title = req.get('title', '')
    link = req.get('link', '')
    description = req.get('description', '')
    target = float(req.get('target', 0))
    
    db = get_db()
    new_gift = {
        "id": len(db.get("gifts", [])) + 2001,
        "title": title,
        "link": link,
        "description": description,
        "target": target,
        "unlocked": False
    }
    db.setdefault("gifts", []).append(new_gift)
    evaluate_goals_and_rewards(db)
    save_db(db)
    return jsonify({"success": True, "gift": new_gift})

@app.route('/delete-gift', methods=['POST'])
def delete_gift():
    req = request.json or {}
    gift_id = req.get('id')
    db = get_db()
    original_len = len(db.get("gifts", []))
    db["gifts"] = [g for g in db.get("gifts", []) if g.get("id") != gift_id]
    
    if len(db["gifts"]) != original_len:
        save_db(db)
        return jsonify({"success": True, "message": "Gift deleted successfully"})
    return jsonify({"success": False, "message": "Gift not found"}), 404

@app.route('/get-goals', methods=['GET'])
def get_goals():
    db = get_db()
    return jsonify({
        "goals": db.get("goals", []),
        "rewards": db.get("rewards", [])
    })

@app.route('/set-goals', methods=['POST'])
def set_goals():
    req = request.json or {}
    db = get_db()
    if "goals" in req:
        db["goals"] = req["goals"]
    if "rewards" in req:
        db["rewards"] = req["rewards"]

    save_db(db)
    return jsonify({"success": True, "goals": db["goals"], "rewards": db["rewards"]})

@app.route('/rollover-salary', methods=['POST'])
def rollover_salary():
    req = request.json or {}
    leftover = float(req.get('leftover', 0.0))
    
    db = get_db()
    db["savings"] = db.get("savings", 0.0) + leftover
    db["expenses"] = []
    
    evaluate_goals_and_rewards(db)
    save_db(db)
    return jsonify({"success": True, "savings": db["savings"]})

@app.route('/reset', methods=['POST'])
def reset_db():
    db = load_local_db()
    db["expenses"] = []
    db["savings"] = 0.0
    db["gifts"] = []
    save_db(db)
    return jsonify({"success": True, "message": "Database reset successfully."})

def evaluate_goals_and_rewards(db):
    savings = float(db.get("savings", 0.0))

    # Check unlocked gifts
    gifts = db.setdefault("gifts", [])
    for g in gifts:
        if savings >= float(g.get("target", 0.0)):
            g["unlocked"] = True
        else:
            g["unlocked"] = False

if __name__ == '__main__':
    # Add a configurable port for convenience
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
