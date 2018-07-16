
/*Funcion para convertir filas en columnas */
USE [BDPIentomologia]
GO
/*PARAMETROS*/
DECLARE @idproyecto INT
SET @idproyecto = 200

DECLARE @idobservacion INT
DECLARE @valor VARCHAR(MAX)
DECLARE @nombrevariable VARCHAR(40)

DECLARE @contadorIdoObservacion INT
DECLARE @contadorDatosVariable INT
SET @contadorIdoObservacion = 0

DECLARE @informacionDatoVariable VARCHAR(MAX)
DECLARE @informacionTabla VARCHAR(MAX)

DECLARE cursorIdobservacion CURSOR SCROLL FOR
(SELECT tbdatosvariable.idobservacion FROM tbobservacion
INNER JOIN tbdatosvariable 
ON tbobservacion.idobservacion = tbdatosvariable.idobservacion
WHERE tbobservacion.idproyectoinv = @idproyecto
GROUP BY tbdatosvariable.idobservacion)

OPEN cursorIdobservacion

FETCH FIRST FROM cursorIdobservacion INTO @idobservacion
WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE cursorDatos CURSOR SCROLL FOR
	(SELECT tbvariable.nombrevariable, tbdatosvariable.valor
	FROM tbdatosvariable 
	INNER JOIN tbvariable ON
	tbdatosvariable.idvariable = tbvariable.idvariable
	WHERE tbdatosvariable.idobservacion = @idobservacion)

	SET @informacionDatoVariable =''
	SET @contadorDatosVariable =0

	OPEN cursorDatos
	FETCH FIRST FROM cursorDatos INTO @nombrevariable,@valor
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @contadorDatosVariable += 1 
		IF @contadorDatosVariable = 1
			SET @informacionDatoVariable = @informacionDatoVariable + 'SELECT OBSERVACION='
			+CONVERT(varchar,@idobservacion)+','
			+@nombrevariable+'='''+CONVERT(varchar,@valor)+''''
		ELSE
			SET @informacionDatoVariable = @informacionDatoVariable + ','
			+@nombrevariable+'='''+CONVERT(varchar,@valor)+''''
			
		FETCH NEXT FROM cursorDatos INTO @nombrevariable,@valor
	END
	CLOSE cursorDatos
	DEALLOCATE cursorDatos

	SET @contadorIdoObservacion +=1
	IF @contadorIdoObservacion =1 
		SET @informacionTabla = @informacionDatoVariable
	ELSE
		SET @informacionTabla = @informacionTabla + ' UNION ' + @informacionDatoVariable
	FETCH NEXT FROM cursorIdobservacion INTO @idobservacion
END
PRINT(@informacionTabla)
EXEC(@informacionTabla)
CLOSE cursorIdobservacion
DEALLOCATE cursorIdobservacion
GO



