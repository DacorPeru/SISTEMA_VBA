/* ============================================================
   SISGIPAT - SEMILLA (Central)
   Inserta: 1 SuperAdmin + 1 Empresa DEMO (si no existen)
   ============================================================ */
USE BD_SISGIPAT;
GO

SET XACT_ABORT ON;
BEGIN TRAN;

-- 1) SUPERADMIN INICIAL (ajusta correo/clave)
DECLARE @sa_correo NVARCHAR(150) = N'sa@midominio.com';
DECLARE @sa_pwd    NVARCHAR(200) = N'ClaveFuerte#2025';

IF NOT EXISTS (SELECT 1 FROM dbo.superadmins)
BEGIN
    DECLARE @salt VARBINARY(16) = CRYPT_GEN_RANDOM(16);
    DECLARE @hash VARBINARY(64) = HASHBYTES('SHA2_256', @salt + CONVERT(VARBINARY(4000), @sa_pwd));

    INSERT INTO dbo.superadmins
           (dni, apellido_paterno, apellido_materno, nombres, correo,
            contrasena_hash, salt, activo)
    VALUES ('00000000', N'Admin', N'Sistema', N'Super', @sa_correo,
            @hash, @salt, 1);
END

-- 2) EMPRESA DEMO (ajusta si tu entorno usa otros nombres)
IF NOT EXISTS (SELECT 1 FROM dbo.empresas WHERE codigo_empresa = 'EMP001')
BEGIN
    INSERT INTO dbo.empresas
           (codigo_empresa, ruc, razon_social, nombre_comercial, tipo_empresa,
            db_server, db_name, activo)
    VALUES ('EMP001', '00000000000', N'EMPRESA DEMO S.A.C.', N'EMPRESA DEMO', 'Privada',
            N'.', N'BD_EMPRESA_001', 1);
END

COMMIT;
PRINT 'Semilla aplicada (SA + EMPRESA DEMO).';
GO
