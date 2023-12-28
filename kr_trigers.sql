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

-- Insert into DriversLicense table
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
        -- Raise an error and rollback the transaction
        PRINT('Theoretical exam must include exactly 20 questions!');
        ROLLBACK;
        RETURN;
    END
END;

INSERT INTO TheoreticalExam_Question (theoreticalExamID, questionID)
VALUES 
(1, 21);

-- 3) 












CREATE TRIGGER Voucher_AfterInsert
ON Voucher
AFTER INSERT
AS
BEGIN
    UPDATE V
    SET
        payment = 
            CASE
                WHEN i.ServiceType = 'theoretical exam' THEN 13
                WHEN i.ServiceType = 'practical exam' THEN 13
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