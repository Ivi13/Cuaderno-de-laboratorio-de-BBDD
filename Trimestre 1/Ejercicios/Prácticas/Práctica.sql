/*
Crear base de datos
*/
CREATE DATABASE IF NOT EXISTS dam1;
/*
usar la database
*/
USE dam1;
/*
DROP DATABASE IF EXISTS dam1
*/
CREATE DATABASE IF NOT EXISTS tema4;
use tema4;
-- Crear la base de datos:

CREATE DATABASE IF NOT EXISTS introSQL;

-- Usar la base de datos creada anteriormente:
USE introSQL;





-- Creación de la tabla `clientes` para la actividad

CREATE TABLE clientes (
    idcliente VARCHAR(10) PRIMARY KEY NOT NULL,
    nombre VARCHAR(20),
    direccion VARCHAR(20),
    poblacion VARCHAR(20),
    facturacion INT,
    fechaalta DATE,
    credito DECIMAL(18,2)
);

-- Inserción de registros en la tabla `clientes`

INSERT INTO clientes (idcliente, nombre, direccion, poblacion, facturacion, fechaalta, credito) VALUES
('1', 'Cliente1', 'Calle A', 'Madrid', 10000, '2023-01-01', 1500.00),
('2', 'Cliente2', 'Calle B', 'Barcelona', 20000, '2023-02-01', 2500.00),
('3', 'Cliente3', 'Calle C', 'Valencia', 15000, '2023-03-01', 1800.00);

-- Sentencias básicas `SELECT` para los ejemplos de la actividad

-- Recuperar todas las columnas de la tabla `clientes`
SELECT * FROM clientes;

-- Recuperar columnas específicas (`nombre` y `direccion`)
SELECT nombre, direccion FROM clientes;

-- Eliminar duplicados con `DISTINCT`
SELECT DISTINCT poblacion FROM clientes;

-- Actividad práctica: Consultas adicionales

-- Consultar clientes con facturación mayor a 15000
SELECT nombre, facturacion FROM clientes WHERE facturacion > 15000;

-- Consultar clientes registrados después del 1 de febrero de 2023
SELECT nombre, fechaalta FROM clientes WHERE fechaalta > '2023-02-01';

-- Consultar el crédito de los clientes que residen en Madrid
SELECT nombre, credito FROM clientes WHERE poblacion = 'Madrid';

-- Consultar clientes cuyo crédito es mayor a 2000 y cuya facturación es menor a 20000
SELECT nombre, credito, facturacion FROM clientes WHERE credito > 1800 AND facturacion < 20000;

-- Consultar todas las poblaciones eliminando duplicados
SELECT DISTINCT poblacion FROM clientes;

-- Consultar los nombres de los clientes ordenados alfabéticamente
SELECT nombre FROM clientes ORDER BY nombre ASC;

-- Consultar los clientes ordenados por facturación de mayor a menor
SELECT nombre, facturacion FROM clientes ORDER BY facturacion DESC;