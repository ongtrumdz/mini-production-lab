from flask import Flask, jsonify, request
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

# Tạo một API kiểm tra kết nối DB
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

# Tạo một API cho kiểm tra table user
@app.route('/users', methods=['GET'])
def get_users():
    try:
        with psycopg.connect(**DB_CONFIG) as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT id, name, created_at FROM users ORDER BY id;")
                rows = cur.fetchall()
        users = [
                {"id": r[0], "name": r[1], "created_at": r[2].isoformat()}
                for r in rows
        ]
        return jsonify(users), 200
    except Exception as e:
        app.logger.error(f"lỗi đọc users: {e}")
        return jsonify({"status": "error"}), 500

# Tạo một API gửi client đến data
@app.route('/users', methods=['POST'])
def create_user():
    data = request.get_json(silent=True)
    if not data:
        return jsonify({"error": "JSON body is required"}), 400

    name = data.get("name")
    if not name:
        return jsonify({"error": "name is required"}), 400
    try:
        with psycopg.connect(**DB_CONFIG) as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO users (name) VALUES (%s) RETURNING id, name, created_at;",(name,),
                )
                r = cur.fetchone()

        user = {"id": r[0], "name": r[1], "created_at": r[2].isoformat()}
        return jsonify(user), 201
    except Exception:
        app.logger.exception("loi tao user")
        return jsonify({"status": "error"}), 500

# Chạy server
if __name__ == '__main__':
    # Bật debug=True để server tự khởi động lại khi bạn sửa code
    app.run( host='0.0.0.0', port=8000)
