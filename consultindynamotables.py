import boto3

dynamodb   = boto3.resource('dynamodb')
table_name = 'DailyPersonalPerformance'
table      = dynamodb.Table(table_name)

today = '2026-05-25'  # Exemplo de data, substitua pela data atual conforme necessário
payload = {
            "data": today,
            "30min_udemy":  "no",
            "30min_ingles": "yes",
            "30min_violao":  "no",
            "30min_violino": "no",
            "5_paginas_livro":  "no" 
        }

table.put_item(Item=payload)