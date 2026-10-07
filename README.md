Aqui está o ficheiro **`README.md`** completo, estruturado e corrigido para o seu projeto, incluindo a secção de integrantes (com o destaque da representante), a arquitetura, o mapeamento dos endpoints, e um tutorial (*How-To*) detalhado e aprofundado na configuração do **GitHub Actions (CI/CD)** e do **User Secrets**.

Pode copiar todo o conteúdo abaixo diretamente para o seu ficheiro `README.md`:

```markdown
# 🚀 ApiSpaceMission - Gerenciamento Espacial

## 👥 Integrantes do Grupo
* **Felipe Ribeiro Salles de Camargo** | RM565224
* **João Pedro Pereira Camilo** | RM562005
* **Lucas Matsubara Reis** | RM565020
* **Pamella Christiny Chaves Brito** | RM565206 **(Representante)**

---

## 📋 Resumo do Projeto

A **ApiSpaceMission** é uma API RESTful desenvolvida em .NET 8 utilizando Entity Framework Core. O sistema gerencia o cadastro de Missões Espaciais e seus respectivos Astronautas, implementando um relacionamento de um para muitos (1:N) com operações completas de CRUD.

A aplicação foi projetada para rodar em um ambiente de nuvem (*Cloud Computing*), utilizando o **Azure SQL Database (PaaS)** para a persistência de dados (não containerizado) e o **Azure App Service (Web App)** para a hospedagem da API. O fluxo de publicação (*deploy*) é totalmente automatizado via **GitHub Actions (CI/CD)**.

---

## 🎥 Demonstração e Explicação

👉 [Clique aqui para assistir ao vídeo de demonstração do projeto e implantação](#coloque-o-link-do-seu-video-do-youtube-aqui)

---

## 🏗️ Arquitetura da Solução

A arquitetura do projeto utiliza o Microsoft Azure para a hospedagem da API e persistência dos dados, com integração contínua e entrega contínua geridas pelo GitHub Actions.

![Arquitetura Azure](./scripts/img-arquitetura/arquitetura%20azure.png)

---

## 📍 Mapeamento dos Endpoints da API

### 🧑‍🚀 Astronautas
* `GET /api/Astronautas` - Retorna a lista de todos os astronautas cadastrados.
* `POST /api/Astronautas` - Cadastra um novo astronauta (necessita do ID de uma Missão válida).
* `GET /api/Astronautas/{id}` - Retorna os detalhes de um astronauta específico buscando pelo seu ID.
* `PUT /api/Astronautas/{id}` - Atualiza os dados de um astronauta existente.
* `DELETE /api/Astronautas/{id}` - Deleta um astronauta do banco de dados.

### 🚀 Missões
* `GET /api/Missoes` - Retorna a lista de todas as missões espaciais.
* `POST /api/Missoes` - Cria uma nova missão espacial.
* `GET /api/Missoes/{id}` - Retorna os detalhes de uma missão específica buscando pelo seu ID.
* `PUT /api/Missoes/{id}` - Atualiza os dados de uma missão existente.
* `DELETE /api/Missoes/{id}` - Remove uma missão do sistema (o *Delete Cascade* apagará os astronautas vinculados a ela).

---

## ☁️ Tutorial de Implantação em Nuvem (How-To)

Siga este passo a passo cronológico para subir a infraestrutura completa do zero no Microsoft Azure, configurar o ambiente e realizar o deploy automatizado da aplicação via GitHub Actions.

### Pré-requisitos
* Conta ativa no Microsoft Azure.
* .NET 8 SDK instalado localmente.
* Azure CLI instalado ou acesso ao Azure Cloud Shell.
* Código fonte hospedado em um repositório no GitHub.

---

### Passo 1: Criar o Banco de Dados Azure SQL (PaaS)
A primeira etapa é executar o script de provisionamento para criar o grupo de recursos, o servidor SQL na nuvem e a base de dados.

* **Arquivo de referência:** `1-criarBanco.sh`
* **O que faz:** Cria o grupo de recursos `rg-sql-spacemission` na região `canadacentral`, configura o servidor primário `sql-server-space-v2-rm565206-canadacentral-v2`, inicializa o banco `db-space-rm565206` e libera as regras de firewall para acesso externo.

---

### Passo 2: Criar as Tabelas e Povoar o Banco
Com o banco provisionado, utilize o script correspondente para gerar a estrutura relacional das tabelas e os dados iniciais.

* **Arquivo de referência:** `2-criacaoDasTabelas.sh` (ou execute via PowerShell com o comando `Invoke-Sqlcmd` equivalente).
* **Comando SQL de execução:**
```powershell
Invoke-Sqlcmd -ServerInstance "sql-server-space-v2-rm565206-canadacentral-v2.database.windows.net" `
              -Database "db-space-rm565206" `
              -Username "user-space" `
              -Password "Fiap2026!" `
              -Query "
                CREATE TABLE Missoes (Id INT IDENTITY(1,1) PRIMARY KEY, Nome NVARCHAR(MAX) NOT NULL, Destino NVARCHAR(MAX) NOT NULL);
                CREATE TABLE Astronautas (Id INT IDENTITY(1,1) PRIMARY KEY, Nome NVARCHAR(MAX) NOT NULL, Especialidade NVARCHAR(MAX) NOT NULL, MissaoId INT NOT NULL, CONSTRAINT FK_Astronautas_Missoes FOREIGN KEY (MissaoId) REFERENCES Missoes(Id) ON DELETE CASCADE);
                INSERT INTO Missoes (Nome, Destino) VALUES ('Apollo 11', 'Lua');
                INSERT INTO Astronautas (Nome, Especialidade, MissaoId) VALUES ('Neil Armstrong', 'Comandante', 1);
              "

```

---

### Passo 3: Configurar a API Localmente de Forma Segura (User Secrets)

Para proteger as credenciais de acesso ao banco de dados e evitar expor dados sensíveis no histórico do Git, utilize o **dotnet user-secrets** para configurar a sua string de conexão localmente:

1. Navegue até a pasta do projeto da API no seu terminal:
```bash
cd ApiSpaceMission

```


2. Inicialize o armazenamento de segredos do utilizador (caso ainda não esteja inicializado):
```bash
dotnet user-secrets init

```


3. Adicione a sua Connection String utilizando o comando abaixo:
```bash
dotnet user-secrets set "ConnectionStrings:AzureSqlConnection" "Server=tcp:sql-server-space-v2-rm565206-canadacentral-v2.database.windows.net,1433;Initial Catalog=db-space-rm565206;Persist Security Info=False;User ID=user-space;Password=Fiap2026!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

```


*Nota: O .NET injeta esta string automaticamente durante a execução local, mantendo o seu ficheiro `appsettings.json` limpo e livre de dados sensíveis.*

---

### Passo 4: Criar o Serviço de Hospedagem (Web App) no Azure

Execute o script de publicação do serviço de aplicação onde a API irá rodar.

* **Arquivo de referência:** `3-deploy.sh`
* **O que faz:** Cria o plano de serviço Linux, o Web App `app-space-v2-rm565206` configurado para o runtime do .NET 8, e permite extrair o perfil de publicação (`Publish Profile`).

---

### Passo 5: Configurar CI/CD com GitHub Actions (Passo a Passo Detalhado)

Para automatizar o processo de build e deploy sempre que enviar código para o repositório, o GitHub Actions precisa de aceder ao Azure através de um perfil de publicação seguro (*Publish Profile*). Siga rigorosamente este procedimento:

1. **Obter o Publish Profile no Azure:**
* Aceda ao [Portal do Azure](https://www.google.com/search?q=https://portal.azure.com/).
* Procure e abra o seu Web App (`app-space-v2-rm565206`).
* No topo da página de visão geral (*Overview*), clique no botão **Obter perfil de publicação** (*Get publish profile*). Um ficheiro com extensão `.publishsettings` será descarregado para o seu computador.
* Abra este ficheiro utilizando um editor de texto (como o Bloco de Notas, VS Code ou Notepad++) e **copie todo o conteúdo XML** de dentro dele.


2. **Configurar o Secret no Repositório do GitHub:**
* Abra o seu repositório no GitHub.
* Clique no separador **Settings** (Definições) no menu superior do repositório.
* Na barra lateral esquerda, expanda **Secrets and variables** e clique em **Actions**.
* Clique no botão verde **New repository secret**.
* No campo **Name**, digite exatamente: `AZURE_WEBAPP_PUBLISH_PROFILE`.
* No campo **Value**, cole todo o conteúdo XML do ficheiro `.publishsettings` que copiou no passo anterior.
* Clique em **Add secret** para guardar.


3. **Estrutura do Workflow (.github/workflows/deploy.yml):**
Certifique-se de que o ficheiro de pipeline configurado no seu repositório (`.github/workflows/deploy.yml`) possui uma estrutura compatível com o .NET 8 e o Web App do Azure, realizando o restore, build, publish e o deploy utilizando o secret criado:
```yaml
name: Build and Deploy .NET App to Azure App Service

on:
  push:
    branches: [ "main" ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Set up .NET Core
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.0.x'

    - name: Build with dotnet
      run: dotnet build ApiSpaceMission/ApiSpaceMission.csproj --configuration Release

    - name: dotnet publish
      run: dotnet publish ApiSpaceMission/ApiSpaceMission.csproj -c Release -o ${{env.DOTNET_ROOT}}/myapp

    - name: Run Azure WebApp Deploy
      uses: azure/webapps-deploy@v3
      with:
        app-name: 'app-space-v2-rm565206'
        publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
        package: '${{env.DOTNET_ROOT}}/myapp'

```



---

### Passo 6: Disparar o Deploy Automático e Validar

1. Envie todas as alterações recentes e o ficheiro de pipeline para o repositório remoto executando os comandos no seu terminal:
```bash
git add .
git commit -m "feat: configura pipeline de CI/CD e ajustes finais de deploy"
git push origin main

```


2. Acompanhe a esteira de integração contínua acedendo ao separador **Actions** no seu repositório do GitHub até que o processo termine com sucesso (indicado a verde).
3. Assim que o deploy for concluído, aceda publicamente à API no navegador através do link:
🔗 [https://app-space-v2-rm565206.azurewebsites.net/](https://www.google.com/search?q=https://app-space-v2-rm565206.azurewebsites.net/)

🎉 **Pronto!** A sua infraestrutura foi totalmente provisionada por scripts, integrada com sucesso via pipeline de CI/CD do GitHub Actions e encontra-se a executar na nuvem com alta disponibilidade.

```

```
