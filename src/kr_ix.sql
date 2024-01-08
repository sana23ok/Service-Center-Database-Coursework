set statistics io on;
set statistics time on;

SELECT TIN, firstname, surname
FROM Candidate c
WHERE NOT EXISTS (
    SELECT 1
    FROM Voucher
    WHERE TIN = c.TIN
);

create index ix_candidate_TIN on Candidate(TIN)

create index ix_voucher_TIN on Voucher(TIN)

