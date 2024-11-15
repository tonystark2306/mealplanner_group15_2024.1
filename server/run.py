from app import create_app

app = create_app()

#make default hello world route
@app.route("/")
def hello():
    return "Hello World!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)