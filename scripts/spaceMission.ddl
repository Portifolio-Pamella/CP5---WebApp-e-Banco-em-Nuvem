-- Criação da tabela Missoes
CREATE TABLE Missoes (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(MAX) NOT NULL,
    Destino NVARCHAR(MAX) NOT NULL
);

-- Criação da tabela Astronautas com relacionamento 1 para N (FK para Missoes)
CREATE TABLE Astronautas (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(MAX) NOT NULL,
    Especialidade NVARCHAR(MAX) NOT NULL,
    MissaoId INT NOT NULL,
    CONSTRAINT FK_Astronautas_Missoes_MissaoId 
        FOREIGN KEY (MissaoId) 
        REFERENCES Missoes(Id) 
        ON DELETE CASCADE
);