use MSVServiceCenter;

INSERT INTO Address (streetNumber, street, city, region) 
VALUES 
    (1, 'вул. Шевченка', 'Київ', 'Київська область'),
    (5, 'вул. Лесі Українки', 'Харків', 'Харківська область'),
    (23, 'просп. Свободи', 'Львів', 'Львівська область'),
    (12, 'вул. Івана Франка', 'Одеса', 'Одеська область'),
    (58,'вул. Шевченка', 'Дніпро', 'Дніпропетровська область'),
    (124, 'вул. Шевченка', 'Стрий', 'Львівська область'),
    (478, 'вул. Лісова', 'Запоріжжя', 'Запорізька область'),
    (14, 'вул. Пушкінська', 'Київ', 'Київська область'),
    (25, 'пр. Перемоги', 'Харків', 'Харківська область'),
    (7, 'вул. Космонавтів', 'Одеса', 'Одеська область');


INSERT INTO ServiceCenter (phoneNumber, email, addressID)
VALUES 
    ('234-567-8901', 'serviceKharkiv@example.com', 2),
    ('345-678-9012', 'serviceLviv@example.com', 3),
    ('456-789-0123', 'serviceOdessa@example.com', 4),
    ('567-890-1234', 'serviceDnipro@example.com', 5),
    ('678-901-2345', 'serviceStryi@example.com', 6),
    ('789-012-3456', 'service7@example.com', 7),
    ('890-123-4567', 'service8@example.com', 8),
    ('901-234-5678', 'service9@example.com', 9),
    ('012-345-6789', 'service10@example.com', 10);

INSERT INTO Position (positionName, salary, experience)
VALUES 
    ('Examiner', 22000.00, 1),
    ('Technical Support Specialist', 32000.00, 2),
    ('Accountant', 15000.00, 8),
    ('Financial Analyst', 34000.00, 14),
    ('Chief Examiner', 45000.00, 17),
    ('Chief Accountant', 22000.00, 8),
    ('General Manager', 150000.00, 15),
    ('System Administrator', 65000.00, 4),
    ('Instructor', 35000.00, 13),
    ('Network Support Technician', 42000.00, 2),
	('Secretary', 40000.00, 2);

select * from Position; -- 1 - 11
select * from ServiceCenter; -- 3 - 11

INSERT INTO Worker (centerID, drivingSchool, surname, firstname, positionID, phoneNumber, email)
VALUES 
    (3, NULL, 'Ivanov', 'Oleksandr', 1, '+380951234567', 'oleksandr.ivanov@example.com'),
    (3, NULL, 'Petrenko', 'Yulia', 2, '+380952345678', 'yulia.petrenko@example.com'),
    (3, NULL, 'Koval', 'Maxim', 3, '+380953456789', 'maxim.koval@example.com'),
    (NULL, 'Pilot', 'Sydorenko', 'Anna', 9, '+380954567890', 'anna.sydorenko@example.com'),
    (4, NULL, 'Pavlenko', 'Oleg', 5, '+380955678901', 'oleg.pavlenko@example.com'),
    (4, NULL, 'Sergienko', 'Irina', 6, '+380956789012', 'irina.sergienko@example.com'),
    (NULL, 'Safe Academy', 'Martynenko', 'Vitaliy', 9, '+380957890123', 'vitaliy.martynenko@example.com'),
    (6, NULL, 'Tkachenko', 'Darina', 8, '+380958901234', 'darina.tkachenko@example.com'),
    (7, NULL, 'Romanova', 'Vladyslava', 9, '+380959012345', 'vlada.romanova@example.com'),
    (NULL, 'Safe Academy', 'Kovalenko', 'Irina', 9, '+380951112233', 'irina.kovalenko@example.com'),
    (8, NULL, 'Karpenko', 'Vasyl', 11, '+380951234567', 'vasyl.karpenko@example.com');


select * from Worker;

INSERT INTO MedCard (bloodType, Rh, issueDate)
VALUES 
    ('A', '+', '2022-01-01'),
    ('B', '-', '2022-02-15'),
    ('O', '+', '2022-03-30'),
    ('AB', '-', '2022-04-10'),
    ('A', '+', '2022-05-20'),
    ('B', '-', '2022-06-05'),
    ('O', '+', '2022-07-15'),
    ('AB', '-', '2022-08-25'),
    ('A', '+', '2022-09-10'),
    ('B', '-', '2022-10-22'),
    ('O', '+', '2022-11-05'),
    ('AB', '-', '2022-12-12'),
    ('A', '+', '2023-01-20'),
    ('B', '-', '2023-02-28'),
    ('O', '+', '2023-03-15');

select * from MedCard; -- 1 - 15

-- 10-digit
INSERT INTO Candidate (TIN, surname, firstname, dateOfBirth, phoneNumber, ownerID)
VALUES 
    (123456, 'Poliakova', 'Ludmula', '1990-05-15', '+380951234567', 1),
    (234567, 'Prohorova', 'Karina', '1988-12-03', '+380952345678', 2),
    (345678, 'Koval', 'Oleksii', '1995-08-22', '+380953456789', 3),
    (456789, 'Malynovska', 'Arina', '1992-04-10', '+380954567890', 4),
    (567890, 'Pavlova', 'Inna', '1987-11-28', '+380955678901', 5),
    (678901, 'Komarov', 'Dmytro', '1993-09-18', '+380956789012', 6),
    (789012, 'Chala', 'Lilia', '1989-07-07', '+380957890123', 7),
    (890123, 'Tkach', 'Diana', '1991-01-25', '+380958901234', 8),
    (901234, 'Kononenko', 'Volodymyr', '1994-06-12', '+380959012345', 9),
    (112233, 'Dmytrushyn', 'Iryna', '1996-03-30', '+380951112233', 10),
    (223344, 'Avramov', 'Vasyl', '1985-10-08', '+380951234567', 11),
    (334455, 'Ivanova', 'Nataliia', '1997-02-14', '+380951345678', 12),
    (445566, 'Sokolov', 'Artem', '1986-09-02', '+380951456789', 13),
    (556677, 'Kovalenko', 'Khrystyna', '1998-11-19', '+380951567890', 14),
    (667788, 'Melnik', 'Mykhailo', '1984-07-26', '+380951678901', 15);


