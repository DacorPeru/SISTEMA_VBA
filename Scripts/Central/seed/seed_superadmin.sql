USE BD_SISGIPAT;
GO
EXEC dbo.sp_superadmin_crear
 @correo   = N'sa@tu-dominio.com',
 @pwd      = N'ClaveFuerte#2025',
 @nombres  = N'Super Administrador',
 @activo   = 1;
GO
