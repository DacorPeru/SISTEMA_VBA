-- Ejecutar dentro de la BD Empresa
IF OBJECT_ID('dbo.usuarios','U') IS NULL
CREATE TABLE dbo.usuarios(
  id_usuario BIGINT IDENTITY(1,1) PRIMARY KEY,
  correo NVARCHAR(150) NOT NULL UNIQUE,
  contrasena_hash VARBINARY(64) NOT NULL,
  salt VARBINARY(16) NULL,
  hash_algoritmo VARCHAR(16) NULL,
  nombres NVARCHAR(100) NOT NULL,
  activo BIT NOT NULL DEFAULT(1),
  ultimo_acceso DATETIME2(0) NULL,
  creado_en DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
  actualizado_en DATETIME2(0) NULL,
  rowver ROWVERSION
);
