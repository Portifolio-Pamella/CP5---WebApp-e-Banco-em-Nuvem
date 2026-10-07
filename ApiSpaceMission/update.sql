IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
CREATE TABLE [Missoes] (
    [Id] int NOT NULL IDENTITY,
    [Nome] nvarchar(max) NOT NULL,
    [Destino] nvarchar(max) NOT NULL,
    CONSTRAINT [PK_Missoes] PRIMARY KEY ([Id])
);

CREATE TABLE [Astronautas] (
    [Id] int NOT NULL IDENTITY,
    [Nome] nvarchar(max) NOT NULL,
    [Especialidade] nvarchar(max) NOT NULL,
    [MissaoId] int NOT NULL,
    CONSTRAINT [PK_Astronautas] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Astronautas_Missoes_MissaoId] FOREIGN KEY ([MissaoId]) REFERENCES [Missoes] ([Id]) ON DELETE CASCADE
);

CREATE INDEX [IX_Astronautas_MissaoId] ON [Astronautas] ([MissaoId]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20261007035213_AdicionaTabelasFinais', N'10.0.12');

COMMIT;
GO

