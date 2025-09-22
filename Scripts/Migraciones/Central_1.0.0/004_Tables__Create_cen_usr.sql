-- Trabajamos dentro de la BD central
USE SISGIPAT;
GO

/* ============================================================
   004_Tables__Create_cen_usr.sql  (producción e idempotente)
   - Crea la tabla de usuarios centrales.
   - Incluye banderas de seguridad: must_change_pwd, kdf_alg.
   - Si la tabla ya existía, las agrega vía evolución (ALTER).
   ============================================================ */

-- 1) Crear tabla si no existe
IF OBJECT_ID('dbo.cen_usr','U') IS NULL
BEGIN
    CREATE TABLE dbo.cen_usr(
        -- Clave surrogate eficiente para relaciones
        usr_id       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_cen_usr PRIMARY KEY,

        -- Identificación principal del usuario (login)
        email        NVARCHAR(320) NOT NULL,

        -- Documento (referencia al catálogo y su número)
        tipo_doc_id  SMALLINT      NULL,   -- FK a dbo.cat_tipo_doc
        nro_doc      NVARCHAR(20)  NULL,   -- Permite ceros a la izquierda, distintos formatos

        -- Datos personales (Unicode)
        nombres      NVARCHAR(100) NULL,
        ape_paterno  NVARCHAR(100) NULL,
        ape_materno  NVARCHAR(100) NULL,

        -- Estado funcional con default
        est          VARCHAR(20)   NOT NULL CONSTRAINT DF_cen_usr_est DEFAULT('ACTIVO'),

        -- Seguridad (derivación de clave + sal)
        salt         VARBINARY(16) NOT NULL,
        [hash]       VARBINARY(32) NOT NULL,
        [iter]       INT           NOT NULL,

        -- 🔐 Banderas de seguridad (flujo de contraseñas/migración KDF)
        must_change_pwd BIT         NOT NULL CONSTRAINT DF_cen_usr_mcp DEFAULT(1),

        -- Trazabilidad (alta precisión)
        f_cre        DATETIME2(7)  NOT NULL CONSTRAINT DF_cen_usr_fcre DEFAULT(SYSDATETIME())
    );
END
GO

-- 1.b) EVOLUCIÓN: si la tabla ya existía, agrega las banderas (idempotente)
IF COL_LENGTH('dbo.cen_usr','must_change_pwd') IS NULL
  ALTER TABLE dbo.cen_usr
    ADD must_change_pwd BIT NOT NULL
        CONSTRAINT DF_cen_usr_mcp DEFAULT(1) WITH VALUES;
GO

/* 2) FK idempotente al catálogo de tipos de documento
      - Se crea solo si el catálogo existe y la FK no está ya definida */
IF OBJECT_ID('dbo.cat_tipo_doc','U') IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name='FK_cen_usr_tipo_doc'
      AND parent_object_id = OBJECT_ID('dbo.cen_usr')
)
BEGIN
    ALTER TABLE dbo.cen_usr
      ADD CONSTRAINT FK_cen_usr_tipo_doc
      FOREIGN KEY (tipo_doc_id)
      REFERENCES dbo.cat_tipo_doc(tipo_doc_id);
END
GO

/* 3) Índices y unicidad */

-- Unicidad por email (evita duplicados y acelera autenticación/búsquedas)
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name='UQ_cen_usr_email'
      AND object_id=OBJECT_ID('dbo.cen_usr')
)
    CREATE UNIQUE INDEX UQ_cen_usr_email ON dbo.cen_usr(email);
GO

-- Unicidad por combinación (tipo_doc_id, nro_doc) únicamente cuando ambos existen
-- (Índice filtrado: permite múltiples NULL sin romper unicidad)
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name='UQ_cen_usr_doc'
      AND object_id=OBJECT_ID('dbo.cen_usr')
)
    CREATE UNIQUE INDEX UQ_cen_usr_doc
    ON dbo.cen_usr(tipo_doc_id, nro_doc)
    WHERE tipo_doc_id IS NOT NULL AND nro_doc IS NOT NULL;
GO
