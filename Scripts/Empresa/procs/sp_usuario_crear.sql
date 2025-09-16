IF OBJECT_ID('dbo.sp_usuario_crear','P') IS NOT NULL DROP PROCEDURE dbo.sp_usuario_crear;
GO
CREATE PROCEDURE dbo.sp_usuario_crear
  @correo NVARCHAR(150),
  @pwd    NVARCHAR(200),
  @nombres NVARCHAR(100),
  @activo BIT = 1
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @salt VARBINARY(16)=CRYPT_GEN_RANDOM(16);
  DECLARE @hash VARBINARY(64)=HASHBYTES('SHA2_256', @salt + CONVERT(VARBINARY(4000),@pwd));
  INSERT INTO dbo.usuarios(correo,contrasena_hash,salt,hash_algoritmo,nombres,activo)
  VALUES(@correo,@hash,@salt,'SHA2_256',@nombres,@activo);
END
GO
