use COM5600G02;

--------------------------------------------------------------------------------------------------------
--CREAMOS LA TABLA DE REGISTROS DE BORRADOS LOGICOS
--------------------------------------------------------------------------------------------------------

CREATE TABLE registros.Registro(
	id INT IDENTITY(1,1) PRIMARY KEY,
	fecha_hora DATETIME DEFAULT GETDATE(),
	texto NVARCHAR(255),
	modulo NVARCHAR(50) DEFAULT 'N/A'
);
GO

--------------------------------------------------------------------------------------------------------
--STORE PROCEDURE PARA REGISTRAR CUALQUIER TIPO DE BORRADO LOGICO DE CUALQUIER TABLA
--ESTE SE CREA PRIMERO PORQUE ES EL QUE LUEGO UTILIZAR�N TODOS LOS DEM�S
--------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE registros.registrarBorrado
 @texto nvarchar(255),
 @modulo nvarchar(50) = 'N/A'
AS
BEGIN
	INSERT INTO Registro(texto,modulo)
	VALUES(@texto,@modulo);
END;

GO

--------------------------------------------------------------------------------------------------------
--BORRADO LOGICO SUCURSAL
--------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE supermercado.borrado_logico_sucursal
    @id INT,
    @modulo NVARCHAR(50) = 'sucursal'
AS
BEGIN
    
    UPDATE supermercado.sucursal
    SET activo = 0 --actualizamos el estado en 0
    WHERE id = @id;

    --si modificamos alguna fila llamamos al otro sp para registrarlo
    IF @@ROWCOUNT > 0
    BEGIN
        DECLARE @ciudad NVARCHAR(40);
        DECLARE @texto NVARCHAR(255);

        -- Usamos la variable ciudad para ponerla en el texto de borrado
        SELECT @ciudad = ciudad FROM supermercado.sucursal WHERE id = @id;

        -- construimos el texto de borrado con la variable ciudad y el id
        SET @texto = CONCAT('Borrado l�gico de la sucursal en ciudad: ', @ciudad, ' (ID: ', @id, ')');

        -- Llamar al procedimiento que registra el borrado l�gico en la tabla Registro
        EXEC registros.registrarBorrado @texto = @texto, @modulo = @modulo;
    END
END;

GO

--------------------------------------------------------------------------------------------------------
--BORRADO LOGICO MEDIOS DE PAGO
--------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE ventas.borrado_logico_mediosDePago
	@id INT,
	@modulo NVARCHAR(50) = 'mediosDePago'
AS
BEGIN 
	UPDATE ventas.mediosDePago
	SET activo = 0
	WHERE  id = @id;

--Si modificamos alguna fila entonces tenemos que llamar al sp para generar el registro
	IF @@ROWCOUNT > 0
	BEGIN
		DECLARE @nombre NVARCHAR(100);
		DECLARE @texto NVARCHAR(255);


		SELECT @nombre = nombre FROM ventas.mediosDePago WHERE id = @id;

		SET @texto = CONCAT('Borrado l�gico del medio de pago: ', @nombre,' (ID: ', @id, ')');

	
		EXEC registros.registrarBorrado @texto = @texto , @modulo = @modulo;
	END
END;

GO
--------------------------------------------------------------------------------------------------------
--STORE PROCEDURE PARA HACER BORRADO LOGICO DE LINEA_DE_PRODUCTO POR CAMPO NOMBRE
--------------------------------------------------------------------------------------------------------


CREATE OR ALTER PROCEDURE catalogo.borrado_logico_lineaDeProducto
    @nombre NVARCHAR(100),  
    @modulo NVARCHAR(50) = 'linea_de_producto'
AS
BEGIN
    
    UPDATE catalogo.linea_de_producto
    SET activo = 0
    WHERE nombre = @nombre;

  
    IF @@ROWCOUNT > 0
    BEGIN
        DECLARE @texto NVARCHAR(255);
        SET @texto = CONCAT('Borrado l�gico de la l�nea de producto: ', @nombre);

        
        EXEC  registros.registrarBorrado @texto = @texto, @modulo = @modulo;
    END
END;

GO



---------------------------------------------------------------------------------
-- STORE PROCEDURE PARA HACER BORRADO LOGICO DE EMPLEADO POR LEGAJO
---------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE supermercado.borrado_logico_empleado
    @legajo INT, -- borra para el legajo
    @modulo NVARCHAR(50) = 'empleado'
AS
BEGIN
    --ponemos en 0 el activo 
    UPDATE supermercado.empleado
    SET activo = 0
    WHERE Legajo = @legajo;

    --si se modific� alguna linea
    IF @@ROWCOUNT > 0
    BEGIN
        DECLARE @texto NVARCHAR(255);
        SET @texto = CONCAT('Borrado log del empleado con Legajo: ', @legajo);

        --registramos el legajo
        EXEC  registros.registrarBorrado @texto = @texto, @modulo = @modulo;
    END
END;
GO


----------------------------------------------------------------------------------------------------------
--STORE PROCEDURE PARA HACER EL BORRADO LOGICO DE VENTAS REGISTRADAS POR EL CAMPO FACTURA Y TIPO_FACTURA
----------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ventas.borrado_logico_ventasRegistradas
    @factura NVARCHAR(20),            -- N�mero de factura
    @tipo_factura CHAR(1),             -- Tipo de factura
    @modulo NVARCHAR(50) = 'ventas_registradas'
AS
BEGIN
    -- Actualizaci�n para realizar el borrado l�gico en ventas_registradas
    UPDATE ventas.ventas_registradas
    SET activo = 0
    WHERE factura = @factura AND tipo_Factura = @tipo_factura;

    -- Si se modific� alguna fila, proceder con el registro en la tabla Registro
    IF @@ROWCOUNT > 0
    BEGIN
        DECLARE @texto NVARCHAR(255);
        SET @texto = CONCAT('Borrado l�gico de la venta con Factura: ', @factura, ' y Tipo: ', @tipo_factura);

        -- Llamada al procedimiento para registrar el borrado
        EXEC registrar_borrado_logico @texto = @texto, @modulo = @modulo;
    END
END;

GO
----------------------------------------------------------------------------------------------------------
--PROCEDURE PARA HACER BORRADO LOGICO POR EL ID DEL PRODUCTO
----------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE catalogo.borrado_logico_producto
    @id INT,                           -- ID del producto
    @modulo NVARCHAR(50) = 'producto'
AS
BEGIN
    -- Actualizaci�n para realizar el borrado l�gico en catalogo.producto
    UPDATE catalogo.producto
    SET activo = 0
    WHERE id = @id;

    -- Si se modific� alguna fila, proceder con el registro en la tabla Registro
    IF @@ROWCOUNT > 0
    BEGIN
        DECLARE @texto NVARCHAR(255);
        SET @texto = CONCAT('Borrado l�gico del producto con ID: ', @id);

        -- Llamada al procedimiento para registrar el borrado
        EXEC registrar_borrado_logico @texto = @texto, @modulo = @modulo;
    END
END;
GO
----------------------------------------------------------------------------------------------------------
--FIN
----------------------------------------------------------------------------------------------------------






