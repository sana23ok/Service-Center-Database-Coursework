use MSVServiceCenter;

-- * створення не менше 20 DML-запитів типу SELECT (не включаючи insert, delete, update) різних за суттю;

-- * кількість таблиць, атрибути яких використовуються у запиті не менше двох;

-- * щонайменше 4 запити повинні використовувати підзапити.

-- 1) Вивести всі дані про кандидатів, які мають дійсні медичні картки з заданою групою крові та резусом.

SELECT *
FROM Candidate c
JOIN MedCard m ON c.ownerID = m.medCardID
WHERE m.bloodType = 'A' AND m.Rh = '+';

-- 2) Пронумерувати працівників за досвідом у зворотньому порядку

SELECT ROW_NUMBER() OVER (ORDER BY p.experience DESC) AS RowNum,
w.workerID, CONCAT_WS(' ', w.surname, w.firstname) AS FullName, 
p.experience
FROM Worker w
JOIN Position p on p.positionID = W.positionID;

-- 3) Показати інформацію про робітників, зарплата яких більша за середню

-- /ПІДЗАПИТ/

SELECT w.firstname, w.surname, p.positionName, p.salary
FROM Worker w
JOIN Position p ON w.positionID = p.positionID
WHERE p.salary > (SELECT AVG(salary) FROM Position);


-- 4) Знайти всі талони взяті за адресою, де місто починається на 'К'.
SELECT s.centerID, a.city, a.region, v.voucherID, v.ServiceType
FROM Address a
JOIN ServiceCenter s ON s.addressID = a.addressID
JOIN Voucher v ON v.centerID = s.centerID
JOIN Candidate c ON c.TIN = v.TIN
WHERE a.city LIKE 'К%';

-- 5) Вивести дані про кандидатів, які пройшли практичний екзамен на транспортному засобі з моделлю "Toyota".

SELECT CONCAT(' ', c.surname, c.firstname) AS FullName
FROM Candidate c
JOIN Voucher v ON c.TIN = v.TIN
JOIN Exam e ON v.voucherID = e.voucherID
JOIN PracticalExam pe ON e.examID = pe.examID
JOIN TransportVehicle tv ON pe.examID = tv.instructorID
WHERE tv.brand = 'Toyota';

select * from TransportVehicle;

-- 6) Вивести інформацію про кандидатів та терміни дії їхніх водійських посвідчень.

SELECT c.*, dl.validUntil AS DrivingLicenseExpiration
FROM Candidate c
JOIN DriversLicense dl ON c.TIN = dl.ownerID;

-- 7) Показати дані про практичні екзамени та їхні результати.

SELECT pe.*, e.result
FROM PracticalExam pe
JOIN Exam e ON pe.examID = e.examID;

-- 8) Вивести ім'я та прізвище робітників, які мають зазначені обидва зв'язки: із сервісним центром і автошколою.

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

-- 9) отримати список центрів, відсортований за сумою зроблених оплат 

-- /ПІДЗАПИТ 2/

SELECT s.centerID, s.addressID, TotalPayments
FROM ServiceCenter s
JOIN (
    SELECT centerID, SUM(payment + fee) AS TotalPayments
    FROM Voucher
    GROUP BY centerID
) v ON s.centerID = v.centerID
ORDER BY TotalPayments DESC;

-- 10) Вибрати кандидатів, зо зареєстровані в системі, але не мають жодного талона

-- /ПІДЗАПИТ 3/

SELECT TIN, firstname, surname
FROM Candidate c
WHERE NOT EXISTS (
    SELECT 1
    FROM Voucher
    WHERE TIN = c.TIN
);

-- 11) Знайти кандидатів, чиї посвідчення вже не дійсні

-- /ПІДЗАПИТ 4/
SELECT TIN, firstname, surname
FROM Candidate c
WHERE EXISTS (
    SELECT 1
    FROM DriversLicense d
    WHERE d.ownerID = c.TIN AND d.validUntil <= GETDATE()
);


-- 12) Прахувати кількість працівників у авто школах

-- /ПІДЗАПИТ 5/
SELECT w1.drivingSchool, COUNT(*) AS WorkerCount
FROM Worker w1
WHERE EXISTS (
    SELECT 1
    FROM Worker w2
    WHERE w2.drivingSchool = w1.drivingSchool
      AND w2.workerID <> w1.workerID
)
GROUP BY w1.drivingSchool;

-- 13) Вивести працівників з вказаною позицією

SELECT w.firstname, w.surname, p.positionName
FROM Worker w
JOIN Position p ON w.positionID = p.positionID
WHERE p.positionName = 'Instructor';


-- 14) Вивести інформацію про практичний екзамен та транспортний засіб, який використовувався

SELECT CONCAT_WS(' ', c.surname, c.firstname) as CandidateName, p.practicalExamID, 
																p.examRoute, tv.model, tv.brand
FROM PracticalExam p
JOIN Exam e ON p.examID = e.examID
JOIN Voucher v ON e.voucherID = v.voucherID
JOIN Candidate c ON v.TIN = c.TIN
JOIN PracticalExam_TransportVehicle petv ON p.practicalExamID = petv.practicalExamID
JOIN TransportVehicle tv ON petv.registrationPlate = tv.registrationPlate;


--15) обрати питання, що були використані на певному теоретичному екзамені

SELECT Q.*
FROM Question Q
JOIN TheoreticalExam_Question TEQ ON Q.questionID = TEQ.questionID
JOIN TheoreticalExam TE ON TEQ.theoreticalExamID = TE.theoreticalExamID
WHERE TE.theoreticalExamID = 1;


-- 16) запит вибирає всі теоретичні екзамени, тривалість яких не перевищує 15 хвилин, 
-- і які мають оцінку 18 або вище. Він використовує оператор INTERSECT для вибору спільних
-- записів з обох умов.

SELECT * FROM TheoreticalExam WHERE duration <= 15
INTERSECT
SELECT * FROM TheoreticalExam WHERE score >= 18;

-- 17) визначити іспити, за які було отримано оцінку за теоретичний екзамен,
-- а за які не було, тобто екзамен не був практичним 

SELECT E.examID, E.voucherID, E.datetimeOfExam, E.result, Th.score
FROM Exam E
LEFT JOIN TheoreticalExam Th ON  Th.examID = E.examID;

-- 18) порівняти відповіді вказаного коритувача з правильними на теоретичному іспиті

SELECT A.answerID, A.candidateAnswer, Q.correctAnswer FROM Answer A
JOIN Question Q ON Q.questionID = A.questionID
JOIN TheoreticalExam ThE ON ThE.theoreticalExamID = A.theoreticalExamID
JOIN Exam E ON E.examID = ThE.examID
JOIN Voucher V ON V.voucherID = E.voucherID
JOIN Candidate C ON C.TIN = V.TIN
WHERE C.TIN = 1234563456;

-- 19) порахувати суму оплат, зроблених у вказаному сервісному центрі у вказаний день

SELECT SUM(payment + fee) AS TotalPayments, C.centerID, A.city
FROM Voucher V
JOIN ServiceCenter C ON C.centerID = V.centerID 
JOIN Address A ON A.addressID = C.addressID
WHERE CAST(datetimeOfReciving AS DATE) = '2023-12-24' AND V.centerID = 4
GROUP BY C.centerID, A.city;

-- 20) Підрахувати працівників, що займають посади 'Instructor' та 'Examiner'

SELECT
    'Instructor' AS positionType,
    COUNT(*) AS workerCount
FROM
    Worker
WHERE
    positionID IN (SELECT positionID FROM Position WHERE positionName = 'Instructor')
UNION
SELECT
    'Examiner' AS positionType,
    COUNT(*) AS workerCount
FROM
    Worker
WHERE
    positionID IN (SELECT positionID FROM Position WHERE positionName = 'Examiner');


-- 21) вибрати позицію з більшою середньою заробітною платою з позицій 'Instructor' та 'Examiner'
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


