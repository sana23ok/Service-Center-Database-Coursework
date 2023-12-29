use MSVServiceCenter;

select * from Question;
select * from PossibleAnswers;

select * from Exam;

update Exam 
set examinerID = 63
where examID = 32;


WITH ExamTimes AS (
    SELECT
        E.examID,
        E.datetimeOfExam AS startTime,
        DATEADD(MINUTE, D.duration, E.datetimeOfExam) AS endTime,
        E.examinerID AS workerID
    FROM
        Exam E
        JOIN TheoreticalExam D ON E.examID = D.examID
    UNION ALL
    SELECT
        PE.examID,
        E.datetimeOfExam AS startTime,
        DATEADD(MINUTE, D.duration, E.datetimeOfExam) AS endTime,
        E.examinerID
    FROM
        PracticalExam PE
        JOIN Exam E ON PE.examID = E.examID
        JOIN TheoreticalExam D ON E.examID = D.examID
)
SELECT
    W.workerID,
    W.firstname,
    W.surname,
    ET1.examID AS examID1,
    ET2.examID AS examID2,
    ET1.startTime AS startTime1,
    ET1.endTime AS endTime1,
    ET2.startTime AS startTime2,
    ET2.endTime AS endTime2
FROM
    Worker W
    JOIN ExamTimes ET1 ON W.workerID = ET1.workerID
    JOIN ExamTimes ET2 ON W.workerID = ET2.workerID
WHERE
    ET1.examID < ET2.examID
    AND (
        (ET1.startTime BETWEEN ET2.startTime AND ET2.endTime)
        OR (ET1.endTime BETWEEN ET2.startTime AND ET2.endTime)
        OR (ET2.startTime BETWEEN ET1.startTime AND ET1.endTime)
        OR (ET2.endTime BETWEEN ET1.startTime AND ET1.endTime)
    );

