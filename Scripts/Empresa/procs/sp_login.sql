IF OBJECT_ID('dbo.sp_login','P') IS NOT NULL DROP PROCEDURE dbo.sp_login;
GO
CREATE PROCEDURE dbo.sp_login
  @correo NVARCHAR(150),
  @pwd    NVARCHAR(200)
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @id BIGINT,@salt VARBINARY(16),@hash VARBINARY(64);
  SELECT @id=id_usuario,@salt=salt,@hash=contrasena_hash
    FROM dbo.usuarios
   WHERE correo=@correo AND activo=1;
  IF @id IS NULL RETURN -1;
  DECLARE @calc VARBINARY(64)=HASHBYTES('SHA2_256', ISNULL(@salt,0x00)+CONVERT(VARBINARY(4000),@pwd));
  IF @calc<>@hash RETURN -2;
  UPDATE dbo.usuarios SET ultimo_acceso=SYSDATETIME() WHERE id_usuario=@id;
  SELECT id_usuario,nombres FROM dbo.usuarios WHERE id_usuario=@id;  -- RS1
  SELECT r.nombre
    FROM dbo.usuario_rol ur JOIN dbo.roles r ON r.id_rol=ur.id_rol
   WHERE ur.id_usuario=@id;                                            -- RS2
END
GO
