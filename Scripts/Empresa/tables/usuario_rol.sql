IF OBJECT_ID('dbo.usuario_rol','U') IS NOT NULL DROP TABLE dbo.usuario_rol;
CREATE TABLE dbo.usuario_rol(
  id_usuario BIGINT NOT NULL REFERENCES dbo.usuarios(id_usuario) ON DELETE CASCADE,
  id_rol     INT    NOT NULL REFERENCES dbo.roles(id_rol),
  CONSTRAINT PK_usuario_rol PRIMARY KEY(id_usuario,id_rol)
);
