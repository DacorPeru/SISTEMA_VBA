IF OBJECT_ID('dbo.sp_usuario_quitar_rol','P') IS NOT NULL DROP PROCEDURE dbo.sp_usuario_quitar_rol;
GO
CREATE PROCEDURE dbo.sp_usuario_quitar_rol
  @id_usuario BIGINT,
  @id_rol     INT
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM dbo.usuario_rol WHERE id_usuario=@id_usuario AND id_rol=@id_rol;
END
GO
