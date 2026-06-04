import json
import os
import boto3
import urllib.request
import urllib.parse

# Inicializa o resource do DynamoDB
dynamodb    = boto3.resource('dynamodb')
table_name  = os.environ.get('DYNAMODB_TABLENAME', 'daily_personal_performance')
table       = dynamodb.Table(table_name)

# Configurações do Cognito vindas das variáveis de ambiente da Lambda
COGNITO_DOMAIN    = 'daily-personal-performance-auth.auth.us-east-1.amazoncognito.com'
COGNITO_CLIENT_ID = '5qb8pffc16v5jp1nrl6oa0g7dr'
REDIRECT_URI      = 'https://daily-personal-perfomance.filipe-deabreu.com'

def verificar_auth_code(auth_header):
    """
    Troca o código de autorização pelos tokens do Cognito para validar o usuário.
    Retorna o 'sub' (ID único do usuário no Cognito) se for válido, ou None.
    """
    if not auth_header or not auth_header.startswith('Bearer '):
        return None
    
    code = auth_header.split(' ')[1]
    
    # Endpoint de Token do Cognito
    url = f"https://{COGNITO_DOMAIN}/oauth2/token"
    
    # Payload para a troca do código pelo token
    data = urllib.parse.urlencode({
        'grant_type': 'authorization_code',
        'client_id': COGNITO_CLIENT_ID,
        'code': code,
        'redirect_uri': REDIRECT_URI
    }).encode('utf-8')
    
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    
    try:
        req = urllib.request.Request(url, data=data, headers=headers, method='POST')
        with urllib.request.urlopen(req) as response:
            res_body = json.loads(response.read().decode('utf-8'))
            
            # O id_token contém as informações do perfil do usuário (como o e-mail)
            id_token = res_body.get('id_token')
            if id_token:
                # Decodifica o JWT de forma simples para pegar o 'sub' ou 'email'
                # Em produção, o ideal é validar a assinatura do JWT.
                payload_part = id_token.split('.')[1]
                # Corrige o padding do base64 se necessário
                payload_part += '=' * (4 - len(payload_part) % 4)
                import base64
                user_info = json.loads(base64.b64decode(payload_part).decode('utf-8'))
                
                return user_info.get('email') # Ou user_info.get('sub') para maior segurança
    except Exception as e:
        print(f"Erro ao validar code no Cognito: {e}")
        return None

def lambda_handler(event, context):
    headers_com_cors = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
        'Access-Control-Allow-Credentials': True
    }

    try:
        # Pega o cabeçalho Authorization (suporta maiúsculas ou minúsculas)
        req_headers = event.get('headers', {})
        auth_header = req_headers.get('Authorization') or req_headers.get('authorization')
        
        # Valida o usuário através do Cognito
        user_email = verificar_auth_code(auth_header)
        
        if not user_email:
            return {
                'statusCode': 401,
                'headers': headers_com_cors,
                'body': json.dumps({'message': 'Não autorizado. Faça login novamente.'})
            }

        # Verifica o método HTTP
        http_method = event.get('requestContext', {}).get('http', {}).get('method', 'POST')

        # --- FLUXO GET ---
        if http_method == 'GET':
            query_params = event.get('queryStringParameters') or {}
            data_date = query_params.get('data')

            if not data_date:
                return {
                    'statusCode': 400,
                    'headers': headers_com_cors,
                    'body': json.dumps({'message': 'Missing "data" parameter.'})
                }

            # Importante: A chave de busca agora idealmente conteria o ID do usuário 
            response = table.get_item(Key={'data': data_date})
            item = response.get('Item', {})

            return {
                'statusCode': 200,
                'headers': headers_com_cors,
                'body': json.dumps(item)
            }

        # --- FLUXO POST ---
        body = json.loads(event.get('body', '{}'))

        if not body or 'data' not in body:
            return {
                'statusCode': 400,
                'headers': headers_com_cors,
                'body': json.dumps({'message': 'Missing data or empty payload.'})
            }

        # Adiciona o usuário que salvou no registro por segurança
        body['usuario'] = user_email

        table.put_item(Item=body)

        return {
            'statusCode': 200,
            'headers': headers_com_cors,
            'body': json.dumps({'message': 'Data saved successfully!'})
        }

    except Exception as e:
        print(f"Error saving/getting to DynamoDB: {e}")
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'message': 'Internal server error.'})
        }