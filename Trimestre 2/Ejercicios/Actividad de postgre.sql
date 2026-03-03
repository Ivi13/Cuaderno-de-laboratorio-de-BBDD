-- 1.1 Concatenación de cadenas
-- Muestra los primeros 10 empleados con su nombre completo

SELECT 
    id,
    nombre || ' ' || apellido AS nombre_completo,
    email,
    salario
FROM empleados
ORDER BY apellido, nombre
LIMIT 10;
-- 1.2 Funciones de fecha PostgreSQL
-- Obtiene información de fechas y antigüedad del empleado

SELECT 
    nombre || ' ' || apellido AS empleado,
    fecha_contratacion,
    EXTRACT(YEAR FROM fecha_contratacion) AS anio_contratacion,
    EXTRACT(MONTH FROM fecha_contratacion) AS mes_contratacion,
    TO_CHAR(fecha_contratacion, 'DD "de" TMMonth "de" YYYY') AS fecha_texto,
    AGE(CURRENT_DATE, fecha_contratacion) AS antiguedad
FROM empleados
ORDER BY fecha_contratacion
LIMIT 10;


-- 1.3 Sintaxis FETCH (estándar SQL)
-- Obtiene los 5 empleados con mayor salario

SELECT 
    nombre || ' ' || apellido AS empleado,
    salario
FROM empleados
ORDER BY salario DESC
FETCH FIRST 5 ROWS ONLY;


-- Ejercicio 2: RETURNING
-- 2.1 INSERT con RETURNING
-- Inserta un departamento y devuelve los datos insertados

INSERT INTO departamentos (nombre, ubicacion, presupuesto)
VALUES ('Logistica', 'Almacen Central', 180000)
RETURNING id, nombre, ubicacion, presupuesto, fecha_creacion;


-- 2.2 UPDATE con RETURNING
-- Actualiza el presupuesto y muestra valores nuevos y anteriores

UPDATE departamentos
SET presupuesto = presupuesto * 1.10
WHERE nombre = 'Logistica'
RETURNING 
    id,
    nombre,
    presupuesto AS nuevo_presupuesto,
    presupuesto / 1.10 AS presupuesto_anterior;


-- 2.3 DELETE con RETURNING
-- Elimina el departamento y devuelve sus datos

DELETE FROM departamentos
WHERE nombre = 'Logistica'
RETURNING id, nombre, presupuesto, 'ELIMINADO' AS estado;


-- Ejercicio 3: UPSERT con ON CONFLICT
-- 3.1 Insertar o actualizar producto

INSERT INTO productos (codigo, nombre, precio, stock, categoria_id)
VALUES ('NUEVO001', 'Producto Nuevo', 49.99, 100, 1)
ON CONFLICT (codigo) DO UPDATE
SET 
    precio = EXCLUDED.precio,
    stock = productos.stock + EXCLUDED.stock
RETURNING id, codigo, nombre, precio, stock, 'INSERTADO/ACTUALIZADO' AS operacion;


-- Segunda ejecución para provocar la actualización

INSERT INTO productos (codigo, nombre, precio, stock, categoria_id)
VALUES ('NUEVO001', 'Producto Nuevo Mejorado', 59.99, 50, 1)
ON CONFLICT (codigo) DO UPDATE
SET 
    precio = EXCLUDED.precio,
    stock = productos.stock + EXCLUDED.stock
RETURNING id, codigo, nombre, precio, stock, 'ACTUALIZADO' AS operacion;


-- 3.2 Insertar ignorando duplicados

INSERT INTO productos (codigo, nombre, precio, stock, categoria_id)
VALUES 
    ('ELEC001', 'Monitor Existente', 399.99, 10, 1),
    ('NUEVO002', 'Producto Nuevo 2', 29.99, 50, 2),
    ('INFO001', 'Laptop Existente', 1499.99, 5, 2)
ON CONFLICT (codigo) DO NOTHING
RETURNING id, codigo, nombre;


-- Limpieza de productos de prueba

DELETE FROM productos
WHERE codigo IN ('NUEVO001', 'NUEVO002');


-- Ejercicio 4: CTEs
-- 4.1 CTE simple
-- Calcula el salario medio por departamento

WITH salarios_medios AS (
    SELECT 
        departamento_id,
        AVG(salario) AS salario_medio
    FROM empleados
    GROUP BY departamento_id
)
SELECT 
    e.nombre || ' ' || e.apellido AS empleado,
    d.nombre AS departamento,
    e.salario,
    ROUND(sm.salario_medio::NUMERIC, 2) AS salario_medio_dept,
    ROUND((e.salario - sm.salario_medio)::NUMERIC, 2) AS diferencia
FROM empleados e
JOIN departamentos d ON e.departamento_id = d.id
JOIN salarios_medios sm ON e.departamento_id = sm.departamento_id
WHERE e.salario > sm.salario_medio
ORDER BY diferencia DESC;


-- 4.2 CTEs múltiples
-- Calcula métricas y ranking por departamento

WITH empleados_por_dept AS (
    SELECT 
        departamento_id,
        COUNT(*) AS num_empleados,
        SUM(salario) AS masa_salarial
    FROM empleados
    WHERE activo = true
    GROUP BY departamento_id
),
metricas AS (
    SELECT 
        d.id,
        d.nombre,
        d.presupuesto,
        COALESCE(e.num_empleados, 0) AS num_empleados,
        COALESCE(e.masa_salarial, 0) AS masa_salarial,
        CASE 
            WHEN COALESCE(e.num_empleados, 0) > 0
            THEN ROUND((d.presupuesto / e.num_empleados)::NUMERIC, 2)
            ELSE 0
        END AS presupuesto_por_empleado
    FROM departamentos d
    LEFT JOIN empleados_por_dept e ON d.id = e.departamento_id
)
SELECT 
    nombre AS departamento,
    num_empleados,
    presupuesto,
    masa_salarial,
    presupuesto_por_empleado,
    ROW_NUMBER() OVER (ORDER BY presupuesto_por_empleado DESC) AS ranking
FROM metricas
ORDER BY ranking;


-- Ejercicio 5: Window Functions
-- 5.2 Comparación con valores anteriores y siguientes

SELECT 
    d.nombre AS departamento,
    e.nombre || ' ' || e.apellido AS empleado,
    e.salario,
    LAG(e.salario) OVER w AS salario_anterior,
    LEAD(e.salario) OVER w AS salario_siguiente,
    e.salario - LAG(e.salario) OVER w AS diferencia_anterior
FROM empleados e
JOIN departamentos d ON e.departamento_id = d.id
WINDOW w AS (PARTITION BY d.id ORDER BY e.salario DESC)
ORDER BY d.nombre, e.salario DESC;


-- 5.3 Porcentajes y acumulados

SELECT 
    d.nombre AS departamento,
    e.nombre || ' ' || e.apellido AS empleado,
    e.salario,
    SUM(e.salario) OVER (PARTITION BY d.id) AS total_dept,
    ROUND(
        (e.salario * 100.0 / SUM(e.salario) OVER (PARTITION BY d.id))::NUMERIC,
        2
    ) AS porcentaje,
    SUM(e.salario) OVER (PARTITION BY d.id ORDER BY e.salario DESC) AS acumulado
FROM empleados e
JOIN departamentos d ON e.departamento_id = d.id
ORDER BY d.nombre, e.salario DESC;



--Ejercicios guiados
--Datos necesarios

CREATE TABLE if not exists resumen_departamentos (
    departamento_id INT,
    total_empleados INT,
    salario_medio NUMERIC
);
--1. Herramientas y sentencias DML
--DDL - CREATE crea la estructura
--DML - INSERT inserta datos
--DCL - GRANT controla permisos
--TCL - COMMIT controla transacciones
--DML - UPDATE actualiza datos
--2. Insert, Delete y Update
INSERT INTO departamentos (id, nombre, ubicacion, presupuesto)
VALUES
    (1, 'Recursos Humanos', 'Edificio A', 100000),
    (2, 'Ventas', 'Edificio B', 150000),
    (3, 'TI', 'Edificio C', 200000);
	
UPDATE empleados
SET salario = salario * 1.05
WHERE departamento_id = 2;
-- Primero verificar
SELECT * FROM empleados WHERE salario < 25000;

-- Luego eliminar
DELETE FROM empleados WHERE salario < 25000;

--3. Insert con select
CREATE TABLE empleados_backup AS
SELECT * FROM empleados
WHERE departamento_id = 1;

INSERT INTO resumen_departamentos (departamento_id, total_empleados, salario_medio)
SELECT 
    departamento_id,
    COUNT(*),
    AVG(salario)
FROM empleados
GROUP BY departamento_id;
CREATE TABLE empleados_exportar AS
SELECT 
    id,
    UPPER(nombre || ' ' || apellido) AS nombre_completo,
    salario * 12 AS salario_anual
FROM empleados;
