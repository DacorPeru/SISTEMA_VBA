USE SISGIPAT;
GO

/* =========================================================
   EMPRESAS (multiempresa) — documento principal obligatorio
   - SIN columna RUC
   - Documento principal = (tipo_doc_id, nro_doc) -> RUC (PJ) o DNI/CE/PAS (PN)
   - Clasificación pública/privada y naturaleza PJ/PN
   ========================================================= */

IF OBJECT_ID('dbo.emp','U') IS NULL
BEGIN
    CREATE TABLE dbo.emp(
        emp_id         INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_emp PRIMARY KEY,

        -- Identidad de la empresa en la app
        codigo         NVARCHAR(50)  NOT NULL,               -- código interno único
        nombre         NVARCHAR(200) NOT NULL,                -- razón social / nombre comercial

        -- Documento principal (OBLIGATORIO)
        tipo_doc_id    SMALLINT      NOT NULL,               -- FK a cat_tipo_doc (RUC, DNI, CE, PAS, OTR)
        nro_doc        NVARCHAR(20)  NOT NULL,               -- doc principal: RUC(11) o DNI(8), etc.

        -- Clasificación y ciclo de vida
        tipo_entidad   VARCHAR(10)   NOT NULL CONSTRAINT DF_emp_tipoent DEFAULT('PRIVADA'), -- PUBLICA|PRIVADA
        naturaleza     VARCHAR(5)    NOT NULL CONSTRAINT DF_emp_nat     DEFAULT('PJ'),      -- PJ|PN
        entorno        VARCHAR(10)   NOT NULL CONSTRAINT DF_emp_entorno DEFAULT('DEMO'),    -- DEMO|PROD
        estado         VARCHAR(20)   NOT NULL CONSTRAINT DF_emp_estado  DEFAULT('ACTIVO'),  -- ACTIVO|INACTIVO
        bloqueado      BIT           NOT NULL CONSTRAINT DF_emp_bloqueado DEFAULT(0),
        baja           BIT           NOT NULL CONSTRAINT DF_emp_baja      DEFAULT(0),

        -- Contacto (opcionales, por control profesional)
        email_contacto NVARCHAR(320) NULL,
        celular        NVARCHAR(20)  NULL,

        -- Conexión (tenancy)
        servidor       NVARCHAR(200) NOT NULL,
        base_datos     SYSNAME       NOT NULL,
        usuario        SYSNAME       NULL,
        [password]     NVARCHAR(256) NULL,
        trusted        BIT           NOT NULL CONSTRAINT DF_emp_trusted DEFAULT(1),
        [timeout]      INT           NOT NULL CONSTRAINT DF_emp_timeout DEFAULT(30),

        -- Trazabilidad
        f_cre          DATETIME2(7)  NOT NULL CONSTRAINT DF_emp_fcre DEFAULT(SYSDATETIME()),
        f_mod          DATETIME2(7)  NULL
    );
END
GO

/* FK al catálogo (idempotente) */
IF OBJECT_ID('dbo.cat_tipo_doc','U') IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name='FK_emp_tipo_doc' AND parent_object_id=OBJECT_ID('dbo.emp')
)
BEGIN
    ALTER TABLE dbo.emp
      ADD CONSTRAINT FK_emp_tipo_doc
      FOREIGN KEY (tipo_doc_id)
      REFERENCES dbo.cat_tipo_doc(tipo_doc_id);
END
GO

/* CHECKs de dominio (idempotentes) */
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_emp_entorno')
    ALTER TABLE dbo.emp ADD CONSTRAINT CK_emp_entorno CHECK (entorno IN ('DEMO','PROD'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_emp_estado')
    ALTER TABLE dbo.emp ADD CONSTRAINT CK_emp_estado CHECK (estado IN ('ACTIVO','INACTIVO'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_emp_tipo_entidad')
    ALTER TABLE dbo.emp ADD CONSTRAINT CK_emp_tipo_entidad CHECK (tipo_entidad IN ('PUBLICA','PRIVADA'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_emp_naturaleza')
    ALTER TABLE dbo.emp ADD CONSTRAINT CK_emp_naturaleza CHECK (naturaleza IN ('PJ','PN'));
GO

/* Índices y unicidad clave (idempotentes) */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_emp_codigo' AND object_id=OBJECT_ID('dbo.emp'))
    CREATE UNIQUE INDEX UX_emp_codigo ON dbo.emp(codigo);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_emp_base_datos' AND object_id=OBJECT_ID('dbo.emp'))
    CREATE UNIQUE INDEX UX_emp_base_datos ON dbo.emp(base_datos);
GO
-- Documento principal único a nivel global (impide dos empresas con mismo RUC/DNI)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_emp_doc_principal' AND object_id=OBJECT_ID('dbo.emp'))
    CREATE UNIQUE INDEX UX_emp_doc_principal ON dbo.emp(tipo_doc_id, nro_doc);
GO
