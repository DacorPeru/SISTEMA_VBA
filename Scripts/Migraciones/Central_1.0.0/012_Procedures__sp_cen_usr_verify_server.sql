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
  @pwd_plain NVARCHAR(4000)  -- Contraseña proporcionada por el usuario
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @salt VARBINARY(16), @iter INT, @hash VARBINARY(32),
          @est  VARCHAR(20),   @kdf  VARCHAR(32);

  -- Recuperar salt, iter y hash desde la base de datos
  SELECT @salt = salt, @iter = [iter], @hash = [hash], @est = est, @kdf = kdf_alg
  FROM dbo.cen_usr
  WHERE email = @email;

  -- Verificar si el usuario no existe o si está inactivo
  IF @salt IS NULL
  BEGIN
    SELECT ok = 0, msg = N'Usuario no existe.';
    RETURN;
  END

  IF @est <> 'ACTIVO'
  BEGIN
    SELECT ok = 0, msg = N'Usuario inactivo.';
    RETURN;
  END

  -- Verificar el algoritmo de KDF (si no es el esperado)
  IF @kdf <> 'TSQL_STRETCH'
  BEGIN
    SELECT ok = 0, msg = N'Algoritmo no soportado (use DLL).';
    RETURN;
  END

  -- Calcular el hash de la contraseña proporcionada (debe hacerse fuera de la base de datos)
  -- Este hash debe ser calculado en la aplicación o DLL y proporcionado aquí para la comparación.
  DECLARE @calculated_hash VARBINARY(32);

  -- Aquí es donde se debería calcular el hash fuera de la base de datos (por ejemplo, en la DLL o la aplicación)
  -- El cálculo del hash con el salt y las iteraciones debe realizarse externamente.
  -- Supongamos que el hash calculado se pasa como parámetro o desde la DLL:
  
  -- Aquí deberías obtener el hash calculado por la aplicación o DLL (en este ejemplo se deja como NULL)
  SET @calculated_hash = NULL;  -- Debe ser reemplazado con el valor calculado externamente

  -- Comparar el hash calculado con el hash almacenado en la base de datos
  IF @calculated_hash = @hash
  BEGIN
    SELECT ok = 1, msg = N'OK';  -- Login exitoso
  END
  ELSE
  BEGIN
    SELECT ok = 0, msg = N'Credenciales inválidas.';  -- Credenciales incorrectas
  END
END
GO

-- Ahora sí, concede permiso al rol
GRANT EXECUTE ON dbo.sp_cen_usr_verify_server TO app_user;
GO
