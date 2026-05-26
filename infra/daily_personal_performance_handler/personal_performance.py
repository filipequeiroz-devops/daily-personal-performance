import json
import os
import boto3

# Inicializa o resource do DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLENAME', 'daily_personal_performance')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        # Extrair o corpo da requisição do API Gateway
        body = json.loads(event.get('body', '{}'))

        # O payload já vem formatado do frontend, exemplo:
        # {
        #   "data": "2026-05-25",
        #   "30min_udemy": "yes",
        #   "30min_ingles": "no",
        #   ...
        # }

        if not body or 'data' not in body:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Missing data or empty payload.'})
            }

        # Salva o item no DynamoDB
        # Assumindo que a chave primária da tabela é 'data' (tipo String)
        table.put_item(Item=body)

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': True
            },
            'body': json.dumps({'message': 'Data saved successfully!'})
        }

    except Exception as e:
        print(f"Error saving to DynamoDB: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal server error.'})
        }
