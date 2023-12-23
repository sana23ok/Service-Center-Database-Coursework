IF EXISTS (
	SELECT name
	FROM sys.databases
	WHERE name = N'MSVServiceCenter'
)

DROP DATABASE MSVServiceCenter

CREATE DATABASE MSVServiceCenter
-- tables creation 
CREATE TABLE Address (
    addressID INT IDENTITY(1,1) PRIMARY KEY,
    streetNumber VARCHAR(10) NOT NULL,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL
);

CREATE TABLE ServiceCenter (
    centerID INT IDENTITY(1,1) PRIMARY KEY,
    phoneNumber VARCHAR(15),
    email VARCHAR(255),
	addressID INT,
    FOREIGN KEY (addressID) REFERENCES Address(addressID)
);

CREATE TABLE Position (
    positionID INT IDENTITY(1,1) PRIMARY KEY,
	positionName VARCHAR(100),
    salary DECIMAL(10, 2) CHECK (salary >= 0),
    experience INT CHECK (experience >= 0)
);

-- Worker table
CREATE TABLE Worker(
    workerID INT IDENTITY(1,1) PRIMARY KEY,
    centerID INT, -- Nullable foreign key referencing the service center
    drivingSchool VARCHAR(255), -- Nullable, name of the driving school
    surname VARCHAR(255) NOT NULL,
    firstname VARCHAR(255) NOT NULL,
    positionID INT,
    phoneNumber VARCHAR(15),
    email VARCHAR(255),
    CONSTRAINT CHK_CenterOrDrivingSchool 
        CHECK (
            (centerID IS NOT NULL AND drivingSchool IS NULL) OR
            (centerID IS NULL AND drivingSchool IS NOT NULL)
        ),
    FOREIGN KEY (centerID) REFERENCES ServiceCenter(centerID),
    FOREIGN KEY (positionID) REFERENCES Position(positionID)
);

--drop table Address;
--drop table ServiceCenter;
--drop table Position;
--drop table Worker;

--select * from Address;
--select * from ServiceCenter;
--select * from Position;
--select * from Worker;

-- MedCard table
CREATE TABLE MedCard (
    medCardID INT IDENTITY(1,1) PRIMARY KEY,
    bloodType VARCHAR(2) NOT NULL,
    Rh CHAR(1) NOT NULL,
    issueDate DATE NOT NULL, 
    validUntil AS DATEADD(YEAR, 8, issueDate) PERSISTED NOT NULL
);

-- Candidate table with FOREIGN KEY constraint
CREATE TABLE Candidate (
    TIN INT PRIMARY KEY,
    surname VARCHAR(100) NOT NULL,
    firstname VARCHAR(100) NOT NULL,
    dateOfBirth DATE NOT NULL,
    phoneNumber VARCHAR(15) NOT NULL,
    ownerID INT FOREIGN KEY REFERENCES MedCard(medCardID)
);

CREATE TABLE Voucher (
    voucherID INT IDENTITY(1,1) PRIMARY KEY,
    TIN INT NOT NULL, 
    datetimeOfReciving DATETIME NOT NULL,
    centerID INT NOT NULL, 
    payment DECIMAL(10, 2),
    fee DECIMAL(10, 2),
    terms VARCHAR(255),
	FOREIGN KEY (centerID) REFERENCES ServiceCenter(centerID),
	FOREIGN KEY (TIN) REFERENCES Candidate(TIN)
);

-- Exam table
CREATE TABLE Exam (
    examID INT IDENTITY(1,1) PRIMARY KEY,
    datetimeOfExam DATETIME NOT NULL,
    result VARCHAR(50) CHECK (result IN ('positive', 'negative')) NOT NULL, 
    examinerID INT NOT NULL,
	voucherID INT NOT NULL,
    FOREIGN KEY (examinerID) REFERENCES Worker(workerID),
	FOREIGN KEY (voucherID) REFERENCES Voucher(voucherID)
);

-- PracticalExam table
CREATE TABLE PracticalExam (
    practicalExamID INT IDENTITY(1,1) PRIMARY KEY,
    examRoute VARCHAR(255) NOT NULL,
    examID INT,
    FOREIGN KEY (examID) REFERENCES Exam(examID)
);

-- TransportVehicle table
CREATE TABLE TransportVehicle (
    registrationPlate VARCHAR(15) PRIMARY KEY,
    technicalCondition VARCHAR(255),
    model VARCHAR(50) NOT NULL,
    brand VARCHAR(50) NOT NULL,
    transmission VARCHAR(20) NOT NULL,
    instructorID INT NOT NULL, 
    FOREIGN KEY (instructorID) REFERENCES Worker(workerID)
);

-- Linking table for the many-to-many relationship
CREATE TABLE PracticalExam_TransportVehicle (
    practicalExamID INT NOT NULL,
    registrationPlate VARCHAR(15) NOT NULL,
    PRIMARY KEY (practicalExamID, registrationPlate),
    FOREIGN KEY (practicalExamID) REFERENCES PracticalExam(practicalExamID),
    FOREIGN KEY (registrationPlate) REFERENCES TransportVehicle(registrationPlate)
);

CREATE TABLE DriversLicense (
    seriesAndNumber VARCHAR(20) PRIMARY KEY,
    validityPeriod INT NOT NULL, 
    issueDate DATE NOT NULL,
    ownerID INT NOT NULL,
    category VARCHAR(10) NOT NULL,
    validUntil AS 
        CASE 
            WHEN validityPeriod = 10 THEN DATEADD(YEAR, 10, issueDate)
            ELSE DATEADD(YEAR, 2, issueDate)
        END,
    CONSTRAINT FK_DriversLicense_Owner
        FOREIGN KEY (ownerID) REFERENCES Candidate(TIN)
);

-- Таблиця з теоретичними екзаменами
CREATE TABLE TheoreticalExam (
    theoreticalExamID INT IDENTITY(1,1) PRIMARY KEY,
    examID INT,
	duration INT CHECK (duration >= 0 and duration <= 20),
	score INT CHECK (score >= 0 and score <= 20)
    FOREIGN KEY (examID) REFERENCES Exam(examID)
);

-- Таблиця з запитаннями
CREATE TABLE Question (
    questionID INT IDENTITY(1,1) PRIMARY KEY,
    text VARCHAR(500) NOT NULL
);

-- Таблиця з відповідями
CREATE TABLE Answer (
    answerID INT IDENTITY(1,1) PRIMARY KEY,
    questionID INT,
    text NVARCHAR(MAX) NOT NULL,
    isCorrect BIT, -- Флаг для визначення правильної відповіді
    FOREIGN KEY (questionID) REFERENCES Question(questionID)
);

-- Таблиця для зв'язку теоретичного екзамену із запитаннями
CREATE TABLE TheoreticalExam_Question (
    theoreticalExamID INT,
    questionID INT,
    PRIMARY KEY (theoreticalExamID, questionID),
    FOREIGN KEY (theoreticalExamID) REFERENCES TheoreticalExam(theoreticalExamID),
	FOREIGN KEY (questionID) REFERENCES Question(questionID)
);

-- Таблиця для зберігання відповідей клієнта на теоретичний екзамен
CREATE TABLE ClientAnswer (
    clientAnswerID INT IDENTITY(1,1) PRIMARY KEY,
    theoreticalExamID INT,
    questionID INT,
    answerID INT,
    FOREIGN KEY (theoreticalExamID) REFERENCES TheoreticalExam(theoreticalExamID),
    FOREIGN KEY (questionID) REFERENCES Question(questionID),
    FOREIGN KEY (answerID) REFERENCES Answer(answerID)
);


-- Додаємо 10 адрес у таблицю Address
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

select * from Address;

-- Додаємо 10 записів у таблицю ServiceCenter
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
