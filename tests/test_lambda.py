import pytest
from infra.daily_personal_performance_handler.personal_performance import lambda_handler, verificar_token


def test_verificar_token():
    # Testa um token válido (substitua pelo seu token real para o teste)
    token_valido = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InNldXJvQGZpbGlwZWRlYWJyZXUuY29tIn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
    email = verificar_token(token_valido)
    assert email == "seuro@filipedebareu.com"

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