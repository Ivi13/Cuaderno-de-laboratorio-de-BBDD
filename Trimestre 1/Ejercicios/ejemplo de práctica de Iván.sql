CREATE DATABASE IF NOT EXISTS juanjo1;

USE juanjo1;

CREATE TABLE jesus(
DNI VARCHAR(9) NOT NULL,
ID_jesus INT,
nombre VARCHAR(20),
apellido VARCHAR(20),
CONSTRAINT PK_DNI_JESUS PRIMARY KEY (DNI)
);

CREATE TABLE vecina(
ID_vecina INT AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(30),
apellido VARCHAR(15),
DNI_jesus VARCHAR (9) NOT NULL,
CONSTRAINT FK_DNI_JESUS FOREIGN KEY (DNI_jesus) REFERENCES jesus(DNI) ON DELETE CASCADE
);

INSERT INTO jesus (DNI, nombre, apellido) VALUES
('A12345678', 'Jesus', 'Crist');

INSERT INTO vecina (DNI_jesus, nombre, apellido) VALUES
('A12345678', 'Josefa', 'Pérez');

#Drop database juanjo1;

SELECT
jesus.DNI,
jesus.nombre AS nombre_jesus,
vecina.ID_vecina,
vecina.nombre AS nombre_vecina,
vecina.apellido
FROM
jesus
JOIN
vecina ON jesus.DNI = vecina.DNI_jesus;

#Muestra la tabla

show create table vecina;

#Añade una columna

Alter table vecina
ADD ciudad Varchar(20) NULL;

#Borra la foreign key

Alter table vecina
DROP FOREIGN KEY FK_DNI_jesus;

#Muestra la tabla

show create table vecina;

#Añade la foreign key

Alter table vecina
ADD CONSTRAINT FK_DNI_jesus FOREIGN KEY (DNI_jesus) REFERENCES jesus(DNI);
