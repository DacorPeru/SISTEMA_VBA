USE BD_SISGIPAT;
GO
IF OBJECT_ID('dbo.empresas','U') IS NULL
BEGIN
  CREATE TABLE dbo.empresas(
    id_empresa       BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_empresa   VARCHAR(6)  NOT NULL UNIQUE,
    ruc              VARCHAR(11) NOT NULL UNIQUE CHECK (LEN(ruc)=11),
    razon_social     NVARCHAR(200) NOT NULL,
    nombre_comercial NVARCHAR(150) NULL,
    tipo_empresa     VARCHAR(20)   NULL CHECK (tipo_empresa IN('Privada','Publica')),
    db_server        NVARCHAR(128) NOT NULL,
    db_name          NVARCHAR(128) NOT NULL,
    conn_encrypted   VARBINARY(MAX) NULL,
    activo           BIT NOT NULL DEFAULT(1),
    creado_en        DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    actualizado_en   DATETIME2(0) NULL,
    rowver           ROWVERSION
  );
  CREATE INDEX IX_empresas_ruc    ON dbo.empresas(ruc);
  CREATE INDEX IX_empresas_codigo ON dbo.empresas(codigo_empresa);
END
GO
