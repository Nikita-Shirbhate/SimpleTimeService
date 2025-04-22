from flask import Flask, jsonify, request
import datetime

app = Flask(__name__)

@app.route('/', methods=["GET"])
def get_time_ip():
    """
    Handles the root endpoint ('/') of the application.
    This function responds to GET requests by returning a JSON object containing
    the current timestamp and the IP address of the client making the request.
    The response includes headers to disable caching.
    Returns:
        Response: A Flask JSON response object with the following structure:
            {
                "timestamp": "<current date and time in 'Month Day, Year HH:MM:SS AM/PM' format>",
                "ip": "<client's IP address>"
            }
        The response also includes headers to prevent caching:
            - Cache-Control: "no-store, no-cache, must-revalidate, max-age=0"
            - Pragma: "no-cache"
            - Expires: "0"
    """
    # Get the current timestamp in the specified format and the client's IP address from the request object
    response = jsonify({
        "timestamp": datetime.datetime.now().strftime("%B %d, %Y %I:%M:%S %p"),
        "ip": request.remote_addr
    })

    # Set headers to disable caching
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
    
    return response