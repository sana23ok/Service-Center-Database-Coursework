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

exec sp_columns 'Address';

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

-- MedCard table
CREATE TABLE MedCard (
    medCardID INT IDENTITY(1,1) PRIMARY KEY,
    bloodType VARCHAR(2) NOT NULL,
    Rh CHAR(1) NOT NULL,
    issueDate DATE NOT NULL, 
    validUntil AS DATEADD(YEAR, 8, issueDate) PERSISTED NOT NULL,
	UNIQUE (medCardID)
);

-- Candidate table with FOREIGN KEY constraint
CREATE TABLE Candidate (
    TIN BIGINT PRIMARY KEY,
    surname VARCHAR(100) NOT NULL,
    firstname VARCHAR(100) NOT NULL,
    dateOfBirth DATE NOT NULL,
    phoneNumber VARCHAR(15) NOT NULL,
    ownerID INT FOREIGN KEY REFERENCES MedCard(medCardID),
	UNIQUE (TIN)
);

CREATE TABLE Voucher (
    voucherID INT IDENTITY(1,1) PRIMARY KEY,
    TIN BIGINT NOT NULL, 
    datetimeOfReciving DATETIME NOT NULL,
    centerID INT NOT NULL, 
    payment DECIMAL(10, 2),
    fee DECIMAL(10, 2),
    terms VARCHAR(255),
	FOREIGN KEY (centerID) REFERENCES ServiceCenter(centerID),
	FOREIGN KEY (TIN) REFERENCES Candidate(TIN)
);

ALTER TABLE Voucher
ADD examDateTime DATETIME;

ALTER TABLE Voucher
ADD ServiceType VARCHAR(20) CHECK (ServiceType IN 
('theoretical exam', 'practical exam', 'licence reciving'));

ALTER TABLE Voucher
ADD CONSTRAINT CHK_ExamDateTime
CHECK (datetimeOfReciving < examDateTime);

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


ALTER TABLE Exam
ALTER COLUMN datetimeOfExam DATETIME NULL;

ALTER TABLE Exam
ALTER COLUMN examinerID int NULL;

ALTER TABLE Exam
ALTER COLUMN result varchar(20) NULL;

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
    FOREIGN KEY (instructorID) REFERENCES Worker(workerID),
	UNIQUE (registrationPlate)
);

CREATE TABLE DriversLicense (
    seriesAndNumber VARCHAR(20) PRIMARY KEY,
    validityPeriod INT NOT NULL, 
    issueDate DATE NOT NULL,
    ownerID BIGINT NOT NULL,
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

CREATE TABLE Question(
    questionID INT IDENTITY(1,1) PRIMARY KEY,
    text VARCHAR(500) NOT NULL, 
	correctAnswer VARCHAR(20) NOT NULL
)

CREATE TABLE Answer(
	answerID INT IDENTITY(1,1) PRIMARY KEY,
	candidateAnswer VARCHAR(20),
	questionID INT NOT NULL, 
	theoreticalExamID INT NOT NULL
	FOREIGN KEY (questionID) REFERENCES Question(questionID), 
	FOREIGN KEY (theoreticalExamID) REFERENCES TheoreticalExam(theoreticalExamID)
)

CREATE TABLE PossibleAnswers (
    possibleAnswerID INT IDENTITY(1,1) PRIMARY KEY,
    letter CHAR,
    text VARCHAR(500),
    questionID INT,
    FOREIGN KEY (questionID) REFERENCES Question(questionID) ON DELETE CASCADE
);

-- Linking table for the many-to-many relationship
CREATE TABLE PracticalExam_TransportVehicle (
    practicalExamID INT NOT NULL,
    registrationPlate VARCHAR(15) NOT NULL,
    PRIMARY KEY (practicalExamID, registrationPlate),
    FOREIGN KEY (practicalExamID) REFERENCES PracticalExam(practicalExamID),
    FOREIGN KEY (registrationPlate) REFERENCES TransportVehicle(registrationPlate)
);

-- Таблиця для зв'язку теоретичного екзамену із запитаннями
CREATE TABLE TheoreticalExam_Question (
    theoreticalExamID INT,
    questionID INT,
    PRIMARY KEY (theoreticalExamID, questionID),
    FOREIGN KEY (theoreticalExamID) REFERENCES TheoreticalExam(theoreticalExamID),
	FOREIGN KEY (questionID) REFERENCES Question(questionID)
);

-- Add ON DELETE CASCADE to existing foreign keys
ALTER TABLE ServiceCenter
ADD CONSTRAINT FK_ServiceCenter_Address
FOREIGN KEY (addressID) REFERENCES Address(addressID) ON DELETE CASCADE;

ALTER TABLE Worker
ADD CONSTRAINT FK_Worker_ServiceCenter
FOREIGN KEY (centerID) REFERENCES ServiceCenter(centerID) ON DELETE CASCADE;

ALTER TABLE Worker
ADD CONSTRAINT FK_Worker_Position
FOREIGN KEY (positionID) REFERENCES Position(positionID) ON DELETE CASCADE;

ALTER TABLE Candidate
ADD CONSTRAINT FK_Candidate_MedCard
FOREIGN KEY (ownerID) REFERENCES MedCard(medCardID) ON DELETE CASCADE;

ALTER TABLE Voucher
ADD CONSTRAINT FK_Voucher_ServiceCenter
FOREIGN KEY (centerID) REFERENCES ServiceCenter(centerID) ON DELETE CASCADE;

ALTER TABLE Voucher
ADD CONSTRAINT FK_Voucher_Candidate
FOREIGN KEY (TIN) REFERENCES Candidate(TIN) ON DELETE CASCADE;

ALTER TABLE Exam
ADD CONSTRAINT FK_Exam_Worker
FOREIGN KEY (examinerID) REFERENCES Worker(workerID) ON DELETE CASCADE;

-------
ALTER TABLE Exam
ADD CONSTRAINT FK_Exam_Voucher
FOREIGN KEY (voucherID) REFERENCES Voucher(voucherID) ON DELETE CASCADE;
-------


ALTER TABLE PracticalExam
ADD CONSTRAINT FK_PracticalExam_Exam
FOREIGN KEY (examID) REFERENCES Exam(examID) ON DELETE CASCADE;

ALTER TABLE TransportVehicle
ADD CONSTRAINT FK_TransportVehicle_Worker
FOREIGN KEY (instructorID) REFERENCES Worker(workerID) ON DELETE CASCADE;

ALTER TABLE DriversLicense
ADD CONSTRAINT FK_DriversLicense_Candidate
FOREIGN KEY (ownerID) REFERENCES Candidate(TIN) ON DELETE CASCADE;

ALTER TABLE PracticalExam_TransportVehicle
ADD CONSTRAINT FK_PE_TV_PracticalExam
FOREIGN KEY (practicalExamID) REFERENCES PracticalExam(practicalExamID) ON DELETE CASCADE;

----
ALTER TABLE PracticalExam_TransportVehicle
DROP FOREIGN KEY /* CONSTRAINT FK_PE_TV_TransportVehicle */;

-- Add the foreign key constraint with ON DELETE NO ACTION
ALTER TABLE PracticalExam_TransportVehicle
ADD CONSTRAINT FK_PE_TV_TransportVehicle
FOREIGN KEY (registrationPlate) REFERENCES TransportVehicle(registrationPlate)
ON DELETE NO ACTION;

exec sp_columns 'PracticalExam_TransportVehicle';
-----

ALTER TABLE TheoreticalExam
ADD CONSTRAINT FK_TheoreticalExam_Exam
FOREIGN KEY (examID) REFERENCES Exam(examID) ON DELETE CASCADE;

ALTER TABLE Answer
ADD CONSTRAINT FK_Answer_Question
FOREIGN KEY (questionID) REFERENCES Question(questionID) ON DELETE CASCADE;

ALTER TABLE Answer
ADD CONSTRAINT FK_Answer_TheoreticalExam
FOREIGN KEY (theoreticalExamID) REFERENCES TheoreticalExam(theoreticalExamID) ON DELETE CASCADE;

----
ALTER TABLE PossibleAnswers
ADD CONSTRAINT FK_PossibleAnswers_Question
FOREIGN KEY (questionID) REFERENCES Question(questionID) ON DELETE CASCADE;
----

ALTER TABLE TheoreticalExam_Question
ADD CONSTRAINT FK_TE_Question
FOREIGN KEY (theoreticalExamID) REFERENCES TheoreticalExam(theoreticalExamID) ON DELETE CASCADE;

ALTER TABLE TheoreticalExam_Question
ADD CONSTRAINT FK_TEQ_Question
FOREIGN KEY (questionID) REFERENCES Question(questionID) ON DELETE CASCADE;