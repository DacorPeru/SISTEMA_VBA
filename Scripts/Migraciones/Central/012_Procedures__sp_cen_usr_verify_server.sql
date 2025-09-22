USE SISGIPAT;
GO

-- Crea roles si aún no existen
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name='app_user'  AND type='R')
    CREATE ROLE app_user  AUTHORIZATION dbo;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name='app_admin' AND type='R')
    CREATE ROLE app_admin AUTHORIZATION dbo;
GO

-- (Re)crear el SP de verificación (por si quedó a medias)
CREATE OR ALTER PROCEDURE dbo.sp_cen_usr_verify_server
  @email     NVARCHAR(320),
  @pwd_plain NVARCHAR(4000)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @salt VARBINARY(16), @iter INT, @hash VARBINARY(32),
          @est  VARCHAR(20),   @kdf  VARCHAR(32);

  SELECT @salt=salt, @iter=[iter], @hash=[hash], @est=est, @kdf=kdf_alg
  FROM dbo.cen_usr
  WHERE email=@email;

  IF @salt IS NULL          BEGIN SELECT ok=0, msg=N'Usuario no existe.';          RETURN; END
  IF @est <> 'ACTIVO'       BEGIN SELECT ok=0, msg=N'Usuario inactivo.';           RETURN; END
  IF @kdf <> 'TSQL_STRETCH' BEGIN SELECT ok=0, msg=N'Algoritmo no soportado (use DLL).'; RETURN; END

  IF dbo.fn_pbkdf2_sha256(@pwd_plain,@salt,@iter) = @hash
       SELECT ok=1, msg=N'OK';
  ELSE SELECT ok=0, msg=N'Credenciales inválidas.';
END
GO

-- Ahora sí, concede permiso al rol
GRANT EXECUTE ON dbo.sp_cen_usr_verify_server TO app_user;
GO
