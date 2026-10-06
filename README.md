🚀 ApiSpaceMission - Gerenciamento Espacial

📋 Resumo do Projeto

A ApiSpaceMission é uma API RESTful desenvolvida em .NET 8 utilizando Entity Framework Core. O sistema gerencia o cadastro de Missões Espaciais e seus respectivos Astronautas, implementando um relacionamento de um para muitos (1:N) com operações completas de CRUD.

A aplicação foi projetada para rodar em um ambiente de nuvem (Cloud Computing), utilizando o Azure SQL Database (PaaS) para a persistência de dados (não containerizado) e o Azure App Service (Web App) para a hospedagem da API. O fluxo de publicação (deploy) é totalmente automatizado via GitHub Actions (CI/CD).

🎥 Demonstração e Explicação

👉 Clique aqui para assistir ao vídeo de demonstração do projeto e implantação


## 🏗️ Arquitetura da Solução

A arquitetura do projeto utiliza Microsoft Azure para hospedagem da API e persistência dos dados, com integração contínua por meio do GitHub Actions.

![Arquitetura Azure](./scripts/img-arquitetura/arquitetura%20azure.png)


🧑‍🚀 Astronautas

GET /api/Astronautas - Retorna a lista de todos os astronautas cadastrados.

POST /api/Astronautas - Cadastra um novo astronauta (necessita do ID de uma Missão válida).

GET /api/Astronautas/{id} - Retorna os detalhes de um astronauta específico buscando pelo seu ID.

PUT /api/Astronautas/{id} - Atualiza os dados de um astronauta existente.

DELETE /api/Astronautas/{id} - Deleta um astronauta do banco de dados.

🚀 Missoes

GET /api/Missoes - Retorna a lista de todas as missões espaciais.

POST /api/Missoes - Cria uma nova missão espacial.

GET /api/Missoes/{id} - Retorna os detalhes de uma missão específica buscando pelo seu ID.

PUT /api/Missoes/{id} - Atualiza os dados de uma missão existente.

DELETE /api/Missoes/{id} - Remove uma missão do sistema (o Delete Cascade apagará os astronautas vinculados a ela).



☁️ Tutorial de Implantação em Nuvem (How-To)

Siga este passo a passo cronológico para subir a infraestrutura completa do zero no Microsoft Azure e realizar o deploy da aplicação.

Pré-requisitos

Conta ativa no Microsoft Azure.

Azure CLI instalado ou acesso ao Azure Cloud Shell.

Código hospedado em um repositório no GitHub.

Passo 1: Criar o Banco de Dados Azure SQL (PaaS)

A primeira etapa é criar o local onde os dados serão salvos. Abra o Azure Cloud Shell (Bash) e execute o script de provisionamento da infraestrutura primária e secundária (Failover):

Crie um arquivo ou cole diretamente os comandos no terminal:

# Criar Grupo de Recursos
az group create --name rg-sql-spacemission --location canadacentral

# Criar Servidor SQL Primário
az sql server create \
  --name sql-server-space-rm565206-canadacentral \
  --resource-group rg-sql-spacemission \
  --location canadacentral \
  --admin-user admin-space \
  --admin-password 'Fiap@2tdsvms' \
  --enable-public-network true

# Criar o Banco de Dados
az sql db create \
  --resource-group rg-sql-spacemission \
  --server sql-server-space-rm565206-canadacentral \
  --name db-spacemission \
  --service-objective Basic \
  --backup-storage-redundancy Local \
  --zone-redundant false

# Liberar o Firewall para acesso externo (Testes/Deploy)
az sql server firewall-rule create \
  --resource-group rg-sql-spacemission \
  --server sql-server-space-rm565206-canadacentral \
  --name liberaGeral \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255


(Nota: O script completo de réplica e failover foi executado no laboratório, mas o essencial para a API funcionar é o banco primário acima).

Passo 2: Criar as Tabelas e Povoar o Banco (temos também de exemplo o script sql no projeto)

Mude seu console no Azure para PowerShell e execute o script abaixo para criar as tabelas Missoes e Astronautas e inserir dados de teste.

Invoke-Sqlcmd -ServerInstance "sql-server-space-rm565206-canadacentral.database.windows.net" `
              -Database "db-spacemission" `
              -Username "admin-space" `
              -Password "Fiap@2tdsvms" `
              -Query "
                CREATE TABLE Missoes (Id INT IDENTITY(1,1) PRIMARY KEY, Nome NVARCHAR(MAX) NOT NULL, Destino NVARCHAR(MAX) NOT NULL);
                CREATE TABLE Astronautas (Id INT IDENTITY(1,1) PRIMARY KEY, Nome NVARCHAR(MAX) NOT NULL, Especialidade NVARCHAR(MAX) NOT NULL, MissaoId INT NOT NULL, CONSTRAINT FK_Astronautas_Missoes FOREIGN KEY (MissaoId) REFERENCES Missoes(Id) ON DELETE CASCADE);
                INSERT INTO Missoes (Nome, Destino) VALUES ('Apollo 11', 'Lua');
                INSERT INTO Astronautas (Nome, Especialidade, MissaoId) VALUES ('Neil Armstrong', 'Comandante', 1);
              "


Passo 3: Configurar a API Localmente

Antes de subir a API, conecte-a ao banco recém-criado.

No projeto .NET, abra o arquivo appsettings.json.

Adicione a sua Connection String:

"ConnectionStrings": {
  "AzureSqlConnection": "Server=tcp:sql-server-space-rm565206-canadacentral.database.windows.net,1433;Initial Catalog=db-spacemission;Persist Security Info=False;User ID=admin-space;Password=Fiap@2tdsvms;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}


Abra o arquivo Program.cs e remova o bloco "if (app.Environment.IsDevelopment())" em volta da configuração do Swagger, para garantir que a documentação funcione no Azure:

app.UseSwagger();
app.UseSwaggerUI();


Passo 4: Criar o Serviço de Hospedagem (Web App)

Volte ao Azure Cloud Shell (Bash) e crie o servidor onde a API irá rodar, além de extrair as credenciais de deploy:

# Criar o Plano de Serviço (Linux Gratuito F1)
az appservice plan create --name plan-space-rm565206 --resource-group rg-sql-spacemission --sku F1 --is-linux --location canadacentral

# Criar o Web App (.NET 8)
az webapp create --name app-space-rm565206 --plan plan-space-rm565206 --resource-group rg-sql-spacemission --runtime "DOTNETCORE|8.0"

# Gerar arquivo de credenciais (Publish Profile)
az webapp deployment list-publishing-profiles --name app-space-rm565206 --resource-group rg-sql-spacemission --xml > publish_profile.xml

# Mostrar o XML na tela (copie todo o resultado)
cat publish_profile.xml


Passo 5: Configurar CI/CD com GitHub Actions

Com as credenciais (XML) em mãos, vamos automatizar o deploy:

Acesse seu repositório no GitHub.

Vá em Settings > Secrets and variables > Actions > New repository secret.

Crie um Secret com o Nome: AZURE_WEBAPP_PUBLISH_PROFILE.

No campo Value, cole todo o conteúdo do XML copiado no Passo 4 e salve.

Passo 6: Disparar o Deploy Automático

No seu projeto local, certifique-se de que existe a pasta .github/workflows/ contendo o arquivo deploy.yml.

Salve todas as alterações e faça o envio para a branch principal:

git add .
git commit -m "Configuração final para o deploy"
git push origin main


Acesse a aba Actions no seu repositório do GitHub e acompanhe a esteira de CI/CD.

Quando finalizar, acesse a sua API publicamente pela URL (adicione /swagger ao final para ver a interface gráfica):
https://app-space-rm565206.azurewebsites.net/swagger/index.html

🎉 Pronto! Sua infraestrutura está provisionada e sua aplicação está rodando na nuvem em integração contínua.