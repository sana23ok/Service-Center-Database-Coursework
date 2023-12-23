use MSVServiceCenter;

-- ������ 10 ����� � ������� Address
INSERT INTO Address (streetNumber, street, city, region) 
VALUES 
    (1, '���. ��������', '���', '������� �������'),
    (5, '���. ��� �������', '�����', '��������� �������'),
    (23, '�����. �������', '����', '�������� �������'),
    (12, '���. ����� ������', '�����', '������� �������'),
    (58,'���. ��������', '�����', '��������������� �������'),
    (124, '���. ��������', '�����', '�������� �������'),
    (478, '���. ˳����', '��������', '��������� �������'),
    (14, '���. ���������', '���', '������� �������'),
    (25, '��. ��������', '�����', '��������� �������'),
    (7, '���. ����������', '�����', '������� �������');

select * from ServiceCenter;

-- ������ 10 ������ � ������� ServiceCenter
INSERT INTO ServiceCenter (phoneNumber, email, addressID)
VALUES 
    ('234-567-8901', 'serviceKharkiv@example.com', 2),
    ('345-678-9012', 'serviceLviv@example.com', 3),
    ('456-789-0123', 'serviceOdessa@example.com', 4),
    ('567-890-1234', 'serviceDnipro@example.com', 5),
    ('678-901-2345', 'serviceStryi@example.com', 6),
    ('789-012-3456', 'service7@example.com', 7),
    ('890-123-4567', 'service8@example.com', 8),
    ('901-234-5678', 'service9@example.com', 9),
    ('012-345-6789', 'service10@example.com', 10);
