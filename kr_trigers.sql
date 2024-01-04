use MSVServiceCenter;

-- 1) Перевірка бізнес правила, яке стверджує, що посвідчення може бути видане лише 
-- після успішної здачі обох типів іспитів

CREATE OR ALTER TRIGGER CheckSuccessfulExams
ON DriversLicense
AFTER INSERT, UPDATE
AS 
BEGIN
    DECLARE @TheoreticalExamCount INT;
    DECLARE @PracticalExamCount INT;
    DECLARE @CandidateTIN BIGINT;

    -- Assuming there's a foreign key relationship between DriversLicense and Candidate
    SELECT @CandidateTIN = c.TIN
    FROM inserted i
    JOIN Candidate c ON i.ownerID = c.TIN;

    SELECT @TheoreticalExamCount = COUNT(*) 
    FROM Exam e
    JOIN Voucher v ON v.voucherID = e.voucherID
    WHERE e.result = 'positive' AND v.ServiceType = 'theoretical exam' AND v.TIN = @CandidateTIN;

    SELECT @PracticalExamCount = COUNT(*) 
    FROM Exam e
    JOIN Voucher v ON v.voucherID = e.voucherID
    WHERE e.result = 'positive' AND v.ServiceType = 'practical exam' AND v.TIN = @CandidateTIN;

    IF (@TheoreticalExamCount < 1 AND @PracticalExamCount < 1)
    BEGIN
        -- If the candidate has not passed both exams positively, print a message and roll back the transaction
        PRINT('Candidate with TIN ' + CAST(@CandidateTIN AS NVARCHAR(20)) + ' has not passed both exams positively!');
        ROLLBACK;
        RETURN;
    END
END;


select * from DriversLicense;
select * from Candidate;

DELETE FROM DriversLicense
WHERE seriesAndNumber = 'DL17';

INSERT INTO DriversLicense (seriesAndNumber, validityPeriod, issueDate, ownerID, category)
VALUES ('DL17', 2, '2023-12-29', 111223344, 'B');

-- 2) перевірка того, чи теоретичний екзамен містив 20 питань 
CREATE OR ALTER TRIGGER CheckTheorExamQuestionCount
ON TheoreticalExam_Question
AFTER INSERT, UPDATE
AS 
BEGIN
    DECLARE @TheoreticalExamID INT;
    SELECT @TheoreticalExamID = TheoreticalExamID
    FROM inserted;
    DECLARE @QuestionCount INT;
    SELECT @QuestionCount = COUNT(*)
    FROM TheoreticalExam_Question
    WHERE TheoreticalExamID = @TheoreticalExamID;
    IF @QuestionCount > 20
    BEGIN
        PRINT('Theoretical exam must include exactly 20 questions!');
        ROLLBACK;
        RETURN;
    END
END;

INSERT INTO TheoreticalExam_Question (theoreticalExamID, questionID)
VALUES 
(1, 21);


-- 3) автоматична вставка часу вказаного в талоні, якщо час не заданий при вставці 
CREATE TRIGGER trg_InsertExam
ON Voucher
AFTER INSERT
AS
BEGIN
    INSERT INTO Exam (datetimeOfExam, voucherID)
    SELECT i.examDateTime, i.voucherID
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1 FROM Exam e 
	WHERE e.voucherID = i.voucherID AND e.datetimeOfExam IS NOT NULL);
END;

select * from Candidate;

INSERT INTO Voucher (TIN, datetimeOfReciving, centerID, payment, fee, terms, examDateTime, ServiceType)
VALUES (17, '2024-01-04T14:00:00', 1, 100.00, 50.00, 
'Sample terms', '2024-01-05T10:00:00', 'theoretical exam');

select * from Voucher;

select * from Exam where voucherID = 240;

-- 4) тригер, що перевіряє чи не призначено 2 талони інстуктора 
-- чи екзаменатора одночасно на 2 практичні екзамени 

CREATE OR ALTER TRIGGER PreventOverlapExams
ON Exam
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Exam e ON i.examinerID = e.examinerID 
		JOIN Voucher v ON v.voucherID = e.voucherID
        WHERE i.examID <> e.examID AND
        (
			ABS(DATEDIFF(MINUTE, i.datetimeOfExam, e.datetimeOfExam)) < 20 OR
            ABS(DATEDIFF(MINUTE, DATEADD(MINUTE, 20, i.datetimeOfExam), DATEADD(MINUTE, 20, e.datetimeOfExam))) < 20
        )
		AND v.ServiceType = 'practical exam'
    )
    BEGIN
        RAISERROR ('The examiner is already assigned to another exam at this time.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;


select * from Exam where datetimeOfExam='2023-12-28 15:58:28.027';

update Exam 
set examinerID = 63
where examID = 81;

select * from Voucher where voucherID in(4, 91);

update Voucher 
set ServiceType = 'practical exam'
where voucherID = 4;


-- 5) тригер на видалення даних 
CREATE OR ALTER TRIGGER AfterDeletePossibleAnswer
ON PossibleAnswers
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Reinsert only two records 
    ;WITH DeletedWithRowNumber AS (
        SELECT questionID, letter, text,
               ROW_NUMBER() OVER (PARTITION BY questionID ORDER BY (SELECT NULL)) AS RowNum
        FROM deleted
    )
    INSERT INTO PossibleAnswers (questionID, letter, text)
    SELECT questionID, letter, text
    FROM DeletedWithRowNumber
    WHERE RowNum <= 2;
END;

delete from PossibleAnswers
where questionID = 2;

select * from PossibleAnswers;

-- 6)тригер, який перевірятиме чи є екзаменатор працівником центру, де проводиться екзамен 
CREATE OR ALTER TRIGGER CheckExaminerServiceCenter
ON Exam
AFTER INSERT, UPDATE
AS
BEGIN
    -- Check if the examiner is an employee of the service center where the exam is taking place
    IF (
        SELECT COUNT(*)
        FROM inserted I
        JOIN Worker W ON I.examinerID = W.workerID
        JOIN Voucher V ON I.voucherID = V.voucherID
        WHERE W.centerID <> V.centerID
    ) > 0
    BEGIN
        PRINT('Examiner is not an employee of the service center where the exam is taking place.');
        ROLLBACK;
    END
END;

select * from worker where centerID = 4;

update Exam 
set examinerID = 25
where examID = 13;

select * from Exam e
join Voucher v on v.voucherID = e.voucherID
where v.centerID != 4;

-- 7) тригер для автоматичного розрухування ціни за типом послуг
CREATE OR ALTER TRIGGER Voucher_AfterInsert
ON Voucher
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE V
    SET
        payment = 
            CASE
                WHEN i.ServiceType = 'theoretical exam' THEN 13
                WHEN i.ServiceType = 'practical exam' THEN 33
                WHEN i.ServiceType = 'licence reciving' THEN 13
            END,
        fee = 
            CASE
                WHEN i.ServiceType = 'theoretical exam' THEN 33
                WHEN i.ServiceType = 'practical exam' THEN 800
                WHEN i.ServiceType = 'licence reciving' THEN 300
            END
    FROM Voucher V
    INNER JOIN inserted i ON V.VoucherID = i.VoucherID;
END;


INSERT INTO Voucher (TIN, datetimeOfReciving, centerID, payment, fee, terms, examDateTime, ServiceType)
VALUES (17, '2024-01-04T14:00:00', 1, 100.00, 50.00, 
'Sample terms', '2024-01-05T10:00:00', 'theoretical exam');













------------------------------------------------


-- 5) тригер, що перевіряє чи не викоритовується ТЗ юільше чим на 1 екзамені, що проходить 
-- в зазначений час -+

CREATE OR ALTER TRIGGER CheckVehicleUsage
ON PracticalExam_TransportVehicle
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM PracticalExam_TransportVehicle AS PETV1
        JOIN PracticalExam_TransportVehicle AS PETV2 ON PETV1.registrationPlate = PETV2.registrationPlate
        JOIN Exam AS E1 ON PETV1.practicalExamID = E1.examID
        JOIN Exam AS E2 ON PETV2.practicalExamID = E2.examID
        WHERE E1.datetimeOfExam = E2.datetimeOfExam
    )
    BEGIN
        RAISERROR ('A vehicle cannot be used in more than one exam at the same time.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

select * from PracticalExam






