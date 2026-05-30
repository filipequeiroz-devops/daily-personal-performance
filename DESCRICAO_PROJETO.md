# 🚀 Daily Personal Performance - Descrição do Projeto

Este projeto é uma aplicação web **Serverless** hospedada na AWS, projetada para registrar e acompanhar o desempenho e as tarefas pessoais diárias (Daily Personal Performance). 

## 🏗️ Arquitetura e Tecnologias

A aplicação é dividida em Frontend, Backend e Infraestrutura como Código (IaC), utilizando serviços totalmente gerenciados da AWS e integrados via CI/CD pelo GitHub Actions.

### 1. Frontend (`/app`)
- Aplicação web estática (HTML/CSS/JS) contida em `app/index.html`.
- Apresenta uma interface de "Task List" para o usuário interagir e registrar sua performance.
- Hospedado no **AWS S3** e distribuído através do **Amazon CloudFront** para baixa latência.

### 2. Backend (`/infra/daily_personal_performance_handler/`)
- Uma função **AWS Lambda** escrita em **Python** (`personal_performance.py`).
- Recebe requisições via **Amazon API Gateway**.
- Lida com dois tipos de requisições:
  - **GET**: Busca os dados de performance de uma data específica usando o parâmetro `data`.
  - **POST**: Salva os dados e tarefas submetidos pelo frontend no banco de dados.
- Banco de dados NoSQL utilizado: **Amazon DynamoDB** (configurado para a tabela `daily_personal_performance`).

### 3. Infraestrutura como Código - IaC (`/infra`)
Toda a infraestrutura da AWS é provisionada de forma automatizada utilizando o **Terraform**. Entre os recursos gerenciados estão:
- **S3 & CloudFront**: Para hospedagem e CDN do frontend.
- **API Gateway**: Para roteamento das requisições REST para a função Lambda.
- **Lambda & IAM**: Execução de código backend com as permissões corretas (policies).
- **DynamoDB**: Banco de dados para persistência das informações.
- **Cognito**: Gerenciamento e autenticação de usuários.
- **Route53 & ACM**: Configuração de domínio customizado e certificados de segurança (HTTPS).

### 4. Testes e CI/CD (`/tests` e `.github/workflows`)
- **Testes**: O projeto conta com testes unitários no backend utilizando `pytest`, localizados na pasta `tests/` (ex: `test_lambda.py`).
- **Pipeline de Deploy**: Um workflow configurado no GitHub Actions (`deploy.yaml`) é acionado em *pushes* na branch `main` ou `master`. A esteira executa validação de HTML, testes, e faz o deploy do Frontend (S3) e da Infraestrutura (Terraform).

## 🗂️ Estrutura de Diretórios
- `.github/workflows/`: Pipelines de CI/CD.
- `app/`: Código fonte do frontend da aplicação (HTML/CSS/JS).
- `infra/`: Código Terraform gerenciando toda a infraestrutura AWS e o código Python do AWS Lambda.
- `tests/`: Scripts de testes automatizados (`pytest`).
- `consultindynamotables.py`: Script utilitário em Python para consultar as tabelas no DynamoDB manualmente.
