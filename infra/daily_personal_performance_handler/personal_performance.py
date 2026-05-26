import json
import os
import boto3

# Inicializa o resource do DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLENAME', 'daily_personal_performance')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        # Verifica o método HTTP
        http_method = event.get('requestContext', {}).get('http', {}).get('method', 'POST')

        # Se for GET, busca os dados da data atual no DynamoDB
        if http_method == 'GET':
            query_params = event.get('queryStringParameters') or {}
            data_date = query_params.get('data')

            if not data_date:
                return {
                    'statusCode': 400,
                    'headers': {'Access-Control-Allow-Origin': '*'},
                    'body': json.dumps({'message': 'Missing "data" parameter.'})
                }

            response = table.get_item(Key={'data': data_date})
            item = response.get('Item', {})

            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Credentials': True
                },
                'body': json.dumps(item)
            }

        # Se for POST (ou outro default), salva no DynamoDB
        body = json.loads(event.get('body', '{}'))

        if not body or 'data' not in body:
            return {
                'statusCode': 400,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'message': 'Missing data or empty payload.'})
            }

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
        print(f"Error saving/getting to DynamoDB: {e}")
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'message': 'Internal server error.'})
        }
