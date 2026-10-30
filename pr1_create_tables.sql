

CREATE USER ivanov WITH PASSWORD 'secret1';

CREATE DATABASE ivanov_bd ENCODING = 'UTF8';

GRANT ALL PRIVILEGES ON DATABASE ivanov_bd TO ivanov;


SELECT datname FROM pg_database WHERE datname = 'ivanov_bd';


CREATE TABLE groups (
    group_id       SERIAL PRIMARY KEY,                 
    group_name     VARCHAR(20)  NOT NULL UNIQUE,        
    specialty      VARCHAR(100) NOT NULL,
    admission_year INTEGER      NOT NULL
);


CREATE TABLE students (
    student_id  SERIAL PRIMARY KEY,
    last_name   VARCHAR(50) NOT NULL,
    first_name  VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),                            
    birth_date  DATE        NOT NULL,
    group_id    INTEGER     NOT NULL,

    CONSTRAINT fk_students_groups
        FOREIGN KEY (group_id)
        REFERENCES groups(group_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


CREATE TABLE teachers (
    teacher_id SERIAL PRIMARY KEY,
    last_name  VARCHAR(50)  NOT NULL,
    first_name VARCHAR(50)  NOT NULL,
    department VARCHAR(100) NOT NULL
);

CREATE TABLE disciplines (
    discipline_id   SERIAL PRIMARY KEY,
    discipline_name VARCHAR(100) NOT NULL UNIQUE,
    hours           INTEGER      NOT NULL CHECK (hours > 0)
);

CREATE TABLE lessons (
    lesson_id     SERIAL PRIMARY KEY,
    group_id      INTEGER     NOT NULL,
    discipline_id INTEGER     NOT NULL,
    teacher_id    INTEGER     NOT NULL,
    lesson_date   DATE        NOT NULL,
    lesson_type   VARCHAR(30) NOT NULL,

    CONSTRAINT fk_lessons_groups
        FOREIGN KEY (group_id) REFERENCES groups(group_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_lessons_disciplines
        FOREIGN KEY (discipline_id) REFERENCES disciplines(discipline_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_lessons_teachers
        FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

SELECT
    conrelid::regclass          AS таблица,
    conname                     AS ограничение,
    contype                     AS тип,
    pg_get_constraintdef(oid)   AS определение
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
ORDER BY conrelid::regclass::text, contype;

INSERT INTO groups (group_name, specialty, admission_year) VALUES
    ('П-21',  'Программирование',     2026),
    ('ИС-22', 'Информационные системы', 2026),
    ('ЭК-21', 'Экономика',            2026);

SELECT * FROM groups;


INSERT INTO students (last_name, first_name, middle_name, birth_date, group_id) VALUES
    ('Иванов',   'Иван',   'Иванович',   '2007-03-15', 1),
    ('Петров',   'Алексей','Сергеевич',  '2007-07-21', 1),
    ('Сидорова', 'Анна',   'Игоревна',   '2006-11-04', 2),
    ('Кузнецов', 'Максим', 'Олегович',   '2007-01-18', 2),
    ('Смирнова', 'Елена',  'Андреевна',  '2006-09-27', 3);

INSERT INTO teachers (last_name, first_name, department) VALUES
    ('Волков', 'Александр', 'Информационные технологии'),
    ('Орлова', 'Мария',     'Общеобразовательные дисциплины'),
    ('Фёдоров','Дмитрий',   'Программирование');

INSERT INTO disciplines (discipline_name, hours) VALUES
    ('Основы проектирования баз данных', 72),
    ('Информационные технологии',        72),
    ('Программирование',                144),
    ('Компьютерные сети',                72);

INSERT INTO lessons (group_id, discipline_id, teacher_id, lesson_date, lesson_type) VALUES
    (1, 1, 1, '2026-09-10', 'Лекция'),
    (1, 3, 3, '2026-09-11', 'Практика'),
    (2, 1, 1, '2026-09-10', 'Практика'),
    (2, 2, 2, '2026-09-12', 'Лекция'),
    (3, 2, 2, '2026-09-13', 'Практика');


INSERT INTO groups (group_name, specialty, admission_year)
VALUES ('П-23', 'Программирование', 2026);



SELECT * FROM groups;   -

INSERT INTO students (last_name, first_name, birth_date, group_id)
VALUES ('Тестов', 'Иван', '2007-05-10', 999);

UPDATE groups SET group_id = 10 WHERE group_id = 1;

SELECT * FROM students;   -- у Иванова и Петрова group_id стал 10 автоматически
SELECT * FROM lessons;    -- и в занятиях тоже

UPDATE groups SET group_id = 1 WHERE group_id = 10;

INSERT INTO groups (group_name, specialty, admission_year)
VALUES ('ТЕСТ-01', 'Тестовая специальность', 2026);

INSERT INTO students (last_name, first_name, birth_date, group_id)
VALUES ('Тестовый', 'Студент', '2007-01-01',
        (SELECT group_id FROM groups WHERE group_name = 'ТЕСТ-01'));

SELECT * FROM students WHERE last_name = 'Тестовый';   -- студент есть

DELETE FROM groups WHERE group_name = 'ТЕСТ-01';

SELECT * FROM students WHERE last_name = 'Тестовый';   -- 0 строк: удалён каскадно

SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'groups'
ORDER BY ordinal_position;

CREATE TABLE grades (
    grade_id      SERIAL PRIMARY KEY,
    student_id    INT  NOT NULL,
    discipline_id INT  NOT NULL,
    grade         INT  NOT NULL CHECK (grade BETWEEN 2 AND 5),
    grade_date    DATE NOT NULL,

    CONSTRAINT fk_grades_students
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_grades_disciplines
        FOREIGN KEY (discipline_id) REFERENCES disciplines(discipline_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

INSERT INTO grades (student_id, discipline_id, grade, grade_date) VALUES
    (1, 1, 5, '2026-09-15'),
    (1, 3, 4, '2026-09-16'),
    (2, 1, 3, '2026-09-15'),
    (2, 3, 5, '2026-09-16'),
    (3, 1, 4, '2026-09-17'),
    (3, 2, 5, '2026-09-18'),
    (4, 2, 4, '2026-09-18'),
    (4, 1, 3, '2026-09-19'),
    (5, 2, 5, '2026-09-20'),
    (5, 1, 4, '2026-09-21');

SELECT * FROM grades ORDER BY grade_id;

