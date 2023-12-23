--IF EXISTS (

--SELECT name
--FROM sys.databases
--WHERE name = N'ServiceCenter'

--)

--DROP DATABASE ServiceCenter
--GO
--CREATE DATABASE ServiceCenter
--GO

---- tables creation 

-- ServiceCenter table
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
	addressID INT FOREIGN KEY REFERENCES Address(addressID)
);

CREATE TABLE Position
(
    positionID INT IDENTITY(1,1) PRIMARY KEY,
	positionName VARCHAR(55),
    salary DECIMAL(10, 2),
    experience INT
);

ALTER TABLE Position
ADD CONSTRAINT CHK_PositiveExperience
CHECK (experience >= 0); 

ALTER TABLE Position
ADD CONSTRAINT CHK_NonNegativeSalary
CHECK (salary >= 0); 


CREATE TABLE Worker
(
    workerID INT PRIMARY KEY,
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

-- MedCard table
CREATE TABLE MedCard (
    medCardID INT IDENTITY(1,1) PRIMARY KEY,
    bloodType VARCHAR(5) NOT NULL,
    Rh CHAR(1) NOT NULL,
    issueDate DATE NOT NULL, 
    validUntil AS DATEADD(YEAR, 8, issueDate) PERSISTED NOT NULL
);


-- Candidate table with FOREIGN KEY constraint
CREATE TABLE Candidate (
    TIN INT PRIMARY KEY,
    Surname VARCHAR(255) NOT NULL,
    Firstname VARCHAR(255) NOT NULL,
    dateOfBirth DATE NOT NULL,
    phoneNumber VARCHAR(15) NOT NULL,
    ownerID INT FOREIGN KEY REFERENCES MedCard(medCardID)
);

-- Exam table
CREATE TABLE Exam (
    examID INT IDENTITY(1,1) PRIMARY KEY,
    dateTime DATETIME NOT NULL,
    result VARCHAR(50) CHECK (result IN ('positive', 'negative')) NOT NULL, 
    examinerID INT NOT NULL,
    FOREIGN KEY (examinerID) REFERENCES Worker(workerID)
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
    technicalCondition VARCHAR(255) NOT NULL,
    model VARCHAR(50) NOT NULL,
    brand VARCHAR(50) NOT NULL,
    transmission VARCHAR(20) NOT NULL,
    instructorID INT, 
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


CREATE TABLE Voucher (
    voucherID INT IDENTITY(1,1) PRIMARY KEY,
    TIN INT, 
    datetimeOfReciving DATETIME NOT NULL,
    centerID INT, 
    payment DECIMAL(10, 2),
    fee DECIMAL(10, 2),
    terms VARCHAR(255),
	FOREIGN KEY (centerID) REFERENCES ServiceCenter(centerID),
	FOREIGN KEY (TIN) REFERENCES Candidate(TIN)
);

-- Add column to Exam table
ALTER TABLE Exam
ADD voucherID INT;

-- Add foreign key constraint on voucherID column
ALTER TABLE Exam
ADD CONSTRAINT FK_Exam_Voucher
FOREIGN KEY (voucherID) REFERENCES Voucher(voucherID);

-- Таблиця з теоретичними екзаменами
CREATE TABLE TheoreticalExam (
    theoreticalExamID INT IDENTITY(1,1) PRIMARY KEY,
    examID INT,
    CONSTRAINT FK_TheoreticalExam_Exam
        FOREIGN KEY (examID) REFERENCES Exam(examID)
);

-- Таблиця з запитаннями
CREATE TABLE Question (
    questionID INT IDENTITY(1,1) PRIMARY KEY,
    text NVARCHAR(MAX) NOT NULL
);

-- Таблиця з відповідями
CREATE TABLE Answer (
    answerID INT IDENTITY(1,1) PRIMARY KEY,
    questionID INT,
    text NVARCHAR(MAX) NOT NULL,
    isCorrect BIT, -- Флаг для визначення правильної відповіді
    CONSTRAINT FK_Answer_Question
        FOREIGN KEY (questionID) REFERENCES Question(questionID)
);

-- Таблиця, що встановлює зв'язок між теоретичним екзаменом та запитаннями
CREATE TABLE TheoreticalExam_Question (
    theoreticalExamID INT,
    questionID INT,
    PRIMARY KEY (theoreticalExamID, questionID),
    CONSTRAINT FK_TheoreticalExamQuestion_TheoreticalExam
        FOREIGN KEY (theoreticalExamID) REFERENCES TheoreticalExam(theoreticalExamID),
    CONSTRAINT FK_TheoreticalExamQuestion_Question
        FOREIGN KEY (questionID) REFERENCES Question(questionID)
);

CREATE TABLE DriversLicense (
    seriesAndNumber VARCHAR(20) PRIMARY KEY,
    validUntil DATE NOT NULL,
    issueDate DATE NOT NULL,
    ownerID INT,
    category VARCHAR(10) NOT NULL,
    CONSTRAINT FK_DriversLicense_Owner
        FOREIGN KEY (ownerID) REFERENCES Candidate(TIN)
);




