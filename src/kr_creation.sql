IF EXISTS (
	SELECT name
	FROM sys.databases
	WHERE name = N'MVSServiceCenter'
)

DROP DATABASE MVSServiceCenter

CREATE DATABASE MVSServiceCenter

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
    FOREIGN KEY (addressID) REFERENCES Address(addressID) ON DELETE CASCADE
);

CREATE TABLE Position (
    positionID INT IDENTITY(1,1) PRIMARY KEY,
	positionName VARCHAR(100),
    salary DECIMAL(10, 2) CHECK (salary >= 0),
    experience INT CHECK (experience >= 0)
);

CREATE TABLE Worker(
    workerID INT IDENTITY(1,1) PRIMARY KEY,
    centerID INT, 
    drivingSchool VARCHAR(255), 
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
    FOREIGN KEY (centerID) REFERENCES ServiceCenter(centerID) ON DELETE CASCADE,
    FOREIGN KEY (positionID) REFERENCES Position(positionID) ON DELETE CASCADE
);

CREATE TABLE MedCard (
    medCardID INT IDENTITY(1,1) PRIMARY KEY,
    bloodType VARCHAR(2) NOT NULL,
    Rh CHAR(1) NOT NULL,
    issueDate DATE NOT NULL, 
    validUntil AS DATEADD(YEAR, 8, issueDate) PERSISTED NOT NULL,
);

CREATE TABLE Candidate (
    TIN BIGINT PRIMARY KEY,
    surname VARCHAR(100) NOT NULL,
    firstname VARCHAR(100) NOT NULL,
    dateOfBirth DATE NOT NULL,
    phoneNumber VARCHAR(15) NOT NULL,
    ownerID INT FOREIGN KEY REFERENCES MedCard(medCardID) ON DELETE CASCADE,
	UNIQUE (TIN),
	UNIQUE (ownerID)
);

CREATE TABLE Voucher (
    voucherID INT IDENTITY(1,1) PRIMARY KEY,
    TIN BIGINT NOT NULL, 
    datetimeOfReciving DATETIME NOT NULL,
    centerID INT NOT NULL, 
    payment DECIMAL(10, 2),
    fee DECIMAL(10, 2),
    terms VARCHAR(255),
	examDateTime DATETIME,
	ServiceType VARCHAR(20) NOT NULL CHECK (ServiceType IN ('theoretical exam', 'practical exam', 'licence reciving'))
	FOREIGN KEY (centerID) REFERENCES ServiceCenter(centerID) ON DELETE CASCADE,
	FOREIGN KEY (TIN) REFERENCES Candidate(TIN) ON DELETE CASCADE
);

ALTER TABLE Voucher
ADD CONSTRAINT CHK_ExamDateTime
CHECK (datetimeOfReciving < examDateTime);

CREATE TABLE Exam (
    examID INT IDENTITY(1,1) PRIMARY KEY,
    datetimeOfExam DATETIME,
    result VARCHAR(50) CHECK (result IN ('positive', 'negative')), 
    examinerID INT,
	voucherID INT NOT NULL,
    FOREIGN KEY (examinerID) REFERENCES Worker(workerID),
	FOREIGN KEY (voucherID) REFERENCES Voucher(voucherID),
	UNIQUE (voucherID)
);

ALTER TABLE Voucher
ADD category VARCHAR(10);


ALTER TABLE Voucher
ADD CONSTRAINT CHK_Category
CHECK (
    (ServiceType = 'licence reciving' AND category IS NULL) OR
    (ServiceType <> 'licence reciving' AND category IS NOT NULL)
);



ALTER TABLE TransportVehicle
ADD category VARCHAR(10);

CREATE TABLE PracticalExam (
    practicalExamID INT IDENTITY(1,1) PRIMARY KEY,
    examRoute VARCHAR(255) NOT NULL,
    examID INT,
    FOREIGN KEY (examID) REFERENCES Exam(examID) ON DELETE CASCADE,
	UNIQUE (examID)
);

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

CREATE TABLE PracticalExam_TransportVehicle (
    practicalExamID INT NOT NULL,
    registrationPlate VARCHAR(15) NOT NULL,
    PRIMARY KEY (practicalExamID, registrationPlate),
    FOREIGN KEY (practicalExamID) REFERENCES PracticalExam(practicalExamID),
    FOREIGN KEY (registrationPlate) REFERENCES TransportVehicle(registrationPlate)
);

CREATE TABLE TheoreticalExam (
    theoreticalExamID INT IDENTITY(1,1) PRIMARY KEY,
    examID INT,
	duration INT CHECK (duration >= 0 and duration <= 20),
	score INT CHECK (score >= 0 and score <= 20)
    FOREIGN KEY (examID) REFERENCES Exam(examID) ON DELETE CASCADE,
	UNIQUE (examID)
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
	FOREIGN KEY (questionID) REFERENCES Question(questionID) ON DELETE CASCADE, 
	FOREIGN KEY (theoreticalExamID) REFERENCES TheoreticalExam(theoreticalExamID) ON DELETE CASCADE
)

CREATE TABLE PossibleAnswers (
    possibleAnswerID INT IDENTITY(1,1) PRIMARY KEY,
    letter CHAR,
    text VARCHAR(500),
    questionID INT,
    FOREIGN KEY (questionID) REFERENCES Question(questionID) ON DELETE CASCADE
);


CREATE TABLE TheoreticalExam_Question (
    theoreticalExamID INT,
    questionID INT,
    PRIMARY KEY (theoreticalExamID, questionID),
    FOREIGN KEY (theoreticalExamID) REFERENCES TheoreticalExam(theoreticalExamID),
	FOREIGN KEY (questionID) REFERENCES Question(questionID) ON DELETE CASCADE
);
