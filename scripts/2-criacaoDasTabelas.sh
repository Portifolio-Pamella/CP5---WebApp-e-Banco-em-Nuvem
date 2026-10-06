Invoke-Sqlcmd -ServerInstance "sql-server-space-rm565206-canadacentral.database.windows.net" `
              -Database "db-spacemission" `
              -Username "admin-space" `
              -Password "Fiap@2tdsvms" `
              -Query @"
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Missoes' AND xtype='U')
BEGIN
  CREATE TABLE Missoes (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(MAX) NOT NULL,
    Destino NVARCHAR(MAX) NOT NULL
  );
END;

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Astronautas' AND xtype='U')
BEGIN
  CREATE TABLE Astronautas (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(MAX) NOT NULL,
    Especialidade NVARCHAR(MAX) NOT NULL,
    MissaoId INT NOT NULL,
    CONSTRAINT FK_Astronautas_Missoes_MissaoId FOREIGN KEY (MissaoId) REFERENCES Missoes(Id) ON DELETE CASCADE
  );
END;

-- Inserindo missões de teste se a tabela estiver vazia
IF NOT EXISTS (SELECT * FROM Missoes)
BEGIN
  INSERT INTO Missoes (Nome, Destino) VALUES
  ('Apollo 11', 'Lua'),
  ('Artemis II', 'Órbita Lunar'),
  ('Mars 2020', 'Marte');
END;

-- Inserindo astronautas de teste se a tabela estiver vazia
IF NOT EXISTS (SELECT * FROM Astronautas)
BEGIN
  INSERT INTO Astronautas (Nome, Especialidade, MissaoId) VALUES
  ('Neil Armstrong', 'Comandante', 1),
  ('Buzz Aldrin', 'Piloto do Módulo Lunar', 1),
  ('Victor Glover', 'Piloto', 2);
END;
"@