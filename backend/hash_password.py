import sys
from werkzeug.security import generate_password_hash

def main():
    if len(sys.argv) < 2:
        print("Usage: python hash_password.py <password>")
        sys.exit(1)
    
    password = sys.argv[1]
    hashed = generate_password_hash(password)
    print("\nYour securely hashed password string is:")
    print("-" * 40)
    print(hashed)
    print("-" * 40)
    print("\nCopy and paste this string into your .env file as follows:")
    print(f"APP_PASSWORD_HASH={hashed}\n")

if __name__ == "__main__":
    main()
