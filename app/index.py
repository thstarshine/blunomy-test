from flask import Flask, request, jsonify
from flask_restful import Api, Resource

app = Flask(__name__)
api = Api(app)

class Min(Resource):
    """Find the minimum number from a list of numbers"""
    def post(self):
        try:
            data = request.get_json(force=True)
            numbers = data.get('numbers')
            result = min(numbers)
        except:
            return {'error': '"numbers" key should contain a list of numbers'}, 400

        return {'min': result}, 200

class Ping(Resource):
    """For monitoring the health of the application"""
    def get(self):
        return {}, 200

api.add_resource(Min, "/min")
api.add_resource(Ping, "/ping")

if __name__ == '__main__':
    from waitress import serve
    serve(app, host='0.0.0.0', port=8080)
