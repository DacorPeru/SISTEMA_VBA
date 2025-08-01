CREATE DATABASE BD_SISGIPAT;
GO
USE BD_SISGIPAT;
GO

/* ============================================
   1️⃣ TABLA EMPRESAS
   ============================================ */
CREATE TABLE empresas (
    id_empresa BIGINT IDENTITY(1,1) PRIMARY KEY,
    codigo_empresa VARCHAR(6) NOT NULL UNIQUE,
    ruc VARCHAR(11) NOT NULL UNIQUE,
    razon_social NVARCHAR(200) NOT NULL,
    nombre_comercial NVARCHAR(150),
    tipo_empresa VARCHAR(20) CHECK (tipo_empresa IN ('Privada','Publica')),
    direccion NVARCHAR(255),
    telefono VARCHAR(20),
    correo_contacto NVARCHAR(150),
    representante_legal NVARCHAR(150),
    dni_rep_legal VARCHAR(8),
    estado BIT DEFAULT 1,
    fecha_creacion DATETIME2 DEFAULT SYSDATETIME(),
    fecha_actualizacion DATETIME2,
    es_sincronizado BIT DEFAULT 0
);
CREATE INDEX idx_empresas_ruc ON empresas(ruc);

/* ============================================
   2️⃣ USUARIOS Y ROLES
   ============================================ */
CREATE TABLE usuarios (
    id_usuario BIGINT IDENTITY(1,1) PRIMARY KEY,
    dni VARCHAR(8) NOT NULL UNIQUE,
    nombres NVARCHAR(100) NOT NULL,
    apellido_paterno NVARCHAR(100),
    apellido_materno NVARCHAR(100),
    correo NVARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    contrasena_hash VARBINARY(64) NOT NULL,
    estado BIT DEFAULT 1,
    ultimo_acceso DATETIME2,
    fecha_creacion DATETIME2 DEFAULT SYSDATETIME(),
    fecha_actualizacion DATETIME2,
    es_sincronizado BIT DEFAULT 0
);
CREATE INDEX idx_usuarios_dni ON usuarios(dni);

CREATE TABLE roles (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(50) NOT NULL UNIQUE,
    descripcion NVARCHAR(150)
);

CREATE TABLE usuario_rol (
    id_usuario_rol BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_usuario BIGINT NOT NULL FOREIGN KEY REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    id_rol INT NOT NULL FOREIGN KEY REFERENCES roles(id_rol),
    CONSTRAINT uq_usuario_rol UNIQUE (id_usuario, id_rol)
);

CREATE TABLE usuario_empresa (
    id_usuario_empresa BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_usuario BIGINT NOT NULL FOREIGN KEY REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    id_empresa BIGINT NOT NULL FOREIGN KEY REFERENCES empresas(id_empresa) ON DELETE CASCADE,
    id_rol INT FOREIGN KEY REFERENCES roles(id_rol),
    estado BIT DEFAULT 1,
    fecha_creacion DATETIME2 DEFAULT SYSDATETIME(),
    CONSTRAINT uq_usuario_empresa UNIQUE (id_usuario, id_empresa)
);

/* ============================================
   3️⃣ PLANES, LICENCIAS Y MÓDULOS
   ============================================ */
CREATE TABLE planes (
    id_plan INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(50) NOT NULL UNIQUE,
    descripcion NVARCHAR(200),
    max_usuarios INT,
    max_empresas INT,
    precio_mensual DECIMAL(10,2),
    incluye_soporte BIT DEFAULT 0,
    activo BIT DEFAULT 1
);

CREATE TABLE licencias (
    id_licencia BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_empresa BIGINT NOT NULL FOREIGN KEY REFERENCES empresas(id_empresa) ON DELETE CASCADE,
    id_plan INT NOT NULL FOREIGN KEY REFERENCES planes(id_plan),
    fecha_inicio DATETIME2 DEFAULT SYSDATETIME(),
    fecha_fin DATETIME2,
    activa BIT DEFAULT 1
);

CREATE TABLE modulos (
    id_modulo INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL UNIQUE,
    descripcion NVARCHAR(200),
    activo BIT DEFAULT 1
);

CREATE TABLE plan_modulo (
    id_plan_modulo BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_plan INT NOT NULL FOREIGN KEY REFERENCES planes(id_plan) ON DELETE CASCADE,
    id_modulo INT NOT NULL FOREIGN KEY REFERENCES modulos(id_modulo) ON DELETE CASCADE
);

CREATE TABLE empresa_modulo (
    id_empresa_modulo BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_empresa BIGINT NOT NULL FOREIGN KEY REFERENCES empresas(id_empresa) ON DELETE CASCADE,
    id_modulo INT NOT NULL FOREIGN KEY REFERENCES modulos(id_modulo) ON DELETE CASCADE,
    activo BIT DEFAULT 1,
    fecha_asignacion DATETIME2 DEFAULT SYSDATETIME()
);

/* ============================================
   4️⃣ TOKENS Y SESIONES
   ============================================ */
CREATE TABLE tokens_acceso (
    id_token BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_usuario BIGINT NOT NULL FOREIGN KEY REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    token NVARCHAR(255) NOT NULL UNIQUE,
    fecha_creacion DATETIME2 DEFAULT SYSDATETIME(),
    fecha_expiracion DATETIME2,
    usado BIT DEFAULT 0
);
CREATE INDEX idx_tokens_usuario ON tokens_acceso(id_usuario);

CREATE TABLE sesiones (
    id_sesion BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_usuario BIGINT NOT NULL,
    id_token BIGINT NOT NULL,
    ip NVARCHAR(45),
    agente_usuario NVARCHAR(200),
    inicio DATETIME2 DEFAULT SYSDATETIME(),
    ultima_actividad DATETIME2,
    cerrada BIT DEFAULT 0,
    CONSTRAINT FK_sesiones_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    CONSTRAINT FK_sesiones_token FOREIGN KEY (id_token) 
        REFERENCES tokens_acceso(id_token) ON DELETE NO ACTION
);
CREATE INDEX idx_sesiones_usuario ON sesiones(id_usuario);

/* ============================================
   5️⃣ AUDITORÍA
   ============================================ */
CREATE TABLE auditoria (
    id_auditoria BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_usuario BIGINT FOREIGN KEY REFERENCES usuarios(id_usuario),
    accion NVARCHAR(100),
    tabla_afectada NVARCHAR(100),
    descripcion NVARCHAR(300),
    fecha DATETIME2 DEFAULT SYSDATETIME()
);
