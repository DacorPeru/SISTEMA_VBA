USE SISGIPAT;
GO
SET NOCOUNT ON;

/* ============================================================
   Seed ADMIN — Bootstrap SIN DLL (DEV)
   - Crea/actualiza admin@sisgipat.com
   - Resuelve tipo de documento desde cat_tipo_doc
   - Hash+salt se calculan en SQL (fallback) via sp_cen_usr_upsert
   ============================================================ */

-- Chequeos previos (orden correcto)
IF OBJECT_ID('dbo.cen_usr','U') IS NULL
    THROW 51020, 'Falta dbo.cen_usr. Ejecuta 004_Tables__Create_cen_usr.sql.', 1;
IF OBJECT_ID('dbo.sp_cen_usr_upsert','P') IS NULL
    THROW 51022, 'Falta dbo.sp_cen_usr_upsert. Ejecuta 008_Procedures__sp_cen_usr_upsert.sql.', 1;

-- 1) Datos del usuario (perfil)
DECLARE @email        NVARCHAR(320) = N'admin@sisgipat.com';
DECLARE @nombres      NVARCHAR(100) = N'GESMER BIULIER';
DECLARE @ape_paterno  NVARCHAR(100) = N'REYES';
DECLARE @ape_materno  NVARCHAR(100) = N'EUSTAQUIO';

-- 2) Documento (elige: 'DNI' / 'RUC' / 'CE' / 'PAS' / 'OTR')
DECLARE @tipo_doc_codigo CHAR(3)     = 'DNI';  -- Este es el código del tipo de documento, por ejemplo 'DNI'
DECLARE @nro_doc         NVARCHAR(20)= N'00000000';

-- Obtener el tipo_doc_id desde la tabla cat_tipo_doc utilizando tipo_doc_codigo
DECLARE @tipo_doc_id SMALLINT;
SELECT @tipo_doc_id = c.tipo_doc_id
FROM dbo.cat_tipo_doc AS c
WHERE c.codigo = @tipo_doc_codigo AND c.estado = 'ACTIVO';

-- Verificar si el tipo de documento es válido
IF @tipo_doc_id IS NULL
    THROW 51010, 'SISGIPAT: Tipo de documento no existe o no está ACTIVO.', 1;

-- 3) Contraseña INICIAL (solo dev/bootstrap)
DECLARE @pwd NVARCHAR(4000) = N'Admin';   -- ⚠️ débil; solo para DEV

-- 4) Upsert del perfil + set de contraseña inicial (fallback en SQL)
EXEC dbo.sp_cen_usr_upsert
     @email        = @email,
     @nombres      = @nombres,
     @ape_paterno  = @ape_paterno,
     @ape_materno  = @ape_materno,
     @tipo_doc_id  = @tipo_doc_id,   -- Usamos el ID del tipo de documento obtenido
     @nro_doc      = @nro_doc,
     @pwd_plain    = @pwd,           -- se calcula hash/salt en SQL (temporal)
     @est          = 'ACTIVO',
     @iter         = 120000;

-- 5) Verificación inmediata (¿la clave "Admin" coincide?)
-- Usamos el procedimiento sp_cen_login para verificar las credenciales
DECLARE @loginStatus INT;

EXEC @loginStatus = dbo.sp_cen_login @email = @email, @pwd_plain = @pwd;

-- Si el login fue exitoso, @loginStatus debe ser 1, de lo contrario 0
IF @loginStatus = 1
BEGIN
    PRINT 'Login exitoso';
END
ELSE
BEGIN
    PRINT 'Credenciales incorrectas';
END
GO
