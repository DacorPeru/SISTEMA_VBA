USE SISGIPAT;
GO
CREATE OR ALTER PROCEDURE dbo.sp_cen_usr_verify_server
  @email NVARCHAR(320),
  @pwd_plain NVARCHAR(4000)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @salt VARBINARY(16), @iter INT, @hash VARBINARY(32),
          @est VARCHAR(20), @kdf VARCHAR(32);

  SELECT @salt=salt,@iter=[iter],@hash=[hash],@est=est,@kdf=kdf_alg
  FROM dbo.cen_usr WHERE email=@email;

  IF @salt IS NULL          BEGIN SELECT ok=0, msg=N'Usuario no existe.'; RETURN; END
  IF @est <> 'ACTIVO'       BEGIN SELECT ok=0, msg=N'Usuario inactivo.'; RETURN; END
  IF @kdf <> 'TSQL_STRETCH' BEGIN SELECT ok=0, msg=N'Algoritmo no soportado (use DLL).'; RETURN; END
  IF @iter IS NULL OR @iter < 1 SET @iter=100000;

  DECLARE @cur VARBINARY(32) = HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX),@pwd_plain) + @salt);
  DECLARE @i INT = 1;
  WHILE @i < @iter
  BEGIN
    SET @cur = HASHBYTES('SHA2_256', @cur);
    SET @i += 1;
  END

  IF @cur=@hash SELECT ok=1, msg=N'OK' ELSE SELECT ok=0, msg=N'Credenciales inválidas.';
END
GO

GRANT EXECUTE ON dbo.sp_cen_usr_verify_server TO PUBLIC;
GO
