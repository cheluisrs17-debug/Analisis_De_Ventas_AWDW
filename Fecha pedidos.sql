USE [Analisis_De_Ventas_AWDW]
GO

-- *** 1. LÓGICA DE PREPARACIÓN (Para evitar errores de re-ejecución) ***

-- A. Elimina cualquier restricción de Foreign Key que apunte a DimFecha (soluciona Mens. 3726 si ya está en uso).
DECLARE @sql_fk_drop NVARCHAR(MAX) = N'';

SELECT @sql_fk_drop += N'ALTER TABLE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) + 
               N' DROP CONSTRAINT ' + QUOTENAME(fk.name) + N';' + CHAR(13) + CHAR(10)
FROM sys.foreign_keys AS fk
INNER JOIN sys.tables AS t ON fk.parent_object_id = t.object_id
INNER JOIN sys.schemas AS s ON t.schema_id = s.schema_id
WHERE fk.referenced_object_id = OBJECT_ID(N'[dw].[DimFecha]');

EXEC sp_executesql @sql_fk_drop;
GO

-- B. Elimina la tabla si ya existe (Evita el error Mens. 2714).
IF OBJECT_ID('[dw].[DimFecha]', 'U') IS NOT NULL 
    DROP TABLE [dw].[DimFecha];
GO

-- *** 2. CREACIÓN DE LA ESTRUCTURA (DDL) - Tu código original ***
CREATE TABLE [dw].[DimFecha](
	[DateKey] [int] NOT NULL,
	[FechaCompleta] [date] NOT NULL,
	[Dia] [tinyint] NOT NULL,
	[NombreDiaSemana] [nvarchar](10) NULL,
	[NumeroSemana] [tinyint] NULL,
	[Mes] [tinyint] NOT NULL,
	[NombreMes] [nvarchar](10) NULL,
	[Trimestre] [tinyint] NULL,
	[Año] [smallint] NULL,
PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- *** 3. INSERCIÓN DE DATOS (DML) - EL PASO FALTANTE PARA LLENAR LA TABLA ***
-- Copia los datos desde AdventureWorksDW2022.dbo.DimDate a tu nueva tabla DimFecha.
INSERT INTO [dw].[DimFecha]
(
    [DateKey], 
    [FechaCompleta], 
    [Dia], 
    [NombreDiaSemana], 
    [NumeroSemana], 
    [Mes], 
    [NombreMes], 
    [Trimestre], 
    [Año]
)
SELECT
    T1.[DateKey],
    CAST(T1.[FullDateAlternateKey] AS DATE) AS [FechaCompleta], -- Se usa FullDateAlternateKey como la fecha completa
    T1.[DayNumberOfMonth] AS [Dia],
    T1.[EnglishDayNameOfWeek] AS [NombreDiaSemana],
    T1.[WeekNumberOfYear] AS [NumeroSemana],
    T1.[MonthNumberOfYear] AS [Mes],
    T1.[EnglishMonthName] AS [NombreMes],
    T1.[CalendarQuarter] AS [Trimestre],
    T1.[CalendarYear] AS [Año]
FROM AdventureWorksDW2022.dbo.DimDate AS T1
WHERE T1.[DateKey] IS NOT NULL;
GO

-- *** 4. VERIFICACIÓN FINAL DE DATOS ***
SELECT COUNT(*) AS TotalRegistrosFechas FROM [dw].[DimFecha];
GO

SELECT TOP 10 * FROM [dw].[DimFecha] ORDER BY [DateKey];
GO
















