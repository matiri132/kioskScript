from flask import Flask
app = Flask(__name__)

@app.route("/")
def index():
    return """
        Welcome to my website!<br /><br />
        <a href="/hello">Go to hello world</a>
    """

def hello():
    return "<h1 style='color:blue'>Hello There!</h1>"

if __name__ == "__main__":
    app.run(host='HOSTNAME')
