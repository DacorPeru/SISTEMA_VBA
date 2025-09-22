USE SISGIPAT;
GO
IF OBJECT_ID('dbo.sp_cen_login','P') IS NOT NULL
  DROP PROCEDURE dbo.sp_cen_login;
GO
CREATE PROCEDURE dbo.sp_cen_login
  @email NVARCHAR(320),
  @pwd_plain NVARCHAR(4000)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @salt VARBINARY(16), @iter INT, @hash VARBINARY(32), @est VARCHAR(20), @kdf VARCHAR(32);
  SELECT @salt=salt,@iter=[iter],@hash=[hash],@est=est,@kdf=kdf_alg
  FROM dbo.cen_usr WHERE email=@email;

  IF @salt IS NULL          BEGIN SELECT 0 AS LoginStatus; RETURN; END
  IF @est <> 'ACTIVO'       BEGIN SELECT 0 AS LoginStatus; RETURN; END
  IF @kdf <> 'TSQL_STRETCH' BEGIN SELECT 0 AS LoginStatus; RETURN; END
  IF @iter IS NULL OR @iter < 1 SET @iter=100000;

  DECLARE @cur VARBINARY(32) = HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX),@pwd_plain) + @salt);
  DECLARE @i INT = 1;
  WHILE @i < @iter
  BEGIN
    SET @cur = HASHBYTES('SHA2_256', @cur);
    SET @i += 1;
  END

  IF @cur = @hash SELECT 1 AS LoginStatus ELSE SELECT 0 AS LoginStatus;
END
GO
