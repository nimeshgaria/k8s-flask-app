from flask import Flask, render_template_string

app = Flask(__name__)

@app.route('/')
def home():
    # HTML with inline CSS for the background color
    html_content = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Flask app is ready</title>
    </head>
    <body>
        <h1 style="text-align: center;">
            Hello from <span style="background-color: #4a51f5; color: white; padding: 5px;">Flask app is ready !</span>
        </h1>
    </body>
    </html>
    """
    return render_template_string(html_content)

if __name__ == '__main__':
    app.run(host='0.0.0.0',debug=True)
    