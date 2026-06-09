import pytest
import json
import base64
import os
import boto3

os.environ['DYNAMODB_TABLENAME']   = 'tabela-local-default' #variável necessaria para o teste, mesmo que a tabela não exista (pois não vamos testar a parte do DynamoDB aqui)
os.environ['MEU_EMAIL_AUTORIZADO'] = 'usuario@exemplo.com' #variável necessária para o teste de autorização
from infra.daily_personal_performance_handler.personal_performance import lambda_handler, verificar_token



# --- HELPER PARA GERAR TOKEN DE TESTE ---
def gerar_token_mock(payload):
    """
    Gera um JWT fictício compatível com verificar_token().
    """

    payload_json = json.dumps(payload)

    payload_b64 = (
        base64.urlsafe_b64encode(payload_json.encode("utf-8"))
        .decode("utf-8")
        .rstrip("=")
    )

    return f"header.{payload_b64}.signature"

def test_verificar_token_sucesso():

    payload = {
        "email": "usuario@exemplo.com",
        "name": "Filipe"
    }

    token       = gerar_token_mock(payload)
    auth_header = f"Bearer {token}"
    email       = verificar_token(auth_header)

    assert email == "usuario@exemplo.com"

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