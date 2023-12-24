use MSVServiceCenter;

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