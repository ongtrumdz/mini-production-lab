from flask import Flask, jsonify
import os
import psycopg

DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
        "port": os.getenv("DB_PORT"),
    "dbname": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
}

# Khởi tạo ứng dụng Flask
app = Flask(__name__)

# Tạo một API endpoint cơ bản
@app.route('/health', methods=['GET'])
def health_check():
    return {"status": "ok"}

# Tạo một API cho data
@app.route('/db-health', methods=['GET'])
def db_health():
    try:
       with psycopg.connect(**DB_CONFIG) as conn:
           with conn.cursor() as cur:
               cur.execute("SELECT 1;")
               result = cur.fetchone()
       return jsonify({"status": "ok", "db": "connected", "result": result[0]}), 200
    except Exception as e:
       return jsonify({"status": "error", "db": "unreachable", "detail": str(e)}), 500

# Chạy server
if __name__ == '__main__':
    # Bật debug=True để server tự khởi động lại khi bạn sửa code
    app.run( host='0.0.0.0', port=8000)
