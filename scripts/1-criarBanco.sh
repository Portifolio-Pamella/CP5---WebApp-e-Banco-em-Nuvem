# 1) Grupo de Recursos
echo "Criando Grupo de Recursos..."
az group create --name rg-sql-spacemission --location canadacentral

az provider register --namespace Microsoft.Sql

# 2) Servidor Primário
echo "Criando Servidor SQL Primario..."
az sql server create \
  --name sql-server-space-rm565206-canadacentral-v2 \
  --resource-group rg-sql-spacemission \
  --location canadacentral \
  --admin-user user-space \
  --admin-password 'Fiap@2tdsvms' \
  --enable-public-network true

# 3) Pausa para o servidor primário estabilizar
echo "Aguardando 60 segundos para o servidor primario ficar pronto..."
sleep 60

# 4) Banco de Dados no Servidor Primário
echo "Criando Banco de Dados..."
az sql db create \
  --resource-group rg-sql-spacemission \
  --server sql-server-space-rm565206-canadacentral-v2 \
  --name db-spacemission \
  --service-objective Basic \
  --backup-storage-redundancy Local \
  --zone-redundant false

# 5) Liberar acesso no Firewall
echo "Liberando Firewall..."
az sql server firewall-rule create \
  --resource-group rg-sql-spacemission \
  --server sql-server-space-rm565206-canadacentral-v2 \
  --name liberaGeral \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255

# 6) Servidor Secundário
echo "Criando Servidor Secundario..."
az sql server create \
  --name sql-server-space-rm565206-secundario-v2 \
  --resource-group rg-sql-spacemission \
  --location canadacentral \
  --admin-user user-space \
  --admin-password 'Fiap@2tdsvms' \
  --enable-public-network true

# 7) Pausa para o servidor secundário estabilizar
echo "Aguardando 60 segundos para o servidor secundario ficar pronto..."
sleep 60

# 8) Criação da Réplica do Banco de Dados
echo "Criando Replica do Banco..."
az sql db replica create \
  --name db-spacemission \
  --resource-group rg-sql-spacemission \
  --server sql-server-space-rm565206-canadacentral-v2 \
  --partner-server sql-server-space-rm565206-secundario-v2 \
  --partner-resource-group rg-sql-spacemission \
  --backup-storage-redundancy Local \
  --zone-redundant false

# 9) Política de Retenção de Backup (LTR)
echo "Configurando Politica LTR..."
az sql db ltr-policy set \
  --resource-group rg-sql-spacemission \
  --server sql-server-space-rm565206-canadacentral-v2 \
  --name db-spacemission \
  --weekly-retention P30D \
  --monthly-retention P365D \
  --yearly-retention P1825D \
  --week-of-year 1

# 10) Grupo de Failover
echo "Criando Failover Group..."
az sql failover-group create \
  --name failover-group-space-rm565206-v2 \
  --resource-group rg-sql-spacemission \
  --server sql-server-space-rm565206-canadacentral-v2 \
  --partner-server sql-server-space-rm565206-secundario-v2 \
  --partner-resource-group rg-sql-spacemission \
  --failover-policy Automatic \
  --grace-period 60

az sql failover-group update \
  --name failover-group-space-rm565206-v2 \
  --resource-group rg-sql-spacemission \
  --server sql-server-space-rm565206-canadacentral-v2 \
  --add-db db-spacemission

echo "Processo concluido com sucesso!"