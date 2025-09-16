IF NOT EXISTS(SELECT 1 FROM dbo.roles WHERE nombre=N'Admin')
  INSERT INTO dbo.roles(nombre,descripcion) VALUES(N'Admin',N'Administrador de la empresa');
IF NOT EXISTS(SELECT 1 FROM dbo.roles WHERE nombre=N'Operador')
  INSERT INTO dbo.roles(nombre,descripcion) VALUES(N'Operador',N'Uso diario');
IF NOT EXISTS(SELECT 1 FROM dbo.roles WHERE nombre=N'Invitado')
  INSERT INTO dbo.roles(nombre,descripcion) VALUES(N'Invitado',N'Solo lectura');
GO
