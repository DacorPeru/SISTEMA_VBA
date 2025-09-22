/* Crea y configura la BD CENTRAL SISGIPAT si no existe */

-- 1) Verifica si la BD 'SISGIPAT' no existe todavía
IF DB_ID('SISGIPAT') IS NULL
BEGIN
    -- 2) La crea de forma segura (sólo se ejecuta si no existe)
    EXEC('CREATE DATABASE SISGIPAT');
END
GO  -- 3) Fin de lote: garantiza que la BD ya esté creada

-- 4) Cambia el contexto a la BD central
USE SISGIPAT;
GO  -- 5) Fin de lote: asegura que el USE ya aplica

/* 6) Opciones seguras y consistentes a nivel de base
      (afectan cómo el optimizador genera planes para esta BD) */

-- Usar estimador de cardinalidad moderno (mejores estimaciones de filas)
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;

-- Permitir "parameter sniffing" (planes basados en los valores reales)
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;

-- Aplicar hotfixes/mejoras del optimizador sin cambiar compatibilidad
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = ON;
GO  -- 7) Fin de lote
