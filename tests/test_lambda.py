import pytest
from infra.daily_personal_performance_handler.personal_performance import lambda_handler



def test_lambda_handler_get():
    # Simula um evento GET com query string
    event = {
        "requestContext": {
            "http": {
                "method": "GET"
            }
        },
        "queryStringParameters": {
            "data": "2024-06-01"
        }
    }
    
    response = lambda_handler(event, None)
    
    assert response['statusCode'] == 200
    assert 'body' in response