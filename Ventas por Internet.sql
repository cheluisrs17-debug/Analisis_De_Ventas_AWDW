
USE [Analisis_De_Ventas_AWDW]
GO

-- *** 1. LÓGICA DE PREPARACIÓN (Para evitar errores de re-ejecución) ***

-- A. Eliminar las restricciones de llave foránea (FKs) de la tabla FactVentasInternet
-- Esto es necesario para poder eliminar y recrear la tabla.
IF OBJECT_ID('[dw].[FactVentasInternet]', 'U') IS NOT NULL
BEGIN
    ALTER TABLE [dw].[FactVentasInternet] DROP CONSTRAINT IF EXISTS [FK_FactVentasInternet_DimCliente];
    ALTER TABLE [dw].[FactVentasInternet] DROP CONSTRAINT IF EXISTS [FK_FactVentasInternet_DimFecha];
    ALTER TABLE [dw].[FactVentasInternet] DROP CONSTRAINT IF EXISTS [FK_FactVentasInternet_DimProducto];
    ALTER TABLE [dw].[FactVentasInternet] DROP CONSTRAINT IF EXISTS [FK_FactVentasInternet_DimTerritorio];

    -- B. Eliminar la tabla si ya existe
    DROP TABLE [dw].[FactVentasInternet];
END
GO

-- *** 2. CREACIÓN DE LA ESTRUCTURA (DDL) - Tu código original ***
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dw].[FactVentasInternet](
	[FactVentasInternetID] [int] IDENTITY(1,1) NOT NULL,
	[DateKey] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[ProductKey] [int] NOT NULL,
	[SalesTerritoryKey] [int] NOT NULL,
	[OrderQuantity] [smallint] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[ExtendedAmount] [money] NOT NULL,
	[DiscountAmount] [money] NOT NULL,
	[SalesAmount] [money] NOT NULL,
	[TaxAmount] [money] NOT NULL,
	[Freight] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[FactVentasInternetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- *** 3. ADICIÓN DE LLAVES FORÁNEAS (FOREIGN KEY CONSTRAINTS) ***
-- Se añaden las restricciones que conectan la tabla de hechos con las dimensiones
ALTER TABLE [dw].[FactVentasInternet]  WITH CHECK ADD  CONSTRAINT [FK_FactVentasInternet_DimCliente] FOREIGN KEY([CustomerKey])
REFERENCES [dw].[DimCliente] ([CustomerKey])
GO

ALTER TABLE [dw].[FactVentasInternet] CHECK CONSTRAINT [FK_FactVentasInternet_DimCliente]
GO

ALTER TABLE [dw].[FactVentasInternet]  WITH CHECK ADD  CONSTRAINT [FK_FactVentasInternet_DimFecha] FOREIGN KEY([DateKey])
REFERENCES [dw].[DimFecha] ([DateKey])
GO

ALTER TABLE [dw].[FactVentasInternet] CHECK CONSTRAINT [FK_FactVentasInternet_DimFecha]
GO

ALTER TABLE [dw].[FactVentasInternet]  WITH CHECK ADD  CONSTRAINT [FK_FactVentasInternet_DimProducto] FOREIGN KEY([ProductKey])
REFERENCES [dw].[DimProducto] ([ProductKey])
GO

ALTER TABLE [dw].[FactVentasInternet] CHECK CONSTRAINT [FK_FactVentasInternet_DimProducto]
GO

ALTER TABLE [dw].[FactVentasInternet]  WITH CHECK ADD  CONSTRAINT [FK_FactVentasInternet_DimTerritorio] FOREIGN KEY([SalesTerritoryKey])
REFERENCES [dw].[DimTerritorio] ([SalesTerritoryKey])
GO

ALTER TABLE [dw].[FactVentasInternet] CHECK CONSTRAINT [FK_FactVentasInternet_DimTerritorio]
GO

-- *** 4. INSERCIÓN DE DATOS (DML) - EL PASO FALTANTE ***
-- Copia los datos de ventas por Internet desde AdventureWorksDW2022.dbo.FactInternetSales
INSERT INTO [dw].[FactVentasInternet]
(
    [DateKey],
    [CustomerKey],
    [ProductKey],
    [SalesTerritoryKey],
    [OrderQuantity],
    [UnitPrice],
    [ExtendedAmount],
    [DiscountAmount],
    [SalesAmount],
    [TaxAmount],
    [Freight]
)
SELECT
    T1.[OrderDateKey] AS [DateKey],  -- Usamos la fecha de la orden como la DateKey principal
    T1.[CustomerKey],
    T1.[ProductKey],
    T1.[SalesTerritoryKey],
    T1.[OrderQuantity],
    T1.[UnitPrice],
    T1.[ExtendedAmount],
    T1.[DiscountAmount],
    T1.[SalesAmount],
    T1.[TaxAmt] AS [TaxAmount],
    T1.[Freight]
FROM AdventureWorksDW2022.dbo.FactInternetSales AS T1
WHERE T1.[SalesOrderNumber] IS NOT NULL;
GO

-- *** 5. VERIFICACIÓN FINAL DE DATOS ***
SELECT COUNT(*) AS TotalVentasInternetCargadas FROM [dw].[FactVentasInternet];
GO

SELECT TOP 10 * FROM [dw].[FactVentasInternet] ORDER BY [FactVentasInternetID];
GO
















