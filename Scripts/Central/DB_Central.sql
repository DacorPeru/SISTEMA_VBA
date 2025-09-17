/* =====================================================================
   SISGIPAT - Script Único (CENTRAL)
   Crea la BD central y los objetos mínimos para iniciar y escalar.
   Objetos:
     - BD: BD_SISGIPAT
     - Tablas: dbo.superadmins, dbo.empresas
     - SP (WITH ENCRYPTION): login/creación SA, mantenimiento de empresas
   Requisitos: SQL Server 2012+ (HASHBYTES SHA2_256, CRYPT_GEN_RANDOM)
   ===================================================================== */

IF DB_ID(N'BD_SISGIPAT') IS NULL
    CREATE DATABASE BD_SISGIPAT;
GO
USE BD_SISGIPAT;
GO

/* =========================================================
   TABLA: dbo.superadmins  (solo en BD central)
   ========================================================= */
IF OBJECT_ID('dbo.superadmins','U') IS NULL
BEGIN
  CREATE TABLE dbo.superadmins(
    id_superadmin     BIGINT IDENTITY(1,1) NOT NULL
      CONSTRAINT PK_superadmins PRIMARY KEY,

    -- Identificación personal
    dni               VARCHAR(8)    NOT NULL,
    apellido_paterno  NVARCHAR(100) NOT NULL,
    apellido_materno  NVARCHAR(100) NOT NULL,
    nombres           NVARCHAR(100) NOT NULL,

    -- Acceso
    correo            NVARCHAR(150) NOT NULL,
    contrasena_hash   VARBINARY(64) NOT NULL,
    salt              VARBINARY(16)     NULL,
    hash_algoritmo    VARCHAR(16)       NULL,  -- p.ej. 'SHA2_256'

    -- Estado y trazabilidad
    activo            BIT            NOT NULL
      CONSTRAINT DF_superadmins_activo DEFAULT (1),
    ultimo_acceso     DATETIME2(0)       NULL,
    creado_en         DATETIME2(0)   NOT NULL
      CONSTRAINT DF_superadmins_creado DEFAULT (SYSDATETIME()),
    actualizado_en    DATETIME2(0)       NULL,

    rowver            ROWVERSION,

    -- Reglas mínimas
    CONSTRAINT UQ_superadmins_correo UNIQUE (correo),
    CONSTRAINT UQ_superadmins_dni    UNIQUE (dni),
    CONSTRAINT CK_superadmins_dni CHECK (LEN(dni)=8 AND dni NOT LIKE '%[^0-9]%')
  );
END
GO

/* =========================================================
   TABLA: dbo.empresas  (directorio de empresas)
   ========================================================= */
IF OBJECT_ID('dbo.empresas','U') IS NULL
BEGIN
  CREATE TABLE dbo.empresas(
    id_empresa       BIGINT IDENTITY(1,1) NOT NULL
      CONSTRAINT PK_empresas PRIMARY KEY,

    codigo_empresa   VARCHAR(6)  NOT NULL
      CONSTRAINT UQ_empresas_codigo UNIQUE,    -- ej: EMP001
    ruc              VARCHAR(11) NOT NULL
      CONSTRAINT UQ_empresas_ruc UNIQUE,       -- 11 dígitos

    razon_social     NVARCHAR(200) NOT NULL,
    nombre_comercial NVARCHAR(150) NULL,
    tipo_empresa     VARCHAR(20)   NULL,       -- 'Privada'/'Publica' (validación en app)

    db_server        NVARCHAR(128) NOT NULL,   -- instancia SQL donde vive la BD de la empresa
    db_name          NVARCHAR(128) NOT NULL,   -- nombre de la BD de la empresa

    conn_encrypted   VARBINARY(MAX) NULL,      -- (opcional) secreto/CS cifrado por la app

    activo           BIT NOT NULL
      CONSTRAINT DF_empresas_activo DEFAULT (1),

    creado_en        DATETIME2(0) NOT NULL
      CONSTRAINT DF_empresas_creado DEFAULT (SYSDATETIME()),
    actualizado_en   DATETIME2(0) NULL,

    rowver           ROWVERSION
  );
END
GO

/* =========================================================
   SP: Crear Superadmin
   ========================================================= */
IF OBJECT_ID('dbo.sp_superadmin_crear','P') IS NOT NULL
  DROP PROCEDURE dbo.sp_superadmin_crear;
GO
CREATE PROCEDURE dbo.sp_superadmin_crear
  @dni      VARCHAR(8),
  @apepat   NVARCHAR(100),
  @apemat   NVARCHAR(100),
  @nombres  NVARCHAR(100),
  @correo   NVARCHAR(150),
  @pwd      NVARCHAR(200),
  @activo   BIT = 1
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;

  IF EXISTS(SELECT 1 FROM dbo.superadmins WHERE correo=@correo)
    RAISERROR(N'El correo ya está registrado.',16,1);

  IF EXISTS(SELECT 1 FROM dbo.superadmins WHERE dni=@dni)
    RAISERROR(N'El DNI ya está registrado.',16,1);

  DECLARE @salt VARBINARY(16)=CRYPT_GEN_RANDOM(16);
  DECLARE @hash VARBINARY(64)=HASHBYTES('SHA2_256', @salt + CONVERT(VARBINARY(4000),@pwd));

  INSERT INTO dbo.superadmins(dni,apellido_paterno,apellido_materno,nombres,correo,
                              contrasena_hash,salt,hash_algoritmo,activo)
  VALUES(@dni,@apepat,@apemat,@nombres,@correo,@hash,@salt,'SHA2_256',@activo);
END
GO

/* =========================================================
   SP: Cambiar clave Superadmin
   ========================================================= */
IF OBJECT_ID('dbo.sp_superadmin_cambiar_clave','P') IS NOT NULL
  DROP PROCEDURE dbo.sp_superadmin_cambiar_clave;
GO
CREATE PROCEDURE dbo.sp_superadmin_cambiar_clave
  @id_superadmin BIGINT,
  @pwd_nueva     NVARCHAR(200)
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS(SELECT 1 FROM dbo.superadmins WHERE id_superadmin=@id_superadmin AND activo=1)
    RAISERROR(N'Superadmin no existe o está inactivo.',16,1);

  DECLARE @salt VARBINARY(16)=CRYPT_GEN_RANDOM(16);
  DECLARE @hash VARBINARY(64)=HASHBYTES('SHA2_256', @salt + CONVERT(VARBINARY(4000),@pwd_nueva));

  UPDATE dbo.superadmins
     SET contrasena_hash=@hash,
         salt=@salt,
         hash_algoritmo='SHA2_256',
         actualizado_en=SYSDATETIME()
   WHERE id_superadmin=@id_superadmin;
END
GO

/* =========================================================
   SP: Login Superadmin  (devuelve -1/-2 en error, o fila con id/nombres)
   ========================================================= */
IF OBJECT_ID('dbo.sp_superadmin_login','P') IS NOT NULL
  DROP PROCEDURE dbo.sp_superadmin_login;
GO
CREATE PROCEDURE dbo.sp_superadmin_login
  @correo NVARCHAR(150),
  @pwd    NVARCHAR(200)
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @id BIGINT,@salt VARBINARY(16),@hash VARBINARY(64);

  SELECT @id=id_superadmin, @salt=salt, @hash=contrasena_hash
  FROM dbo.superadmins
  WHERE correo=@correo AND activo=1;

  IF @id IS NULL RETURN -1;  -- usuario no existe / inactivo

  DECLARE @calc VARBINARY(64)=HASHBYTES('SHA2_256', ISNULL(@salt,0x00)+CONVERT(VARBINARY(4000),@pwd));
  IF @calc<>@hash RETURN -2; -- clave inválida

  UPDATE dbo.superadmins SET ultimo_acceso=SYSDATETIME() WHERE id_superadmin=@id;

  SELECT id_superadmin,
         CONCAT(nombres,' ',apellido_paterno,' ',apellido_materno) AS nombreCompleto
  FROM dbo.superadmins
  WHERE id_superadmin=@id;
END
GO

/* =========================================================
   SP: Listar Empresas (mínimo para UI)
   ========================================================= */
IF OBJECT_ID('dbo.sp_empresas_listar','P') IS NOT NULL
  DROP PROCEDURE dbo.sp_empresas_listar;
GO
CREATE PROCEDURE dbo.sp_empresas_listar
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;

  SELECT id_empresa, codigo_empresa, ruc, razon_social,
         db_server, db_name, activo, creado_en, actualizado_en
  FROM dbo.empresas
  ORDER BY razon_social;
END
GO

/* =========================================================
   SP: Upsert Empresa (Insert/Update según @id_empresa)
   ========================================================= */
IF OBJECT_ID('dbo.sp_empresa_upsert','P') IS NOT NULL
  DROP PROCEDURE dbo.sp_empresa_upsert;
GO
CREATE PROCEDURE dbo.sp_empresa_upsert
  @id_empresa       BIGINT = NULL,
  @codigo_empresa   VARCHAR(6),
  @ruc              VARCHAR(11),
  @razon_social     NVARCHAR(200),
  @nombre_comercial NVARCHAR(150) = NULL,
  @tipo_empresa     VARCHAR(20)   = NULL,
  @db_server        NVARCHAR(128),
  @db_name          NVARCHAR(128),
  @activo           BIT = 1
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;

  IF @id_empresa IS NULL
  BEGIN
    INSERT INTO dbo.empresas(codigo_empresa,ruc,razon_social,nombre_comercial,tipo_empresa,
                             db_server,db_name,activo)
    VALUES(@codigo_empresa,@ruc,@razon_social,@nombre_comercial,@tipo_empresa,
           @db_server,@db_name,@activo);
  END
  ELSE
  BEGIN
    UPDATE dbo.empresas
       SET codigo_empresa   = @codigo_empresa,
           ruc              = @ruc,
           razon_social     = @razon_social,
           nombre_comercial = @nombre_comercial,
           tipo_empresa     = @tipo_empresa,
           db_server        = @db_server,
           db_name          = @db_name,
           activo           = @activo,
           actualizado_en   = SYSDATETIME()
     WHERE id_empresa       = @id_empresa;
  END
END
GO

/* =========================================================
   SP: Cambiar estado (activar/desactivar empresa)
   ========================================================= */
IF OBJECT_ID('dbo.sp_empresa_cambiar_estado','P') IS NOT NULL
  DROP PROCEDURE dbo.sp_empresa_cambiar_estado;
GO
CREATE PROCEDURE dbo.sp_empresa_cambiar_estado
  @id_empresa BIGINT,
  @activo     BIT
WITH ENCRYPTION
AS
BEGIN
  UPDATE dbo.empresas
     SET activo=@activo,
         actualizado_en=SYSDATETIME()
   WHERE id_empresa=@id_empresa;
END
GO

/* =========================================================
   (Opcional) Semilla de Superadmin inicial
   -- Descomenta para crear uno de prueba:
   -- EXEC dbo.sp_superadmin_crear
   --   @dni='00000000',
   --   @apepat=N'Admin',
   --   @apemat=N'Sistema',
   --   @nombres=N'Super',
   --   @correo=N'sa@tu-dominio.com',
   --   @pwd=N'ClaveFuerte#2025',
   --   @activo=1;
   ========================================================= */

PRINT 'BD_SISGIPAT creada/actualizada. Objetos centrales listos.';
