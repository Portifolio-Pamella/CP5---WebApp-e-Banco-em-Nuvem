# Definindo variáveis para facilitar
RG="rg-sql-spacemission"
LOCATION="canadacentral"
PLAN="plan-space-rm565206"
APP="app-space-rm565206" # Este nome será a URL da sua API (app-space-rm565206.azurewebsites.net)

# 1. Criar o Plano de Serviço (App Service Plan) usando a camada Gratuita (F1) para Linux
az appservice plan create \
  --name $PLAN \
  --resource-group $RG \
  --sku F1 \
  --is-linux \
  --location $LOCATION

# 2. Criar o Web App (Onde a API vai rodar) com .NET 8
az webapp create \
  --name $APP \
  --plan $PLAN \
  --resource-group $RG \
  --runtime "DOTNETCORE|8.0"

# 3. Baixar o "Publish Profile" (Perfil de Publicação)
# Esse comando vai gerar um arquivo XML no seu terminal com as credenciais de deploy.
az webapp deployment list-publishing-profiles \
  --name $APP \
  --resource-group $RG \
  --xml > publish_profile.xml

# 4. Exibir o conteúdo do XML na tela para você copiar no próximo passo
cat publish_profile.xml