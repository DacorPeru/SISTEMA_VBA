IF OBJECT_ID('dbo.sp_usuario_cambiar_clave','P') IS NOT NULL DROP PROCEDURE dbo.sp_usuario_cambiar_clave;
GO
CREATE PROCEDURE dbo.sp_usuario_cambiar_clave
  @id_usuario BIGINT,
  @pwd_nueva  NVARCHAR(200)
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @salt VARBINARY(16)=CRYPT_GEN_RANDOM(16);
  DECLARE @hash VARBINARY(64)=HASHBYTES('SHA2_256', @salt + CONVERT(VARBINARY(4000),@pwd_nueva));
  UPDATE dbo.usuarios
     SET contrasena_hash=@hash, salt=@salt, hash_algoritmo='SHA2_256', actualizado_en=SYSDATETIME()
   WHERE id_usuario=@id_usuario;
END
GO
