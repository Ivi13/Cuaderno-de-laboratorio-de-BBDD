CREATE DATABASE IF NOT EXISTS actividad1;

USE actividad1;

CREATE TABLE CLIENTES (
cif VARCHAR(9) PRIMARY KEY NOT NULL,
nombre VARCHAR(30) NOT NULL,
direccion VARCHAR(50),
poblacion VARCHAR(50),
web VARCHAR(60),
correo VARCHAR(40)
);

INSERT INTO CLIENTES (cif, nombre, direccion, poblacion, web, correo) VALUES
('A12345678', 'Cliente A', 'Calle Mayor 1', 'Madrid', 'www.clientea.com', 'clientea@gmail.com'),
('B87654321', 'Cliente B', 'Av. Sol 22', 'Barcelona', 'www.clienteb.com', 'clienteb@gmail.com');

CREATE TABLE FACTURAS (
idfactura INT AUTO_INCREMENT PRIMARY KEY,
fechafactura DATETIME,
total DECIMAL(12, 2),
iva DECIMAL(10,2),
descuento DECIMAL(10,2) NULL,
cif VARCHAR(9) NOT NULL,
CONSTRAINT FK_clientes_facturas FOREIGN KEY (cif) REFERENCES CLIENTES(cif) ON DELETE CASCADE
);

INSERT INTO FACTURAS (fechafactura, total, iva, descuento, cif) VALUES
('2024-10-01 10:00:00', 100.00, 21.00, 5.00, 'A12345678'),
('2024-10-02 11:30:00', 200.00, 21.00, NULL, 'A12345678'),
('2024-10-03 15:00:00', 150.00, 21.00, 10.00, 'B87654321');

SELECT
CLIENTES.cif,
CLIENTES.nombre,
FACTURAS.idfactura,
FACTURAS.fechafactura,
FACTURAS.total
FROM
CLIENTES
JOIN
FACTURAS ON CLIENTES.cif = FACTURAS.cif;

SELECT * FROM FACTURAS;
