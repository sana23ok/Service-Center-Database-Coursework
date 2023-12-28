use MSVServiceCenter;

--* ��������� �� ����� 20 DML-������ ���� SELECT (�� ��������� insert, delete, update) ����� �� �����;

-- *������� �������, �������� ���� ���������������� � ����� �� ����� ����;

-- *���������� 4 ������ ������ ��������������� ��������.

-- 1) ������� �� ��� ��� ���������, �� ����� ���� ������ ������ � ������� ������ ���� �� �������.

SELECT *
FROM Candidate c
JOIN MedCard m ON c.ownerID = m.medCardID
WHERE m.bloodType = 'A' AND m.Rh = '+';

-- 2) ������������� ���������� �� ������� � ����������� �������

SELECT ROW_NUMBER() OVER (ORDER BY p.experience DESC) AS RowNum,
w.workerID, CONCAT_WS(' ', w.surname, w.firstname) AS FullName, 
p.experience
FROM Worker w
JOIN Position p on p.positionID = W.positionID;

-- 3) �������� ���������� ��� ��������, �������� ���� ����� �� �������

-- /ϲ������/

SELECT w.firstname, w.surname, p.positionName, p.salary
FROM Worker w
JOIN Position p ON w.positionID = p.positionID
WHERE p.salary > (SELECT AVG(salary) FROM Position);


-- 4) ������ �� ������ ���� �� �������, �� ���� ���������� �� '�'.
SELECT s.centerID, a.city, a.region, v.voucherID, v.ServiceType
FROM Address a
JOIN ServiceCenter s ON s.addressID = a.addressID
JOIN Voucher v ON v.centerID = s.centerID
JOIN Candidate c ON c.TIN = v.TIN
WHERE a.city LIKE '�%';

-- 5) ������� ��� ��� ���������, �� ������� ���������� ������� �� ������������� ����� � ������� "Toyota".

SELECT CONCAT(' ', c.surname, c.firstname) AS FullName
FROM Candidate c
JOIN Voucher v ON c.TIN = v.TIN
JOIN Exam e ON v.voucherID = e.voucherID
JOIN PracticalExam pe ON e.examID = pe.examID
JOIN TransportVehicle tv ON pe.examID = tv.instructorID
WHERE tv.brand = 'Toyota';

select * from TransportVehicle;

-- 6) ������� ���������� ��� ��������� �� ������ 䳿 ���� ��������� ���������.

SELECT c.*, dl.validUntil AS DrivingLicenseExpiration
FROM Candidate c
JOIN DriversLicense dl ON c.TIN = dl.ownerID;

-- 7) �������� ��� ��� �������� �������� �� ��� ����������.

SELECT pe.*, e.result
FROM PracticalExam pe
JOIN Exam e ON pe.examID = e.examID;

-- 8) ������� ��'� �� ������� ��������, �� ����� �������� ������ ��'����: �� �������� ������� � ����������.

SELECT
    w.firstname,
    w.surname,
	w.drivingSchool,
    sc.centerID
FROM
    Worker w
JOIN
    ServiceCenter sc ON w.centerID = sc.centerID
WHERE
    w.centerID IS NOT NULL AND w.drivingSchool IS NOT NULL;

-- 9) �������� ������ ������, ������������ �� ����� ��������� ����� 

-- /ϲ������ 2/

SELECT s.centerID, s.addressID, TotalPayments
FROM ServiceCenter s
JOIN (
    SELECT centerID, SUM(payment + fee) AS TotalPayments
    FROM Voucher
    GROUP BY centerID
) v ON s.centerID = v.centerID
ORDER BY TotalPayments DESC;

-- 10) ������� ���������, �� ����������� � ������, ��� �� ����� ������� ������

-- /ϲ������ 3/

SELECT TIN, firstname, surname
FROM Candidate c
WHERE NOT EXISTS (
    SELECT 1
    FROM Voucher
    WHERE TIN = c.TIN
);

-- 11) ������ ���������, �� ���������� ��� �� ����

-- /ϲ������ 4/
SELECT TIN, firstname, surname
FROM Candidate c
WHERE EXISTS (
    SELECT 1
    FROM DriversLicense d
    WHERE d.ownerID = c.TIN AND d.validUntil <= GETDATE()
);


-- 12) ��������� ������� ���������� � ���� ������

-- /ϲ������ 5/
SELECT w1.drivingSchool, COUNT(*) AS WorkerCount
FROM Worker w1
WHERE EXISTS (
    SELECT 1
    FROM Worker w2
    WHERE w2.drivingSchool = w1.drivingSchool
      AND w2.workerID <> w1.workerID
)
GROUP BY w1.drivingSchool;

-- 13) ������� ���������� � �������� ��������

SELECT w.firstname, w.surname, p.positionName
FROM Worker w
JOIN Position p ON w.positionID = p.positionID
WHERE p.positionName = 'Instructor';


-- 14) ������� ���������� ��� ���������� ������� �� ������������ ����, ���� ����������������

SELECT CONCAT_WS(' ', c.surname, c.firstname) as CandidateName, p.practicalExamID, 
																p.examRoute, tv.model, tv.brand
FROM PracticalExam p
JOIN Exam e ON p.examID = e.examID
JOIN Voucher v ON e.voucherID = v.voucherID
JOIN Candidate c ON v.TIN = c.TIN
JOIN PracticalExam_TransportVehicle petv ON p.practicalExamID = petv.practicalExamID
JOIN TransportVehicle tv ON petv.registrationPlate = tv.registrationPlate;


--15) ������ �������, �� ���� ���������� �� ������� ������������ �������

SELECT Q.*
FROM Question Q
JOIN TheoreticalExam_Question TEQ ON Q.questionID = TEQ.questionID
JOIN TheoreticalExam TE ON TEQ.theoreticalExamID = TE.theoreticalExamID
WHERE TE.theoreticalExamID = 1;


-- 16) ����� ������ �� ��������� ��������, ��������� ���� �� �������� 15 ������, 
-- � �� ����� ������ 18 ��� ����. ³� ����������� �������� INTERSECT ��� ������ �������
-- ������ � ���� ����.

SELECT * FROM TheoreticalExam WHERE duration <= 15
INTERSECT
SELECT * FROM TheoreticalExam WHERE score >= 18;

-- 17)




-- 21) ������� ������� � ������ ��������� ��������� ������ � ������� 'Instructor' �� 'Examiner'
WITH InstructorAvg AS (
    SELECT AVG(salary) AS avgSalary
    FROM Position p
    JOIN Worker w ON w.positionID = p.positionID
    WHERE positionName = 'Instructor'
),

ExaminerAvg AS (
    SELECT AVG(salary) AS avgSalary
    FROM Position p
    JOIN Worker w ON w.positionID = p.positionID
    WHERE positionName = 'Examiner'
)
SELECT 
    CASE 
        WHEN InstructorAvg.avgSalary > ExaminerAvg.avgSalary THEN 'Instructor'
        WHEN InstructorAvg.avgSalary < ExaminerAvg.avgSalary THEN 'Examiner'
        ELSE 'Equal' 
    END AS HigherPosition,
    CASE 
        WHEN InstructorAvg.avgSalary > ExaminerAvg.avgSalary THEN InstructorAvg.avgSalary
        WHEN InstructorAvg.avgSalary < ExaminerAvg.avgSalary THEN ExaminerAvg.avgSalary
        ELSE InstructorAvg.avgSalary 
    END AS HigherAvgSalary
FROM InstructorAvg, ExaminerAvg; 






-- Select all theoretical exams and their associated questions 
--(including those without questions)
SELECT TE.*, Q.*
FROM TheoreticalExam TE
LEFT JOIN TheoreticalExam_Question TEQ ON TE.theoreticalExamID = TEQ.theoreticalExamID
LEFT JOIN Question Q ON TEQ.questionID = Q.questionID;


-- Select all questions and their associated theoretical exams (including those without exams) using right outer join
SELECT Q.*, TE.*
FROM Question Q
RIGHT JOIN TheoreticalExam_Question TEQ ON Q.questionID = TEQ.questionID
RIGHT JOIN TheoreticalExam TE ON TEQ.theoreticalExamID = TE.theoreticalExamID;

SELECT SUM(payment+fee) AS TotalPayments
FROM Voucher
WHERE CAST(datetimeOfReciving AS DATE) = '2023-12-24' AND centerID = 4;
