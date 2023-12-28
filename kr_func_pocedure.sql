use MSVServiceCenter;


--− використання збережених процедур/функцій. При розробці бази
--даних повинно бути реалізовано щонайменше 10 збережених 
--процедур/функцій різних типів та за суттю; 

-- PROCEDURES 
-- 1) процедура що показує результати екзаменів по вказаному центру 
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

-- 2) процедура, що дфлить інструкторів за місцем роботити в сервісному центрі або в автошколі 

CREATE PROCEDURE CategorizeInstructors
AS
BEGIN
    -- Instructors working in a specific center
    SELECT *
    FROM Worker
    WHERE centerID IS NOT NULL
      AND positionID IN (SELECT positionID FROM Position WHERE positionName = 'Instructor');

    -- Instructors with a driving school
    SELECT *
    FROM Worker
    WHERE drivingSchool IS NOT NULL
      AND positionID IN (SELECT positionID FROM Position WHERE positionName = 'Instructor');
END;

EXEC CategorizeInstructors;


-- 3) процедура, яка визначає кількість проведених теоретичних та практичних іспитів за певний день

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

EXEC GetExamCountsByDate  @specificDate = '2023-12-25';

select * from Exam;

-- 4) вибрати кандидатів, що допущені до практичного екзамену

CREATE PROCEDURE GetCandidatesForPracticalExam
AS
BEGIN
    -- Кандидати, які успішно склали теоретичний екзамен і допущені до практичного
    SELECT C.TIN, C.surname, C.firstname
    FROM Candidate C
    INNER JOIN Voucher V ON C.TIN = V.TIN
    INNER JOIN Exam E ON V.voucherID = E.voucherID
    INNER JOIN TheoreticalExam TE ON E.examID = TE.examID
    WHERE E.result = 'positive';

END;

EXEC GetCandidatesForPracticalExam;


-- 5) вибрати кандитатів, що успішно склали екзамени і вже мать посвідчення 

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


-- 6) процедура для автоматичного заповнення даних на основі даних про талон 
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

-- 7) автоматичне заповнення результаів на основі балу на теооретичному екзамені
CREATE OR ALTER PROCEDURE FillExamResults
AS
BEGIN
    -- Update Exam table
    UPDATE Exam
    SET result = CASE WHEN TheoreticalExam.score >= 18 THEN 'positive' ELSE 'negative' END
    FROM Exam
    INNER JOIN TheoreticalExam ON Exam.examID = TheoreticalExam.examID;
END;

-- Execute the stored procedure
EXEC FillExamResults;


-- 8) знайти список питань, що були задані конкретному кандидату на теоретичному екзамені 

CREATE OR ALTER PROCEDURE GetTheoreticalExamDetails
    @TargetTIN BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    -- Get the theoretical exam ID for the given person
    DECLARE @TheoreticalExamID INT;

    SELECT @TheoreticalExamID = te.theoreticalExamID
    FROM TheoreticalExam te
    JOIN Exam e ON te.examID = e.examID
    JOIN Voucher v ON e.voucherID = v.voucherID
    JOIN Candidate c ON v.TIN = c.TIN
    WHERE c.TIN = @TargetTIN;

    IF @TheoreticalExamID IS NOT NULL
    BEGIN
        -- Get the list of questions, client answers, and correct answers for the theoretical exam
        SELECT
            q.text AS Question,
            ISNULL(a.text, 'Not Answered') AS ClientAnswer,
            a.isCorrect AS IsCorrectAnswer
        FROM
            TheoreticalExam_Question tq
        JOIN Question q ON tq.questionID = q.questionID
        LEFT JOIN ClientAnswer ca ON tq.theoreticalExamID = ca.theoreticalExamID
        LEFT JOIN Answer a ON ca.answerID = a.answerID
        WHERE
            tq.theoreticalExamID = @TheoreticalExamID;
    END
    ELSE
    BEGIN
        PRINT 'Theoretical exam not found for the specified TIN.';
    END
END;


EXEC GetTheoreticalExamDetails @TargetTIN = 1234563456;

select * from TheoreticalExam;


select t.*, c.surname, c.TIN
from TheoreticalExam t
join Exam e ON e.examID = t.examID
join Voucher v on v.voucherID = e.voucherID
join Candidate c on c.TIN = v.TIN;


-- 9) Обрахувати результат теоретичного екзамену
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



-- FUNCTIONS 

-- 1)Отримати кількість працівників у конкретному центрі:
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

-- 2)Отримати середню зарплатню працівників у певній посаді:
CREATE OR ALTER FUNCTION GetAverageSalaryForPosition(@positionID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @averageSalary DECIMAL(10, 2);
    SELECT @averageSalary = AVG(salary) FROM Position WHERE positionID = @positionID;
    RETURN @averageSalary;
END;

DECLARE @avgSalary INT;
EXEC @avgSalary = GetAverageSalaryForPosition @positionID = 9;
SELECT @avgSalary AS EmployeeCount;


-- 3) визначення наявності вільних талонів на певну дату CheckAvailabilityForDate

-- Створення функції
CREATE OR ALTER FUNCTION CheckAvailabilityForDate(@targetDate DATE, @vochersForDay INT)
RETURNS INT
AS
BEGIN
    DECLARE @count INT;

    -- Підрахунок кількості талонів на вказану дату
    SELECT @count = COUNT(*)
    FROM Voucher
    WHERE CONVERT(DATE, datetimeOfReciving) = @targetDate;

    -- Повернення результату
    RETURN @vochersForDay - @count;
END;

-- Виклик функції і вивід результату
DECLARE @dateToCheck DATE = '2023-12-24';
DECLARE @voucherCount INT;

SET @voucherCount = dbo.CheckAvailabilityForDate(@dateToCheck, 45);

PRINT 'Кількість вільних талонів на ' + CONVERT(NVARCHAR, @dateToCheck) + ': ' + CONVERT(NVARCHAR, @voucherCount);

-- 4) створимо функцію, яка підраховує кількість здач теоретичних і 
-- практичних іспитів для заданого користувача (кандидата)

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
        (SELECT COUNT(*) FROM TheoreticalExam WHERE examID IN (SELECT examID 
		FROM Exam WHERE voucherID IN (SELECT voucherID FROM Voucher 
		WHERE TIN = (SELECT TIN FROM Candidate 
		WHERE surname = @Surname AND firstname = @Firstname)))) 
		AS TheoreticalExamsTaken,

        (SELECT COUNT(*) FROM PracticalExam WHERE examID IN (SELECT examID 
		FROM Exam WHERE voucherID IN (SELECT voucherID FROM Voucher 
		WHERE TIN = (SELECT TIN FROM Candidate 
		WHERE surname = @Surname AND firstname = @Firstname)))) AS PracticalExamsTaken
);

SELECT * FROM GetExamsTakenCount('Malynovska', 'Arina');

-- 5) визначити чи  водій має тимсове посвідчення

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
