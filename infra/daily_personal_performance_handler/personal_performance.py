import json
import os
import boto3
import base64

dynamodb    = boto3.resource('dynamodb')
table_name  = os.environ.get('DYNAMODB_TABLENAME', 'daily_personal_performance')
table       = dynamodb.Table(table_name)

def verificar_token(auth_header):
    """
    Decodifica o JWT fornecido pelo frontend e extrai o e-mail.
    """
    if not auth_header or not auth_header.startswith('Bearer '):
        return None
    
    token = auth_header.split(' ')[1]
    
    try:
        # Separa as partes do JWT e pega o payload (dados)
        payload_part = token.split('.')[1]
        
        # Corrige o padding do Base64 exigido pelo Python
        payload_part += '=' * (4 - len(payload_part) % 4)
        
        # Decodifica e converte para dicionário Python
        user_info = json.loads(base64.b64decode(payload_part).decode('utf-8'))
        
        return user_info.get('email')
    except Exception as e:
        print(f"Erro ao decodificar token: {e}")
        return None

def lambda_handler(event, context):
    headers_com_cors = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
        'Access-Control-Allow-Credentials': True
    }

    try:
        req_headers = event.get('headers', {})
        auth_header = req_headers.get('Authorization') or req_headers.get('authorization')
        
        user_email = verificar_token(auth_header)
        
        # Bloqueio de segurança: Permite apenas o seu e-mail
        MEU_EMAIL_AUTORIZADO = "seu.email.real@gmail.com" # <-- COLOQUE SEU EMAIL AQUI
        
        if not user_email or user_email != MEU_EMAIL_AUTORIZADO:
            return {
                'statusCode': 401,
                'headers': headers_com_cors,
                'body': json.dumps({'message': 'Não autorizado.'})
            }

        http_method = event.get('requestContext', {}).get('http', {}).get('method', 'POST')

        if http_method == 'GET':
            query_params = event.get('queryStringParameters') or {}
            data_date = query_params.get('data')

            if not data_date:
                return {
                    'statusCode': 400,
                    'headers': headers_com_cors,
                    'body': json.dumps({'message': 'Missing "data" parameter.'})
                }

            response = table.get_item(Key={'data': data_date})
            return {
                'statusCode': 200,
                'headers': headers_com_cors,
                'body': json.dumps(response.get('Item', {}))
            }

        body = json.loads(event.get('body', '{}'))

        if not body or 'data' not in body:
            return {
                'statusCode': 400,
                'headers': headers_com_cors,
                'body': json.dumps({'message': 'Missing data or empty payload.'})
            }

        body['usuario'] = user_email
        table.put_item(Item=body)

        return {
            'statusCode': 200,
            'headers': headers_com_cors,
            'body': json.dumps({'message': 'Data saved successfully!'})
        }

    except Exception as e:
        print(f"Erro: {e}")
        return {
            'statusCode': 500,
            'headers': headers_com_cors,
            'body': json.dumps({'message': 'Internal server error.'})
        }