	CREATE DATABASE IF NOT EXISTS empleados;
    USE empleados;
    CREATE TABLE empleados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    genero ENUM('M','F','Otro') NOT NULL,
    habilidades SET('JAVA','PYTHON','HTML','CSS','SQL') NOT NULL,
    salario INT
    );
    
    Insert into empleados (nombre, genero, habilidades, salario)
    values
    ('Ana López', 'F', 'JAVA,SQL', 25000),
    ('Carlos Pérez', 'M', 'HTML,CSS', 23000),
    ('Lucía Ortega', 'F', 'JAVA,PYTHON,SQL', 28000),
    ('Andrés Martín', 'M', 'PYTHON', 22000),
    ('María Ruiz', 'F', 'JAVA,HTML,CSS', 24000);
    
    insert into empleados
    set nombre = 'Pedro Gómez',
    genero = 'M',
	habilidades = 'Java,Python,CSS',
    salario = 26000;
    select * FROM empleados;
    
    select nombre, habilidades FROM empleados;
    
    SELECT * FROM empleados Where find_in_set ('python', habilidades);
        
    SELECT * FROM empleados Where habilidades like '%,%';
    
    SELECT COUNT(*) AS total_con_java FROM empleados Where find_in_set ('Java', habilidades);
    
    