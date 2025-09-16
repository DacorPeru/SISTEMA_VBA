IF OBJECT_ID('dbo.sp_usuario_asignar_rol','P') IS NOT NULL DROP PROCEDURE dbo.sp_usuario_asignar_rol;
GO
CREATE PROCEDURE dbo.sp_usuario_asignar_rol
  @id_usuario BIGINT,
  @id_rol     INT
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;
  IF NOT EXISTS(SELECT 1 FROM dbo.usuario_rol WHERE id_usuario=@id_usuario AND id_rol=@id_rol)
    INSERT INTO dbo.usuario_rol(id_usuario,id_rol) VALUES(@id_usuario,@id_rol);
END
GO
