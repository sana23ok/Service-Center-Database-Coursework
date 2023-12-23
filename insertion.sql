use MSVServiceCenter;

-- Додаємо 10 адрес у таблицю Address
INSERT INTO Address (streetNumber, street, city, region) 
VALUES 
    (1, 'вул. Шевченка', 'Київ', 'Київська область'),
    (5, 'вул. Лесі Українки', 'Харків', 'Харківська область'),
    (23, 'просп. Свободи', 'Львів', 'Львівська область'),
    (12, 'вул. Івана Франка', 'Одеса', 'Одеська область'),
    (58,'вул. Шевченка', 'Дніпро', 'Дніпропетровська область'),
    (124, 'вул. Шевченка', 'Стрий', 'Львівська область'),
    (478, 'вул. Лісова', 'Запоріжжя', 'Запорізька область'),
    (14, 'вул. Пушкінська', 'Київ', 'Київська область'),
    (25, 'пр. Перемоги', 'Харків', 'Харківська область'),
    (7, 'вул. Космонавтів', 'Одеса', 'Одеська область');

select * from ServiceCenter;

-- Додаємо 10 записів у таблицю ServiceCenter
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
