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

---- ServiceCenter table
--CREATE TABLE Address (
--    addressID INT IDENTITY(1,1) PRIMARY KEY,
--    streetNumber VARCHAR(10) NOT NULL,
--    street VARCHAR(255) NOT NULL,
--    city VARCHAR(100) NOT NULL,
--    region VARCHAR(100) NOT NULL
--);

--CREATE TABLE ServiceCenter (
--    centerID INT IDENTITY(1,1) PRIMARY KEY,
--    phoneNumber VARCHAR(15),
--    email VARCHAR(255),
--	addressID INT FOREIGN KEY REFERENCES Address(addressID)
--);

CREATE TABLE Position
(
    positionID INT IDENTITY(1,1) PRIMARY KEY,
	positionName VARCHAR(55),
    salary DECIMAL(10, 2),
    experience INT
);

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

-- Trigger to check that examinerID in Exam != instructorID in TransportVehicle
CREATE TRIGGER CheckExaminerInstructor
ON TransportVehicle
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Exam e ON i.instructorID = e.examinerID
    )
    BEGIN
        RAISEERROR('Examiner ID in Exam must not be equal to Instructor ID in TransportVehicle.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;



