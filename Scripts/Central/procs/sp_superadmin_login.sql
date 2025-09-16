USE BD_SISGIPAT;
GO
IF OBJECT_ID('dbo.sp_superadmin_login','P') IS NOT NULL DROP PROCEDURE dbo.sp_superadmin_login;
GO
CREATE PROCEDURE dbo.sp_superadmin_login
  @correo NVARCHAR(150),
  @pwd    NVARCHAR(200)
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @salt VARBINARY(16), @hash VARBINARY(64), @id BIGINT;
  SELECT @id=id_superadmin, @salt=salt, @hash=contrasena_hash
    FROM dbo.superadmins
   WHERE correo=@correo AND activo=1;
  IF @id IS NULL RETURN -1;
  DECLARE @calc VARBINARY(64)=HASHBYTES('SHA2_256', ISNULL(@salt,0x00)+CONVERT(VARBINARY(4000),@pwd));
  IF @calc<>@hash RETURN -2;
  UPDATE dbo.superadmins SET ultimo_acceso=SYSDATETIME() WHERE id_superadmin=@id;
  SELECT id_superadmin, nombres FROM dbo.superadmins WHERE id_superadmin=@id;
END
GO
