USE SISGIPAT;
GO

IF OBJECT_ID('dbo.cen_usr','U') IS NULL
BEGIN
  CREATE TABLE dbo.cen_usr(
    usr_id          INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_cen_usr PRIMARY KEY,
    email           NVARCHAR(320) NOT NULL,
    tipo_doc_id     SMALLINT      NULL,
    nro_doc         NVARCHAR(20)  NULL,
    nombres         NVARCHAR(100) NULL,
    ape_paterno     NVARCHAR(100) NULL,
    ape_materno     NVARCHAR(100) NULL,
    est             VARCHAR(20)   NOT NULL CONSTRAINT DF_cen_usr_est DEFAULT('ACTIVO'),
    salt            VARBINARY(16) NOT NULL,
    [hash]          VARBINARY(32) NOT NULL,
    [iter]          INT           NOT NULL,
    must_change_pwd BIT           NOT NULL CONSTRAINT DF_cen_usr_mcp DEFAULT(1),
    kdf_alg         VARCHAR(32)   NOT NULL CONSTRAINT DF_cen_usr_kdf DEFAULT('TSQL_STRETCH'),
    f_cre           DATETIME2(7)  NOT NULL CONSTRAINT DF_cen_usr_fcre DEFAULT(SYSDATETIME())
  );
END
GO

IF OBJECT_ID('dbo.cat_tipo_doc','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_cen_usr_tipo_doc' AND parent_object_id=OBJECT_ID('dbo.cen_usr'))
BEGIN
  ALTER TABLE dbo.cen_usr
    ADD CONSTRAINT FK_cen_usr_tipo_doc FOREIGN KEY(tipo_doc_id) REFERENCES dbo.cat_tipo_doc(tipo_doc_id);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UQ_cen_usr_email' AND object_id=OBJECT_ID('dbo.cen_usr'))
  CREATE UNIQUE INDEX UQ_cen_usr_email ON dbo.cen_usr(email);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UQ_cen_usr_doc' AND object_id=OBJECT_ID('dbo.cen_usr'))
  CREATE UNIQUE INDEX UQ_cen_usr_doc ON dbo.cen_usr(tipo_doc_id, nro_doc) WHERE tipo_doc_id IS NOT NULL AND nro_doc IS NOT NULL;
GO

-- KDF permitido (solo el fallback TSQL)
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_cen_usr_kdf')
  ALTER TABLE dbo.cen_usr DROP CONSTRAINT CK_cen_usr_kdf;
GO
ALTER TABLE dbo.cen_usr
  ADD CONSTRAINT CK_cen_usr_kdf CHECK (kdf_alg='TSQL_STRETCH');
GO
