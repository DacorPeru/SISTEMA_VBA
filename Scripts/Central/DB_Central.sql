/* ============================================================
   SISGIPAT - ESQUEMA CENTRAL + SEGURIDAD (Windows/SQL Login)
   ============================================================ */

-- 1) Crear BD central si no existe
IF DB_ID(N'BD_SISGIPAT') IS NULL
    CREATE DATABASE BD_SISGIPAT;
GO
USE BD_SISGIPAT;
GO

/* 2) Tabla: SUPERADMINS */
IF OBJECT_ID('dbo.superadmins','U') IS NULL
BEGIN
  CREATE TABLE dbo.superadmins(
    id_superadmin     BIGINT IDENTITY(1,1) PRIMARY KEY,
    dni               VARCHAR(8)     NOT NULL,
    apellido_paterno  NVARCHAR(100)  NOT NULL,
    apellido_materno  NVARCHAR(100)  NOT NULL,
    nombres           NVARCHAR(100)  NOT NULL,
    correo            NVARCHAR(150)  NOT NULL,
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

/* 3) Tabla: EMPRESAS (directorio de BDs por empresa) */
IF OBJECT_ID('dbo.empresas','U') IS NULL
BEGIN
  CREATE TABLE dbo.empresas(
    id_empresa       BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_empresa   VARCHAR(6)  NOT NULL CONSTRAINT UQ_empresas_codigo UNIQUE,
    ruc              VARCHAR(11) NOT NULL CONSTRAINT UQ_empresas_ruc UNIQUE,
    razon_social     NVARCHAR(200) NOT NULL,
    nombre_comercial NVARCHAR(150) NULL,
    tipo_empresa     VARCHAR(20)   NULL,
    db_server        NVARCHAR(128) NOT NULL,
    db_name          NVARCHAR(128) NOT NULL,
    activo           BIT NOT NULL DEFAULT (1),
    creado_en        DATETIME2(0) NOT NULL DEFAULT (SYSDATETIME()),
    actualizado_en   DATETIME2(0) NULL,
    rowver           ROWVERSION
  );
END
GO

/* ============================================================
   4) BOOTSTRAP DE SEGURIDAD (elige A y/o B)
   ============================================================ */

-- === A) WINDOWS LOGIN: usa tu usuario de Windows para Excel ===
-- Cambia el nombre si tu usuario es diferente
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'GESMER-R\GESMER REYES')
    CREATE LOGIN [GESMER-R\GESMER REYES] FROM WINDOWS;
ALTER LOGIN [GESMER-R\GESMER REYES] WITH DEFAULT_DATABASE = [BD_SISGIPAT];

USE [BD_SISGIPAT];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'GESMER-R\GESMER REYES')
    CREATE USER [GESMER-R\GESMER REYES] FOR LOGIN [GESMER-R\GESMER REYES];

EXEC sp_addrolemember N'db_datareader', N'GESMER-R\GESMER REYES';
EXEC sp_addrolemember N'db_datawriter', N'GESMER-R\GESMER REYES';
GRANT EXECUTE TO [GESMER-R\GESMER REYES];
GO

-- === B) SQL LOGIN: usuario/clave para la app (opcional) ===
-- Asegúrate de que el servidor esté en modo mixto si usarás esto.
IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = N'app_user')
    CREATE LOGIN [app_user] WITH PASSWORD = 'TuClaveFuerte#2025', CHECK_POLICY = ON;
ALTER LOGIN [app_user] WITH DEFAULT_DATABASE = [BD_SISGIPAT];

USE [BD_SISGIPAT];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'app_user')
    CREATE USER [app_user] FOR LOGIN [app_user];

EXEC sp_addrolemember N'db_datareader', N'app_user';
EXEC sp_addrolemember N'db_datawriter', N'app_user';
GRANT EXECUTE TO [app_user];
GO

-- (Opcional) Rol de aplicación y asignaciones
USE [BD_SISGIPAT];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'app_role')
    CREATE ROLE [app_role];

GRANT SELECT, INSERT, UPDATE, DELETE TO [app_role];
GRANT EXECUTE ON SCHEMA::dbo TO [app_role];

EXEC sp_addrolemember N'app_role', N'GESMER-R\GESMER REYES';
-- EXEC sp_addrolemember N'app_role', N'app_user';
GO
