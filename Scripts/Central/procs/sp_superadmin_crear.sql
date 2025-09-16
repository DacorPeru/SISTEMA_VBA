USE BD_SISGIPAT;
GO
IF OBJECT_ID('dbo.sp_superadmin_crear','P') IS NOT NULL DROP PROCEDURE dbo.sp_superadmin_crear;
GO
CREATE PROCEDURE dbo.sp_superadmin_crear
  @correo NVARCHAR(150),
  @pwd    NVARCHAR(200),
  @nombres NVARCHAR(100),
  @activo BIT = 1
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;
  IF EXISTS(SELECT 1 FROM dbo.superadmins WHERE correo=@correo)
    RAISERROR(N'El correo ya existe.',16,1);
  DECLARE @salt VARBINARY(16)=CRYPT_GEN_RANDOM(16);
  DECLARE @hash VARBINARY(64)=HASHBYTES('SHA2_256', @salt + CONVERT(VARBINARY(4000),@pwd));
  INSERT INTO dbo.superadmins(correo,contrasena_hash,salt,hash_algoritmo,nombres,activo)
  VALUES(@correo,@hash,@salt,'SHA2_256',@nombres,@activo);
END
GO
