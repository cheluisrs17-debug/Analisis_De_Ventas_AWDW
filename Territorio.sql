USE [Analisis_De_Ventas_AWDW]
GO

-- *** 1. LÓGICA DE PREPARACIÓN (Para evitar errores de re-ejecución) ***

-- A. Elimina cualquier restricción de Foreign Key que apunte a DimTerritorio (soluciona Mens. 3726).
DECLARE @sql_fk_drop NVARCHAR(MAX) = N'';

SELECT @sql_fk_drop += N'ALTER TABLE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) + 
               N' DROP CONSTRAINT ' + QUOTENAME(fk.name) + N';' + CHAR(13) + CHAR(10)
FROM sys.foreign_keys AS fk
INNER JOIN sys.tables AS t ON fk.parent_object_id = t.object_id
INNER JOIN sys.schemas AS s ON t.schema_id = s.schema_id
WHERE fk.referenced_object_id = OBJECT_ID(N'[dw].[DimTerritorio]');

-- Ejecuta la eliminación de FKs (si existen)
EXEC sp_executesql @sql_fk_drop;
GO

-- B. Elimina la tabla si ya existe (soluciona Mens. 2714).
IF OBJECT_ID('[dw].[DimTerritorio]', 'U') IS NOT NULL 
    DROP TABLE [dw].[DimTerritorio];
GO

-- *** 2. CREACIÓN DE LA ESTRUCTURA (DDL) ***
-- Creamos la tabla DimTerritorio con las columnas que definiste.
CREATE TABLE [dw].[DimTerritorio](
	[SalesTerritoryKey] [int] NOT NULL,
	[NombreTerritorio] [nvarchar](50) NULL,
	[GrupoTerritorio] [nvarchar](50) NULL,
	[Pais] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesTerritoryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- *** 3. INSERCIÓN DE DATOS (DML) ***
-- Este script llena la tabla 'DimTerritorio' con datos de 'AdventureWorksDW2022.dbo.DimSalesTerritory'.
-- Es crucial que la cantidad de columnas de INSERT y SELECT coincida.
INSERT INTO [dw].[DimTerritorio]
(
    [SalesTerritoryKey], 
    [NombreTerritorio], 
    [GrupoTerritorio], 
    [Pais]
)
SELECT
    T1.[SalesTerritoryKey],
    T1.[SalesTerritoryRegion] AS [NombreTerritorio], -- Mapea la región como NombreTerritorio
    T1.[SalesTerritoryGroup] AS [GrupoTerritorio],   -- Mapea el grupo
    T1.[SalesTerritoryCountry] AS [Pais]             -- Mapea el país
FROM AdventureWorksDW2022.dbo.DimSalesTerritory AS T1
WHERE T1.[SalesTerritoryKey] IS NOT NULL;
GO

-- *** 4. VERIFICACIÓN DE DATOS ***
-- Consulta de conteo para confirmar que la tabla ya no está vacía.
SELECT COUNT(*) AS TotalRegistrosTerritorio FROM [dw].[DimTerritorio];
GO

-- Muestra los primeros 10 territorios.
SELECT TOP 10 * FROM [dw].[DimTerritorio] ORDER BY [SalesTerritoryKey];
GO




















