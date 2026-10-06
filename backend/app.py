from flask import Flask, jsonify

# Khởi tạo ứng dụng Flask
app = Flask(__name__)

# Tạo một API endpoint cơ bản
@app.route('/health', methods=['GET'])
def health_check():
    return {"status": "ok"}

# Chạy server
if __name__ == '__main__':
    # Bật debug=True để server tự khởi động lại khi bạn sửa code
    app.run( host='0.0.0.0', port=8000)
