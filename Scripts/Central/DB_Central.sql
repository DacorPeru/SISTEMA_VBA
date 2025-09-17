/* ============================================================
   SISGIPAT - ESQUEMA CENTRAL MÍNIMO (solo BD + tablas)
   ============================================================ */

-- 1) Crear BD central si no existe
IF DB_ID(N'BD_SISGIPAT') IS NULL
    CREATE DATABASE BD_SISGIPAT;
GO
USE BD_SISGIPAT;
GO

-- 2) Tabla: SUPERADMINS (solo en BD central)
IF OBJECT_ID('dbo.superadmins','U') IS NULL
BEGIN
  CREATE TABLE dbo.superadmins(
    id_superadmin     BIGINT IDENTITY(1,1) PRIMARY KEY,
    dni               VARCHAR(8)     NOT NULL,
    apellido_paterno  NVARCHAR(100)  NOT NULL,
    apellido_materno  NVARCHAR(100)  NOT NULL,
    nombres           NVARCHAR(100)  NOT NULL,
    correo            NVARCHAR(150)  NOT NULL,

    -- si aún no usarás hash/salt desde SQL, puedes dejar estos NULL
    contrasena_hash   VARBINARY(64)  NULL,
    salt              VARBINARY(16)  NULL,

    activo            BIT            NOT NULL DEFAULT (1),
    ultimo_acceso     DATETIME2(0)   NULL,
    creado_en         DATETIME2(0)   NOT NULL DEFAULT (SYSDATETIME()),
    actualizado_en    DATETIME2(0)   NULL,
    rowver            ROWVERSION,

    CONSTRAINT UQ_superadmins_correo UNIQUE (correo),
    CONSTRAINT UQ_superadmins_dni    UNIQUE (dni),
    CONSTRAINT CK_superadmins_dni CHECK (LEN(dni)=8 AND dni NOT LIKE '%[^0-9]%')
  );
END
GO

-- 3) Tabla: EMPRESAS (directorio de BDs por empresa)
IF OBJECT_ID('dbo.empresas','U') IS NULL
BEGIN
  CREATE TABLE dbo.empresas(
    id_empresa       BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_empresa   VARCHAR(6)  NOT NULL CONSTRAINT UQ_empresas_codigo UNIQUE,
    ruc              VARCHAR(11) NOT NULL CONSTRAINT UQ_empresas_ruc UNIQUE,
    razon_social     NVARCHAR(200) NOT NULL,
    nombre_comercial NVARCHAR(150) NULL,
    tipo_empresa     VARCHAR(20)   NULL,       -- 'Privada'/'Publica' (valídalo en tu app)
    db_server        NVARCHAR(128) NOT NULL,   -- instancia SQL donde vive la BD de la empresa
    db_name          NVARCHAR(128) NOT NULL,   -- nombre de la BD de la empresa
    activo           BIT NOT NULL DEFAULT (1),
    creado_en        DATETIME2(0) NOT NULL DEFAULT (SYSDATETIME()),
    actualizado_en   DATETIME2(0) NULL,
    rowver           ROWVERSION
  );
END
GO
