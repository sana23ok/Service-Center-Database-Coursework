use MSVServiceCenter;

-- використання представлень. При розробці бази даних повинно бути 
-- створено щонайменше 3 представлення;


-- 1) детальна інформація про працівників 
CREATE VIEW WorkerDetails
AS 
SELECT 
    w.workerID,
	CONCAT_WS(' ', w.surname, w.firstname) AS FullName,
    p.positionName,
    p.salary,
    p.experience,
    c.centerID,
    a.city AS centerCity,
    a.region AS centerRegion
FROM Worker w
JOIN Position p ON w.positionID = p.positionID
LEFT JOIN ServiceCenter c ON w.centerID = c.centerID
LEFT JOIN Address a ON c.addressID = a.addressID;

SELECT * FROM WorkerDetails;


-- 2)Детальна інформація про проведені екзамени екзаменаторами

CREATE VIEW ExamsConductedByExaminers AS
SELECT
    CONCAT_WS(' ', c.surname, c.firstname) AS CandidateName,
    e.examID,
    e.datetimeOfExam,
    e.result AS ExamResult,
    c.TIN AS CandidateTIN,
	ed.workerID AS ExaminerID,
    ed.FullName AS ExaminerName
FROM WorkerDetails ed
JOIN Exam e ON ed.workerID = e.examinerID
JOIN Voucher v ON e.voucherID = v.voucherID
JOIN Candidate c ON v.TIN = c.TIN;

-- Вивести дані з нового представлення
SELECT * FROM ExamsConductedByExaminers;

-- 3) деталі медичних даних

CREATE VIEW MedCardDetails AS
SELECT
    mc.medCardID,
    mc.bloodType,
    mc.Rh,
    mc.issueDate,
    mc.validUntil,
    CONCAT_WS(' ', c.surname, c.firstname) AS OwnerName,
    c.TIN AS OwnerTIN
FROM MedCard mc
JOIN Candidate c ON mc.medCardID = c.ownerID;

select * from MedCardDetails;


-- 4) Детальна інформація про водійські посвідчення та їх власників з інформацією про медичні картки

CREATE OR ALTER VIEW DriversLicenseDetails AS
SELECT
    CONCAT_WS(' ', c.surname, c.firstname) AS OwnerName,
	c.TIN AS OwnerTIN,
	c.dateOfBirth,
	c.phoneNumber,
    dl.seriesAndNumber,
    dl.validityPeriod,
    dl.issueDate,
    dl.validUntil,
    dl.category,
	CONCAT(mc.bloodType, mc.Rh) AS BloodType,
    mc.validUntil AS MedCardValidUntil
FROM DriversLicense dl
JOIN Candidate c ON dl.ownerID = c.TIN
LEFT JOIN MedCard mc ON c.ownerID = mc.medCardID;

select * from DriversLicenseDetails;