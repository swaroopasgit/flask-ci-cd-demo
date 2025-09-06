from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def hello():
    version = os.getenv("APP_VERSION", "v0.0.1")
    return f"Hello from Flask! Version: {version}\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
