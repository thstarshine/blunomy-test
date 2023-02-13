import pytest
import json
from flask import Flask
from flask_restful import Api
from index import Min

@pytest.fixture
def client():
    app = Flask(__name__)
    api = Api(app)
    api.add_resource(Min, "/min")
    client = app.test_client()
    yield client

def test_min_positive_numbers(client):
    data = {"numbers": [1, 2, 3, 4, 5]}
    response = client.post("/min", data=json.dumps(data), content_type="application/json")
    assert response.status_code == 200
    assert response.get_json() == {"min": 1}

def test_min_negative_numbers(client):
    data = {"numbers": [-1, -2, -3, -4, -5]}
    response = client.post("/min", data=json.dumps(data), content_type="application/json")
    assert response.status_code == 200
    assert response.get_json() == {"min": -5}
