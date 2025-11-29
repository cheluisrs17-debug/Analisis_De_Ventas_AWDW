USE [Analisis_De_Ventas_AWDW]
GO

-- *** 1. LÓGICA DE PREPARACIÓN (Para evitar errores de ejecución repetida) ***

-- Crea el esquema 'dw' si no existe (evita el error Mens. 2714/2759)
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dw')
BEGIN
    EXEC('CREATE SCHEMA dw');
END
GO

-- A. Elimina dinámicamente cualquier restricción de Foreign Key que apunte a DimCliente.
-- Esto es necesario para poder eliminar la tabla sin el error Mens. 3726 (si ya está referenciada).
DECLARE @sql_fk_drop NVARCHAR(MAX) = N'';

SELECT @sql_fk_drop += N'ALTER TABLE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) + 
               N' DROP CONSTRAINT ' + QUOTENAME(fk.name) + N';' + CHAR(13) + CHAR(10)
FROM sys.foreign_keys AS fk
INNER JOIN sys.tables AS t ON fk.parent_object_id = t.object_id
INNER JOIN sys.schemas AS s ON t.schema_id = s.schema_id
WHERE fk.referenced_object_id = OBJECT_ID(N'[dw].[DimCliente]');

EXEC sp_executesql @sql_fk_drop;
GO

-- B. Elimina la tabla si ya existe (Evita el error Mens. 2714 después de eliminar las FKs).
IF OBJECT_ID('[dw].[DimCliente]', 'U') IS NOT NULL 
    DROP TABLE [dw].[DimCliente];
GO

-- *** 2. CREACIÓN DE LA ESTRUCTURA (DDL) - Tu código original ***
CREATE TABLE [dw].[DimCliente](
	[CustomerKey] [int] NOT NULL,
	[AlternateKey] [nvarchar](15) NULL,
	[NombreCompleto] [nvarchar](150) NULL,
	[Genero] [nchar](1) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[Ciudad] [nvarchar](30) NULL,
	[EstadoProvincia] [nvarchar](50) NULL,
	[Pais] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- *** 3. INSERCIÓN DE DATOS (DML) - ESTE ES EL PASO FALTANTE ***
-- Este comando copia los datos desde AdventureWorksDW2022 a tu nueva tabla DimCliente.
INSERT INTO [dw].[DimCliente]
(
    [CustomerKey], 
    [AlternateKey], 
    [NombreCompleto], 
    [Genero], 
    [EmailAddress], 
    [Ciudad], 
    [EstadoProvincia], 
    [Pais]
)
SELECT
    C.[CustomerKey],
    C.[CustomerAlternateKey] AS [AlternateKey],
    C.[FirstName] + ' ' + C.[LastName] AS [NombreCompleto], -- Combina nombre y apellido
    C.[Gender] AS [Genero],
    C.[EmailAddress],
    G.[City] AS [Ciudad],
    G.[StateProvinceName] AS [EstadoProvincia],
    G.[EnglishCountryRegionName] AS [Pais]
FROM AdventureWorksDW2022.dbo.DimCustomer AS C
-- Usamos LEFT JOIN para obtener la información geográfica del cliente
LEFT JOIN AdventureWorksDW2022.dbo.DimGeography AS G
    ON C.[GeographyKey] = G.[GeographyKey]
WHERE C.[CustomerKey] IS NOT NULL;
GO

-- *** 4. VERIFICACIÓN FINAL DE DATOS ***
SELECT COUNT(*) AS TotalRegistrosClientes FROM [dw].[DimCliente];
GO

SELECT TOP 10 [CustomerKey], [NombreCompleto], [Ciudad], [Pais] 
FROM [dw].[DimCliente] 
ORDER BY [CustomerKey];
GO

