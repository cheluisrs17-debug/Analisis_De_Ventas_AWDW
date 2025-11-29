USE [Analisis_De_Ventas_AWDW]
GO

-- *** 1. LÓGICA DE PREPARACIÓN (Para evitar errores de re-ejecución) ***

-- A. Elimina cualquier restricción de Foreign Key que apunte a DimProducto (soluciona Mens. 3726 si ya está en uso).
DECLARE @sql_fk_drop NVARCHAR(MAX) = N'';

SELECT @sql_fk_drop += N'ALTER TABLE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) + 
               N' DROP CONSTRAINT ' + QUOTENAME(fk.name) + N';' + CHAR(13) + CHAR(10)
FROM sys.foreign_keys AS fk
INNER JOIN sys.tables AS t ON fk.parent_object_id = t.object_id
INNER JOIN sys.schemas AS s ON t.schema_id = s.schema_id
WHERE fk.referenced_object_id = OBJECT_ID(N'[dw].[DimProducto]');

EXEC sp_executesql @sql_fk_drop;
GO

-- B. Elimina la tabla si ya existe (Evita el error Mens. 2714).
IF OBJECT_ID('[dw].[DimProducto]', 'U') IS NOT NULL 
    DROP TABLE [dw].[DimProducto];
GO

-- *** 2. CREACIÓN DE LA ESTRUCTURA (DDL) - Tu código original ***
CREATE TABLE [dw].[DimProducto](
	[ProductKey] [int] NOT NULL,
	[AlternateKey] [nvarchar](25) NULL,
	[NombreProducto] [nvarchar](50) NULL,
	[SubcategoriaProducto] [nvarchar](50) NULL,
	[CategoriaProducto] [nvarchar](50) NULL,
	[Color] [nvarchar](15) NULL,
	[Tamaño] [nvarchar](50) NULL,
	[PrecioLista] [money] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- *** 3. INSERCIÓN DE DATOS (DML) - EL PASO FALTANTE PARA LLENAR LA TABLA ***
-- Se unen DimProduct, DimProductSubcategory y DimProductCategory para obtener todos los campos.
INSERT INTO [dw].[DimProducto]
(
    [ProductKey], 
    [AlternateKey], 
    [NombreProducto], 
    [SubcategoriaProducto], 
    [CategoriaProducto], 
    [Color], 
    [Tamaño], 
    [PrecioLista]
)
SELECT
    P.[ProductKey],
    P.[ProductAlternateKey] AS [AlternateKey],
    P.[EnglishProductName] AS [NombreProducto],
    PSC.[EnglishProductSubcategoryName] AS [SubcategoriaProducto],
    PC.[EnglishProductCategoryName] AS [CategoriaProducto],
    P.[Color] AS [Color],
    P.[Size] AS [Tamaño],
    P.[ListPrice] AS [PrecioLista]
FROM AdventureWorksDW2022.dbo.DimProduct AS P
-- LEFT JOIN para Subcategoría
LEFT JOIN AdventureWorksDW2022.dbo.DimProductSubcategory AS PSC
    ON P.ProductSubcategoryKey = PSC.ProductSubcategoryKey
-- LEFT JOIN para Categoría
LEFT JOIN AdventureWorksDW2022.dbo.DimProductCategory AS PC
    ON PSC.ProductCategoryKey = PC.ProductCategoryKey
WHERE P.[ProductKey] IS NOT NULL;
GO

-- *** 4. VERIFICACIÓN FINAL DE DATOS ***
SELECT COUNT(*) AS TotalRegistrosProductos FROM [dw].[DimProducto];
GO

SELECT TOP 10 [ProductKey], [NombreProducto], [CategoriaProducto], [PrecioLista] 
FROM [dw].[DimProducto] 
ORDER BY [ProductKey];
GO


