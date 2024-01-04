use MSVServiceCenter;

--− використання збережених процедур/функцій. При розробці бази
--даних повинно бути реалізовано щонайменше 10 збережених 
--процедур/функцій різних типів та за суттю; 

--8.1 Створення функцій 
--8.1.1 Функція GetEmployeeCountInCenter
CREATE OR ALTER FUNCTION GetEmployeeCountInCenter(@centerID INT)
RETURNS INT
AS
BEGIN
    DECLARE @employeeCount INT;
    SELECT @employeeCount = COUNT(*) FROM Worker WHERE centerID = @centerID;
    RETURN @employeeCount;
END;

DECLARE @count INT;
EXEC @count = GetEmployeeCountInCenter @centerID = 4;
SELECT @count AS EmployeeCount;

--8.1.2 Функція GetAverageSalaryForPosition
CREATE OR ALTER FUNCTION GetAverageSalaryForPosition(@positionN VARCHAR(50))
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @averageSalary DECIMAL(10, 2);
    SELECT @averageSalary = AVG(salary) FROM Position WHERE positionName = @positionN;
    RETURN @averageSalary;
END;

DECLARE @avgSalary INT;
EXEC @avgSalary = GetAverageSalaryForPosition @positionN = 'Instructor';
SELECT @avgSalary AS EmployeeCount;

select * from Position;

--8.1.3 Функція CheckAvailabilityForDate

CREATE OR ALTER FUNCTION CheckAvailabilityForDate(
	@targetDate DATE, 
	@vochersForDay INT
)
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*)
    FROM Voucher
    WHERE CONVERT(DATE, datetimeOfReciving) = @targetDate;
    RETURN @vochersForDay - @count;
END;

-- Виклик функції і вивід результату
DECLARE @dateToCheck DATE = '2023-12-24';
DECLARE @voucherCount INT;

SET @voucherCount = dbo.CheckAvailabilityForDate(@dateToCheck, 45);

PRINT 'Кількість вільних талонів на ' + CONVERT(NVARCHAR, @dateToCheck) + 
': ' + CONVERT(NVARCHAR, @voucherCount);

select * from Voucher;

--8.1.4 Функція GetExamsTakenCount
CREATE OR ALTER FUNCTION GetExamsTakenCount
(
    @Surname VARCHAR(255),
    @Firstname VARCHAR(255)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        (SELECT COUNT(*) FROM TheoreticalExam 
        WHERE examID IN (SELECT examID 
                         FROM Exam 
                         WHERE voucherID IN (SELECT voucherID 
                                            FROM Voucher 
                                            WHERE TIN = (SELECT TIN 
                                                         FROM Candidate 
                                                         WHERE surname = @Surname AND firstname = @Firstname)
                                                      AND ServiceType = 'theoretical exam'))) 
        AS TheoreticalExamsTaken,

        (SELECT COUNT(*) FROM PracticalExam 
        WHERE examID IN (SELECT examID 
                         FROM Exam 
                         WHERE voucherID IN (SELECT voucherID 
                                            FROM Voucher 
                                            WHERE TIN = (SELECT TIN 
                                                         FROM Candidate 
                                                         WHERE surname = @Surname AND firstname = @Firstname)
                                                      AND ServiceType = 'practical exam'))) 
        AS PracticalExamsTaken
);

SELECT * FROM GetExamsTakenCount('Malynovska', 'Arina');


--8.1.5 Функція GetLicenseType
CREATE OR ALTER FUNCTION GetLicenseType 
(
    @Firstname VARCHAR(255),
    @Surname VARCHAR(255)
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @LicenseType VARCHAR(20)

    SELECT @LicenseType = 
        CASE 
            WHEN dl.validityPeriod = 2 THEN 'Temporary (2 years)'
            WHEN dl.validityPeriod = 10 THEN 'Permanent (10 years)'
            ELSE 'Unknown'
        END
    FROM DriversLicense dl
    INNER JOIN Candidate c ON dl.ownerID = c.TIN
    WHERE c.firstname = @Firstname AND c.surname = @Surname;

    RETURN @LicenseType;
END;


DECLARE @FirstnameParam VARCHAR(255) = 'Inna'; 
DECLARE @SurnameParam VARCHAR(255) = 'Pavlova'; 
DECLARE @Result VARCHAR(20);

SET @Result = dbo.GetLicenseType(@FirstnameParam, @SurnameParam);

PRINT 'License Type: ' + @Result;

select * from DriversLicense d
join Candidate c on c.TIN = d.ownerID;

--8.2 Створення процедур 
--8.2.1 Процедура GetExamResultsByCenter
CREATE OR ALTER PROCEDURE GetExamResultsByCenter
    @centerID INT
AS
BEGIN
    SELECT E.examID, E.datetimeOfExam, E.result, W.surname + ' ' + W.firstname AS examinerName, 
	C.surname + ' ' + C.firstname AS candidateName
    FROM Exam E
    INNER JOIN Worker W ON E.examinerID = W.workerID
    INNER JOIN Voucher V ON E.voucherID = V.voucherID
	INNER JOIN Candidate C ON C.TIN = V.TIN
    WHERE V.centerID = @centerID;
END;


EXEC GetExamResultsByCenter @centerID = 4;

--8.2.2 Процедура CategorizeInstructors
CREATE PROCEDURE CategorizeInstructors
AS
BEGIN
    SELECT *
    FROM Worker
    WHERE centerID IS NOT NULL
		AND positionID IN (SELECT positionID FROM Position 
		WHERE positionName = 'Instructor');

    SELECT *
    FROM Worker
    WHERE drivingSchool IS NOT NULL
		AND positionID IN (SELECT positionID FROM Position 
		WHERE positionName = 'Instructor');
END;

EXEC CategorizeInstructors;

--8.2.3 Процедура GetExamCountsByDate
CREATE OR ALTER PROCEDURE GetExamCountsByDate
    @specificDate DATE
AS
BEGIN
    -- Кількість проведених практичних екзаменів за конкретний день
    SELECT COUNT(*) AS PracticalExamCount
    FROM PracticalExam PE
    INNER JOIN Exam E ON PE.examID = E.examID
    WHERE CONVERT(DATE, E.datetimeOfExam) = @specificDate;

    -- Кількість проведених теоретичних екзаменів за конкретний день
    SELECT COUNT(*) AS TheoreticalExamCount
    FROM TheoreticalExam TE
    INNER JOIN Exam E ON TE.examID = E.examID
    WHERE CONVERT(DATE, E.datetimeOfExam) = @specificDate;
END;

EXEC GetExamCountsByDate  @specificDate = '2023-12-24';

select * from Exam where CAST(datetimeOfExam as Date)='2023-12-24';

--8.2.4 Процедура GetCandidatesThEx 
CREATE OR ALTER PROCEDURE GetCandidatesThEx
AS
BEGIN
	 SELECT C.TIN, C.surname, C.firstname
	 FROM Candidate C
	 INNER JOIN Voucher V ON C.TIN = V.TIN
	 INNER JOIN Exam E ON V.voucherID = E.voucherID
	 INNER JOIN TheoreticalExam TE ON E.examID = TE.examID
	 WHERE TE.score >= 18;
END;

EXEC  GetCandidatesThEx;

--8.2.5 Процедура FillExamResults
CREATE OR ALTER PROCEDURE FillExamResults
AS
BEGIN
    -- Update Exam table
    UPDATE Exam
    SET result = CASE WHEN TheoreticalExam.score >= 18 THEN 'positive' ELSE 'negative' END
    FROM Exam
    INNER JOIN TheoreticalExam ON Exam.examID = TheoreticalExam.examID;
END;


EXEC FillExamResults;












-----------------------------------------------
-- FUNCTIONS 

CREATE OR ALTER PROCEDURE FillExamResults
AS
BEGIN
    -- Update Exam table
    UPDATE Exam
    SET result = CASE WHEN TheoreticalExam.score >= 18 THEN 'positive' ELSE 'negative' END
    FROM Exam
    INNER JOIN TheoreticalExam ON Exam.examID = TheoreticalExam.examID;
END;

exec FillExamResults;

select * from Exam; -- 40 41 42

update TheoreticalExam
set score = 19 
where examID in(21, 36, 88)

select t.*, e.result from TheoreticalExam t
join Exam e on e.examID = t.examID
where t.examID in(21, 36, 88);


---------------------------
-- 5) вибрати кандитатів, що успішно склали екзамени і вже мать посвідчення --

CREATE OR ALTER PROCEDURE GetSuccessfulCandidatesWithLicense
AS
BEGIN
    -- Кандидати, які успішно склали обидва екзамени
    SELECT C.TIN, C.surname, C.firstname
    INTO #SuccessfulCandidates
    FROM Candidate C
    WHERE EXISTS (
        SELECT 1
        FROM Voucher V
        INNER JOIN Exam E ON V.voucherID = E.voucherID
        INNER JOIN TheoreticalExam TE ON E.examID = TE.examID
        INNER JOIN PracticalExam PE ON E.examID = PE.examID
        WHERE C.TIN = V.TIN AND E.result = 'positive'
    );

    -- Кандидати з посвідченням
    SELECT SC.*
    FROM #SuccessfulCandidates SC
    INNER JOIN DriversLicense DL ON SC.TIN = DL.ownerID;

    -- Видалити тимчасову таблицю
    DROP TABLE IF EXISTS #SuccessfulCandidates;
END;

EXEC GetSuccessfulCandidatesWithLicense;


-- 6) процедура для автоматичного заповнення даних на основі даних про талон --
CREATE PROCEDURE FillExamsFromVoucher
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


-- 8) Обрахувати результат теоретичного екзамену ++
-- Create a function to calculate the score for a theoretical exam
CREATE OR ALTER FUNCTION dbo.CalculateScore(@theoreticalExamID INT)
RETURNS INT
AS
BEGIN
    DECLARE @score INT = 0;

    SELECT @score = @score + CASE
                                WHEN A.candidateAnswer = Q.correctAnswer THEN 1
                                ELSE 0
                             END
    FROM Answer A
    INNER JOIN Question Q ON A.questionID = Q.questionID
    WHERE A.theoreticalExamID = @theoreticalExamID;

    RETURN @score;
END;

-- Update the score column in the TheoreticalExam table using the function
declare @thExID INT = 1;

UPDATE TheoreticalExam
SET score = dbo.CalculateScore(@thExID)
WHERE theoreticalExamID = @thExID;

-- View the updated TheoreticalExam table
SELECT * FROM TheoreticalExam;
