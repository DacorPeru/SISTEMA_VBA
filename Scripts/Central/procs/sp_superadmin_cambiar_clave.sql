USE BD_SISGIPAT;
GO
IF OBJECT_ID('dbo.sp_superadmin_cambiar_clave','P') IS NOT NULL DROP PROCEDURE dbo.sp_superadmin_cambiar_clave;
GO
CREATE PROCEDURE dbo.sp_superadmin_cambiar_clave
  @id_superadmin BIGINT,
  @pwd_nueva     NVARCHAR(200)
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;
  IF NOT EXISTS(SELECT 1 FROM dbo.superadmins WHERE id_superadmin=@id_superadmin AND activo=1)
    RAISERROR(N'Superadmin no existe o inactivo.',16,1);
  DECLARE @salt VARBINARY(16)=CRYPT_GEN_RANDOM(16);
  DECLARE @hash VARBINARY(64)=HASHBYTES('SHA2_256', @salt + CONVERT(VARBINARY(4000),@pwd_nueva));
  UPDATE dbo.superadmins
    SET contrasena_hash=@hash, salt=@salt, hash_algoritmo='SHA2_256', actualizado_en=SYSDATETIME()
  WHERE id_superadmin=@id_superadmin;
END
GO
