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

INSERT INTO Candidate (TIN, surname, firstname, dateOfBirth, phoneNumber, ownerID)
VALUES 
    (1234563456, 'Poliakova', 'Ludmula', '1990-05-15', '+380951234567', 1),
    (2345672525, 'Prohorova', 'Karina', '1988-12-03', '+380952345678', 2),
    (3456780202, 'Koval', 'Oleksii', '1995-08-22', '+380953456789', 3),
    (4567891111, 'Malynovska', 'Arina', '1992-04-10', '+380954567890', 4),
    (5678111190, 'Pavlova', 'Inna', '1987-11-28', '+380955678901', 5),
    (6111178901, 'Komarov', 'Dmytro', '1993-09-18', '+380956789012', 6),
    (7890111112, 'Chala', 'Lilia', '1989-07-07', '+380957890123', 7),
    (8911110123, 'Tkach', 'Diana', '1991-01-25', '+380958901234', 8),
    (9012311114, 'Kononenko', 'Volodymyr', '1994-06-12', '+380959012345', 9),
    (1121111233, 'Dmytrushyn', 'Iryna', '1996-03-30', '+380951112233', 10),
    (0111223344, 'Avramov', 'Vasyl', '1985-10-08', '+380951234567', 11),
    (3111134455, 'Ivanova', 'Nataliia', '1997-02-14', '+380951345678', 12),
    (0011445566, 'Sokolov', 'Artem', '1986-09-02', '+380951456789', 13),
    (0012556677, 'Kovalenko', 'Khrystyna', '1998-11-19', '+380951567890', 14),
    (0012667788, 'Melnik', 'Mykhailo', '1984-07-26', '+380951678901', 15);

select * from Position; -- 1 - 11
select * from ServiceCenter; -- 3 - 11
select * from Worker;
select * from MedCard; -- 1 - 15
select * from Candidate; -- 1 - 15


-- Generate 15 vouchers using TIN from the Candidate table
INSERT INTO Voucher (TIN, datetimeOfReciving, centerID, payment, fee, terms)
VALUES 
    (1234563456, GETDATE(), 3, 13, 20, 'Standard terms'),
    (2345672525, GETDATE(), 3, 13, 20, 'Standard terms'),
    (3456780202, GETDATE(), 3, 13, 20, 'Standard terms'),
    (4567891111, GETDATE(), 3, 13, 20, 'Standard terms'),
    (5678111190, GETDATE(), 4, 33, 800, 'Standard terms'),
    (6111178901, GETDATE(), 4, 33, 800, 'Standard terms'),
    (7890111112, GETDATE(), 4, 33, 300, 'Standard terms'),
    (8911110123, GETDATE(), 5, 33, 800, 'Standard terms'),
    (9012311114, GETDATE(), 6, 33, 800, 'Standard terms'),
    (1121111233, GETDATE(), 6, 33, 800, 'Standard terms'),
    (0011445566, '2023-04-10', 6, 13, 20, 'Standard terms'),
    (0011445566, '2023-05-12', 6, 13, 20, 'Standard terms'),
    (0011445566, GETDATE(), 7, 13, 20, 'Standard terms'),
    (0012556677, GETDATE(), 7, 13, 20, 'Standard terms'),
    (0012667788, GETDATE(), 7, 33, 300, 'Standard terms');


select * from Voucher;

DECLARE @latestDatetimeOfReciving DATETIME;
SELECT @latestDatetimeOfReciving = MAX(datetimeOfReciving) FROM Voucher;

INSERT INTO Exam (datetimeOfExam, result, examinerID, voucherID)
VALUES 
    (DATEADD(DAY, 1, @latestDatetimeOfReciving), 'positive', 1, 1),
    (DATEADD(DAY, 2, @latestDatetimeOfReciving), 'negative', 1, 2),
    (DATEADD(DAY, 3, @latestDatetimeOfReciving), 'positive', 1, 3),
    (DATEADD(DAY, 4, @latestDatetimeOfReciving), 'negative', 1, 4),
    (DATEADD(DAY, 5, @latestDatetimeOfReciving), 'positive', 1, 5),
    (DATEADD(DAY, 6, @latestDatetimeOfReciving), 'negative', 1, 6),
    (DATEADD(DAY, 7, @latestDatetimeOfReciving), 'positive', 9, 7),
    (DATEADD(DAY, 8, @latestDatetimeOfReciving), 'negative', 9, 8),
    (DATEADD(DAY, 9, @latestDatetimeOfReciving), 'positive', 9, 9),
    (DATEADD(DAY, 10, @latestDatetimeOfReciving), 'negative', 9, 10),
    (DATEADD(DAY, 11, @latestDatetimeOfReciving), 'positive', 9, 11),
    (DATEADD(DAY, 12, @latestDatetimeOfReciving), 'negative', 9, 12),
    (DATEADD(DAY, 13, @latestDatetimeOfReciving), 'positive', 9, 13),
    (DATEADD(DAY, 14, @latestDatetimeOfReciving), 'negative', 1, 14),
    (DATEADD(DAY, 15, @latestDatetimeOfReciving), 'positive', 1, 15);

select * from Exam;

INSERT INTO PracticalExam (examRoute, examID)
VALUES 
    ('Route 3', 17),
    ('Route 3', 18),
    ('Route 3', 19),
    ('Route 5', 20),
    ('Route 5', 21),
    ('Route 1', 22),
    ('Route 2', 27);

select * from PracticalExam;

INSERT INTO TransportVehicle (registrationPlate, technicalCondition, model, brand, 
transmission, instructorID)
VALUES 
    ('ABC123', 'Good', 'Sedan', 'Toyota', 'Automatic', 4),
    ('XYZ456', 'Excellent', 'SUV', 'Ford', 'Manual', 7),
    ('LMN789', 'Fair', 'Hatchback', 'Honda', 'Automatic', 8),
    ('PQR012', 'Good', 'Truck', 'Chevrolet', 'Manual', 9);

select * from TransportVehicle;

-- Insert data into Question table
INSERT INTO Question (text)
VALUES 
    ('What is the speed limit on highways?'),
    ('What does a yellow traffic light indicate?'),
    ('What is the meaning of a stop sign?'),
    ('When should you use your headlights?'),
    ('What is the legal blood alcohol concentration limit?');


select * from Question;

INSERT INTO Answer (questionID, [text], isCorrect)
VALUES 
    (1, '60 mph', 0),
    (1, '70 mph', 0),
    (1, '55 mph', 1),
    (2, 'Slow down', 1),
    (2, 'Speed up', 0),
    (2, 'Stop', 0),
    (3, 'Proceed with caution', 0),
    (3, 'Stop completely', 1),
    (3, 'Prepare to turn', 0),
    (4, 'Only at night', 0),
    (4, 'In fog or rain', 1),
    (4, 'On private property', 0),
    (5, '0.05%', 0),
    (5, '0.08%', 1),
    (5, '0.10%', 0);

select * from Answer;

INSERT INTO TheoreticalExam (examID, duration, score)
VALUES 
    (13, 15, 18),
    (14, 20, 16),
    (15, 18, 20);

select * from TheoreticalExam;

INSERT INTO TheoreticalExam_Question (theoreticalExamID, questionID)
VALUES 
    (1, 1),
    (1, 2),
    (1, 3),
    (2, 4),
    (2, 5),
    (3, 1),
    (3, 3),
    (3, 5);

select * from TheoreticalExam_Question;

INSERT INTO PracticalExam_TransportVehicle (practicalExamID, registrationPlate)
VALUES 
    (6, 'XYZ456'),
    (2, 'LMN789'),
    (3, 'PQR012');

select * from PracticalExam_TransportVehicle ;


INSERT INTO ClientAnswer (theoreticalExamID, answerID)
VALUES 
    (1, 3),
    (1, 2),
    (2, 4),
    (2, 5),
    (3, 1),
    (3, 3);

select * from ClientAnswer;

-- positively completed 
SELECT DISTINCT C.TIN, C.surname, C.firstname
FROM Candidate C
JOIN Voucher V ON C.TIN = V.TIN
JOIN Exam E ON V.voucherID = E.voucherID
JOIN PracticalExam P ON E.examID = P.examID
WHERE E.result = 'positive';

INSERT INTO DriversLicense (seriesAndNumber, validityPeriod, issueDate, ownerID, category)
SELECT 
    CONCAT('DL', ROW_NUMBER() OVER (ORDER BY C.TIN)) AS seriesAndNumber,
    CASE WHEN E.result = 'positive' THEN 2 ELSE 10 END AS validityPeriod,
    GETDATE() AS issueDate,
    C.TIN AS ownerID,
    'B' AS category
FROM Candidate C
JOIN Voucher V ON C.TIN = V.TIN
JOIN Exam E ON V.voucherID = E.voucherID
JOIN PracticalExam P ON E.examID = P.examID
WHERE E.result = 'positive';

select * from DriversLicense;

--ALTER TABLE Voucher
--ADD examDateTime DATETIME;

--ALTER TABLE Voucher
--ADD ServiceType VARCHAR(20) CHECK (ServiceType IN ('theoretical exam', 
--													'practical exam', 
--													'licence reciving'));

select * from Voucher;

EXEC sp_columns 'Voucher';


-- Generate 15 vouchers using TIN from the Candidate table
INSERT INTO Voucher (TIN, datetimeOfReciving, centerID, payment, fee, terms, examDateTime, ServiceType)
VALUES     
    (17, '2023-12-20', 9, 33, 300, 'Financial Agreement', DATEADD(DAY, 1, '2023-12-20'), 'practical exam'),
    (18, '2023-12-20', 1, 33, 300, 'Standard terms', DATEADD(DAY, 1, '2023-12-20'), 'licence reciving'),
    (19, '2023-12-20', 2, 13, 33, 'Financial Agreement', DATEADD(DAY, 1, '2023-12-20'), 'theoretical exam'),
    (20, GETDATE(), 3, 33, 300, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'practical exam'),
    (21, '2023-12-20', 4, 33, 800, 'Standard terms', DATEADD(DAY, 1, '2023-12-20'), 'licence reciving'),
    (22, GETDATE(), 5, 13, 33, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'theoretical exam'),
    (23, GETDATE(), 6, 33, 800, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'practical exam'),
    (24, '2023-12-20', 7, 33, 300, 'Standard terms', DATEADD(DAY, 1, '2023-12-20'), 'licence reciving'),
    (26, '2023-12-20', 8, 13, 33, 'Standard terms', DATEADD(DAY, 1, '2023-12-20'), 'theoretical exam'),
    (27, GETDATE(), 9, 33, 300, 'Financial Agreement', DATEADD(DAY, 1, GETDATE()), 'practical exam'),
    (28, GETDATE(), 1, 33, 300, 'Financial Agreement', DATEADD(DAY, 1, GETDATE()), 'licence reciving'),
    (31, GETDATE(), 1, 13, 33, 'Financial Agreement', DATEADD(DAY, 1, GETDATE()), 'theoretical exam'),
    (33, GETDATE(), 3, 33, 300, 'Financial Agreement', DATEADD(DAY, 1, GETDATE()), 'practical exam'),
    (34, '2023-12-22', 4, 33, 800, 'Standard terms', DATEADD(DAY, 1, '2023-12-22'), 'licence reciving'),
    (35, '2023-12-22', 5, 13, 33, 'Standard terms', DATEADD(DAY, 1, '2023-12-22'), 'theoretical exam'),
    (37, '2023-12-22', 4, 33, 800, 'Standard terms', DATEADD(DAY, 1, '2023-12-22'), 'practical exam'),
    (39, '2023-12-22', 7, 33, 300, 'Standard terms', DATEADD(DAY, 1, '2023-12-22'), 'licence reciving'),
    (41, GETDATE(), 8, 13, 33, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'theoretical exam'),
    (42, GETDATE(), 4, 33, 300, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'practical exam'),
    (46, '2023-12-22', 4, 33, 300, 'Standard terms', DATEADD(DAY, 1, '2023-12-22'), 'licence reciving'),
    (47, GETDATE(), 4, 33, 300, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'theoretical exam'),
    (48, GETDATE(), 3, 33, 300, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'practical exam'),
    (50, GETDATE(), 4, 33, 300, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'licence reciving'),
    (52, GETDATE(), 5, 33, 800, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'theoretical exam'),
    (54, GETDATE(), 6, 33, 800, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'practical exam'),
    (55, GETDATE(), 7, 33, 300, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'licence reciving'),
    (56, '2023-12-22', 8, 13, 33, 'Standard terms', DATEADD(DAY, 1, '2023-12-22'), 'theoretical exam'),
    (57, GETDATE(), 9, 33, 300, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'practical exam'),
    (59, '2023-12-22', 9, 33, 300, 'Standard terms', DATEADD(DAY, 1, '2023-12-22'), 'licence reciving'),
    (60, GETDATE(), 4, 13, 33, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'theoretical exam'),
    (61, GETDATE(), 4, 33, 300, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'practical exam'),
    (63, GETDATE(), 4, 33, 800, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'licence reciving'),
    (64, GETDATE(), 5, 13, 33, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'theoretical exam'),
    (66, GETDATE(), 6, 33, 800, 'Standard terms', DATEADD(DAY, 1, GETDATE()), 'practical exam');


select * from ServiceCenter;
select * from Voucher;

CREATE OR ALTER PROCEDURE FillExamsFromVoucher
AS
BEGIN
    -- Заповнення таблиці Exam
    INSERT INTO Exam (datetimeOfExam, result, examinerID, voucherID)
    SELECT 
        V.datetimeOfReciving,
        NULL, -- За замовчуванням результат не визначений
        NULL, -- За замовчуванням екзаменатор не визначений
        V.voucherID
    FROM Voucher V
    WHERE V.examDateTime IS NOT NULL;

    -- Заповнення таблиць PracticalExam та TheoreticalExam
    INSERT INTO PracticalExam (examRoute, examID)
    SELECT 
        CASE 
            WHEN V.ServiceType = 'practical exam' THEN ABS(CHECKSUM(NEWID())) % 10 + 1
            ELSE NULL
        END,
        E.examID
    FROM Exam E
    JOIN Voucher V ON V.voucherID = E.voucherID
    WHERE V.ServiceType = 'practical exam';

    INSERT INTO TheoreticalExam (duration, score, examID)
    SELECT 
        NULL, -- За замовчуванням тривалість та бали не визначені
        NULL,
        E.examID
    FROM Exam E
    JOIN Voucher V ON V.voucherID = E.voucherID
    WHERE V.ServiceType = 'theoretical exam';
END;

EXEC FillExamsFromVoucher;

select * from PracticalExam;
select * from TheoreticalExam;

