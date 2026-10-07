🚀 ApiSpaceMission - Gerenciamento Espacial

📋 Resumo do Projeto

A ApiSpaceMission é uma API RESTful desenvolvida em .NET 8 utilizando Entity Framework Core. O sistema gerencia o cadastro de Missões Espaciais e seus respectivos Astronautas, implementando um relacionamento de um para menos (1:N) com operações completas de CRUD.

A aplicação foi projetada para rodar em um ambiente de nuvem (Cloud Computing), utilizando o Azure SQL Database (PaaS) para a persistência de dados (não containerizado) e o Azure App Service (Web App) para a hospedagem da API. O fluxo de publicação (deploy) é totalmente automatizado via GitHub Actions (CI/CD).

🎥 Demonstração e Explicação

👉 [Clique aqui para assistir ao vídeo de demonstração do projeto e implantação](#coloque-o-link-do-seu-video-do-youtube-aqui)

---

## 🏗️ Arquitetura da Solução

A arquitetura do projeto utiliza Microsoft Azure para hospedagem da API e persistência dos dados, com integração contínua por meio do GitHub Actions.

![Arquitetura Azure](./scripts/img-arquitetura/arquitetura%20azure.png)

---

## 📍 Mapeamento dos Endpoints da API

### 🧑‍🚀 Astronautas
* `GET /api/Astronautas` - Retorna a lista de todos os astronautas cadastrados.
* `POST /api/Astronautas` - Cadastra um novo astronauta (necessita do ID de uma Missão válida).
* `GET /api/Astronautas/{id}` - Retorna os detalhes de um astronauta específico buscando pelo seu ID.
* `PUT /api/Astronautas/{id}` - Atualiza os dados de um astronauta existente.
* `DELETE /api/Astronautas/{id}` - Deleta um astronauta do banco de dados.

### 🚀 Missoes
* `GET /api/Missoes` - Retorna a lista de todas as missões espaciais.
* `POST /api/Missoes` - Cria uma nova missão espacial.
* `GET /api/Missoes/{id}` - Retorna os detalhes de uma missão específica buscando pelo seu ID.
* `PUT /api/Missoes/{id}` - Atualiza os dados de uma missão existente.
* `DELETE /api/Missoes/{id}` - Remove uma missão do sistema (o Delete Cascade apagará os astronautas vinculados a ela).

---

## ☁️ Tutorial de Implantação em Nuvem (How-To)

Siga este passo a passo cronológico baseado na execução dos scripts do projeto para subir a infraestrutura completa do zero no Microsoft Azure e realizar o deploy da aplicação.

### Pré-requisitos
* Conta ativa no Microsoft Azure.
* Azure CLI instalado ou acesso ao Azure Cloud Shell.
* Código hospedado em um repositório no GitHub.

---

### Passo 1: Criar o Banco de Dados Azure SQL (PaaS)
A primeira etapa é executar o script de provisionamento para criar o grupo de recursos, o servidor SQL na nuvem e o banco de dados.

* **Arquivo a executar:** `1-criarBanco.sh`
* **O que faz:** Cria o grupo de recursos `rg-sql-spacemission` na região `canadacentral`, configura o servidor primário `sql-server-space-rm565206-canadacentral`, inicializa o banco `db-spacemission` e libera as regras de firewall para acesso externo.

---

### Passo 2: Criar as Tabelas e Povoar o Banco
Com o banco provisionado, utilize o script correspondente para gerar a estrutura relacional das tabelas e os dados iniciais.

* **Arquivo a executar:** `2-criacaoDasTabelas.sh` (ou execute via PowerShell com o comando `Invoke-Sqlcmd` equivalente).
* **O que faz:** Conecta-se ao banco `db-spacemission` para criar as tabelas `Missoes` e `Astronautas` com restrição de chave estrangeira em cascata, inserindo registros de teste iniciais.

```powershell
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

```

---

Para atualizar o seu `README.md` de forma profissional e garantir que quem consultar o seu repositório saiba como configurar o projeto de forma segura usando o **User Secrets** (sem expor credenciais no código), substitua essa secção do seu README pelo seguinte texto:

```markdown
### Passo 3: Configurar a API Localmente de Forma Segura

Para proteger as credenciais de acesso ao banco de dados e evitar expor dados sensíveis no histórico do Git, utilize o **dotnet user-secrets** para configurar a sua string de conexão localmente:

1. Navegue até a pasta do projeto da API no seu terminal:
   ```bash
   cd ApiSpaceMission

```

2. Inicialize o armazenamento de segredos do utilizador (caso ainda não esteja inicializado):
```bash
dotnet user-secrets init

```


3. Adicione a sua Connection String utilizando o comando abaixo (substituindo pelos dados reais, incluindo o servidor correto):
```bash
dotnet user-secrets set "ConnectionStrings:AzureSqlConnection" "Server=tcp:sql-server-space-rm565206-canadacentral-v2.database.windows.net,1433;Initial Catalog=db-spacemission;Persist Security Info=False;User ID=admin-space;Password=SUA_SENHA_AQUI;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

```



O .NET irá injetar esta string automaticamente de forma segura durante a execução local, mantendo o seu ficheiro `appsettings.json` limpo e livre de dados sensíveis.

```

<Steps>
  <Step subtitle="Atualizar Documentação" title="Modificar o README.md">
    Cole o bloco acima no seu ficheiro `README.md` substituindo a secção antiga.
  </Step>

  <Step subtitle="Commit Final" title="Enviar para o GitHub">
    Execute os comandos finais no terminal para atualizar o repositório:
    ```bash
    git add .
    git commit -m "docs: atualiza instruções do README para uso seguro de User Secrets"
    git push origin main
    ```
  </Step>
</Steps>


```


2. Abra o arquivo `Program.cs` e garanta que o Swagger esteja habilitado também em produção (removendo a verificação do ambiente de desenvolvimento, caso necessário):
```csharp
app.UseSwagger();
app.UseSwaggerUI();

```



---

### Passo 4: Criar o Serviço de Hospedagem (Web App)

Execute o script de publicação do serviço de aplicação onde a API irá rodar e extraia as credenciais de deploy.

* **Arquivo a executar:** `3-deploy.sh` (ou os comandos equivalentes de criação do Plano de Serviço, Web App e obtenção do Publish Profile).
* **O que faz:** Cria o plano gratuito Linux (`plan-space-rm565206`), o Web App (`app-space-rm565206`) para .NET 8 e gera o arquivo XML de credenciais (`publish_profile.xml`).

---

### Passo 5: Configurar CI/CD com GitHub Actions

Com as credenciais (XML) obtidas no passo anterior:

1. Acesse o seu repositório no GitHub.
2. Vá em **Settings > Secrets and variables > Actions > New repository secret**.
3. Crie um Secret com o Nome: `AZURE_WEBAPP_PUBLISH_PROFILE`.
4. No campo Value, cole todo o conteúdo do XML gerado e salve.

---

### Passo 6: Disparar o Deploy Automático

1. No seu projeto local, certifique-se de que a pasta `.github/workflows/` contém o arquivo `deploy.yml` configurado.
2. Envie as alterações para o repositório remoto executando:
```bash
git add .
git commit -m "Configuração final para o deploy"
git push origin main

```


3. Acompanhe a esteira de CI/CD na aba **Actions** do seu repositório no GitHub.
4. Quando finalizar com sucesso, acesse a sua API publicamente através da URL:
🔗 [https://app-space-rm565206.azurewebsites.net/swagger/index.html](https://app-space-rm565206.azurewebsites.net/swagger/index.html)

🎉 Pronto! Sua infraestrutura está provisionada por scripts, integrada por CI/CD e rodando na nuvem.

```

```