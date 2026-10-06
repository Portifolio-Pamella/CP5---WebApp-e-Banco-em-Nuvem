# 1. Criação do Grupo de Recursos
az group create --name rg-sql-spacemission --location canadacentral

# 2. Registro do Provedor SQL (caso ainda não esteja registrado)
az provider register --namespace Microsoft.Sql

# 3. Criação do Servidor Primário
az sql server create \
  --name sql-server-space-rm565206-canadacentral \
  --resource-group rg-sql-spacemission \
  --location canadacentral \
  --admin-user admin-space \
  --admin-password 'Fiap@2tdsvms' \
  --enable-public-network true

# 4. Criação do Banco de Dados no Servidor Primário
az sql db create \
  --resource-group rg-sql-spacemission \
  --server sql-server-space-rm565206-canadacentral \
  --name db-spacemission \
  --service-objective Basic \
  --backup-storage-redundancy Local \
  --zone-redundant false

# 5. Liberação do Firewall (Permitir acesso público para desenvolvimento)
az sql server firewall-rule create \
  --resource-group rg-sql-spacemission \
  --server sql-server-space-rm565206-canadacentral \
  --name liberaGeral \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255

# 6. Criação do Servidor Secundário (Parceiro)
az sql server create \
  --name sql-server-space-rm565206-canadaeast \
  --resource-group rg-sql-spacemission \
  --location canadaeast \
  --admin-user admin-space \
  --admin-password 'Fiap@2tdsvms' \
  --enable-public-network true

# 7. Criação da Réplica do Banco de Dados no Servidor Secundário
az sql db replica create \
  --name db-spacemission \
  --resource-group rg-sql-spacemission \
  --server sql-server-space-rm565206-canadacentral \
  --partner-server sql-server-space-rm565206-canadaeast \
  --partner-resource-group rg-sql-spacemission \
  --backup-storage-redundancy Local \
  --zone-redundant false

# 8. Configuração da Política de Retenção de Backup (Long Term Retention)
az sql db ltr-policy set \
  --resource-group rg-sql-spacemission \
  --server sql-server-space-rm565206-canadacentral \
  --name db-spacemission \
  --weekly-retention P30D \
  --monthly-retention P365D \
  --yearly-retention P1825D \
  --week-of-year 1

# 9. Criação do Grupo de Failover
az sql failover-group create \
  --name failover-group-space-rm565206 \
  --resource-group rg-sql-spacemission \
  --server sql-server-space-rm565206-canadacentral \
  --partner-server sql-server-space-rm565206-canadaeast \
  --partner-resource-group rg-sql-spacemission \
  --failover-policy Automatic \
  --grace-period 1

# Adicionar o banco de dados ao Grupo de Failover
az sql failover-group update \
  --name failover-group-space-rm565206 \
  --resource-group rg-sql-spacemission \
  --server sql-server-space-rm565206-canadacentral \
  --add-db db-spacemission