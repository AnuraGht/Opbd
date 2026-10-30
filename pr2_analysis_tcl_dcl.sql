
INSERT INTO groups (group_name, specialty, admission_year) VALUES
    ('П-23',    'Программирование',       2026),
    ('ТЕСТ-01', 'Тестовая специальность', 2026)
ON CONFLICT (group_name) DO NOTHING;


SELECT
    s.student_id,
    s.last_name || ' ' || s.first_name || ' ' || COALESCE(s.middle_name, '') AS ФИО,
    g.group_name AS группа,
    g.specialty  AS специальность
FROM students s
JOIN groups g ON s.group_id = g.group_id
ORDER BY g.group_name, s.last_name;

SELECT
    g.group_name AS группа,
    COUNT(s.student_id) AS количество_студентов
FROM groups g
LEFT JOIN students s ON g.group_id = s.group_id
GROUP BY g.group_id, g.group_name
ORDER BY количество_студентов DESC, g.group_name;

SELECT
    l.lesson_date AS дата,
    g.group_name  AS группа,
    d.discipline_name AS дисциплина,
    t.last_name || ' ' || t.first_name AS преподаватель,
    l.lesson_type AS вид_занятия
FROM lessons l
JOIN groups g      ON l.group_id = g.group_id
JOIN disciplines d ON l.discipline_id = d.discipline_id
JOIN teachers t    ON l.teacher_id = t.teacher_id
ORDER BY l.lesson_date, g.group_name;


SELECT
    t.last_name || ' ' || t.first_name AS преподаватель,
    t.department AS кафедра,
    COUNT(l.lesson_id) AS количество_занятий
FROM teachers t
LEFT JOIN lessons l ON t.teacher_id = l.teacher_id
GROUP BY t.teacher_id, t.last_name, t.first_name, t.department
ORDER BY количество_занятий DESC;


SELECT
    last_name || ' ' || first_name AS ФИО,
    birth_date AS дата_рождения
FROM students
WHERE birth_date > '2007-01-01'
ORDER BY birth_date;

SELECT discipline_name AS дисциплина, hours AS часы
FROM disciplines
WHERE hours > 72
ORDER BY hours DESC;


SELECT
    g.group_name AS группа,
    COUNT(s.student_id) AS студентов
FROM groups g
JOIN students s ON g.group_id = s.group_id
GROUP BY g.group_id, g.group_name
HAVING COUNT(s.student_id) > 1
ORDER BY студентов DESC;

SELECT ROUND(AVG(занятий), 2) AS среднее_количество_занятий
FROM (
    SELECT teacher_id, COUNT(lesson_id) AS занятий
    FROM lessons
    GROUP BY teacher_id
) AS subquery;


SELECT DISTINCT specialty AS специальность
FROM groups
ORDER BY specialty;


SELECT
    last_name || ' ' || first_name AS ФИО,
    (SELECT group_name FROM groups WHERE group_id = s.group_id) AS группа
FROM students s
ORDER BY last_name;


INSERT INTO groups (group_id, group_name, specialty, admission_year)
VALUES (1, 'Новая группа', 'Тест', 2026);

=
INSERT INTO students (first_name, birth_date, group_id)
VALUES ('Иван', '2007-01-01', 1);


ALTER TABLE students ALTER COLUMN middle_name TYPE VARCHAR(100);


INSERT INTO groups (group_name, specialty, admission_year)
VALUES ('П-21', 'Другая специальность', 2026);


ALTER TABLE teachers RENAME COLUMN department TO kafedra;
ALTER TABLE teachers RENAME COLUMN kafedra TO department;


ALTER TABLE teachers ADD COLUMN temp_column VARCHAR(50);
ALTER TABLE teachers DROP COLUMN temp_column;


ALTER TABLE groups
    ADD CONSTRAINT chk_admission_year
    CHECK (admission_year BETWEEN 2000 AND 2100);


BEGIN TRANSACTION;

UPDATE students SET group_id = 2 WHERE student_id = 1;
UPDATE groups   SET group_name = 'П-21 (обновлена)' WHERE group_id = 1;

COMMIT;

SELECT * FROM students WHERE student_id = 1;   -- group_id = 2


UPDATE students SET group_id = 1 WHERE student_id = 1;
UPDATE groups   SET group_name = 'П-21' WHERE group_id = 1;

BEGIN TRANSACTION;

DELETE FROM students;                       
SELECT COUNT(*) FROM students;              

ROLLBACK;                                   

SELECT COUNT(*) FROM students;              


BEGIN TRANSACTION;

INSERT INTO groups (group_name, specialty, admission_year)
VALUES ('ВРЕМ-01', 'Временная', 2026);

SAVEPOINT sp1;

INSERT INTO groups (group_name, specialty, admission_year)
VALUES ('ВРЕМ-02', 'Временная', 2026);

ROLLBACK TO SAVEPOINT sp1;                  

COMMIT;                                     

SELECT * FROM groups WHERE specialty = 'Временная';   


DELETE FROM groups WHERE group_name = 'ВРЕМ-01';



CREATE VIEW v_students_with_groups AS
SELECT
    s.student_id,
    s.last_name || ' ' || s.first_name AS full_name,
    s.birth_date,
    g.group_name,
    g.specialty
FROM students s
JOIN groups g ON s.group_id = g.group_id;

SELECT * FROM v_students_with_groups WHERE group_name = 'П-21';

DROP VIEW v_students_with_groups;


CREATE INDEX idx_students_last_name ON students(last_name);   -- поиск по фамилии
CREATE INDEX idx_lessons_date       ON lessons(lesson_date);  -- поиск по дате

EXPLAIN ANALYZE
SELECT * FROM students WHERE last_name = 'Иванов';


DROP INDEX idx_students_last_name;

CREATE TABLE IF NOT EXISTS grades (
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


INSERT INTO grades (student_id, discipline_id, grade, grade_date)
SELECT * FROM (VALUES
    (1, 1, 5, DATE '2026-09-15'),
    (1, 3, 4, DATE '2026-09-16'),
    (2, 1, 3, DATE '2026-09-15'),
    (2, 3, 5, DATE '2026-09-16'),
    (3, 1, 4, DATE '2026-09-17'),
    (3, 2, 5, DATE '2026-09-18'),
    (4, 2, 4, DATE '2026-09-18'),
    (4, 1, 3, DATE '2026-09-19'),
    (5, 2, 5, DATE '2026-09-20'),
    (5, 1, 4, DATE '2026-09-21')
) AS v(student_id, discipline_id, grade, grade_date)
WHERE NOT EXISTS (SELECT 1 FROM grades);


SELECT
    s.last_name || ' ' || s.first_name AS студент,
    ROUND(AVG(g.grade), 2) AS средний_балл
FROM grades g
JOIN students s ON g.student_id = s.student_id
GROUP BY s.student_id, s.last_name, s.first_name
ORDER BY средний_балл DESC;


SELECT
    d.discipline_name AS дисциплина,
    ROUND(AVG(g.grade), 2) AS средний_балл,
    COUNT(g.grade_id) AS количество_оценок
FROM grades g
JOIN disciplines d ON g.discipline_id = d.discipline_id
GROUP BY d.discipline_id, d.discipline_name
ORDER BY средний_балл DESC;


SELECT
    s.last_name || ' ' || s.first_name AS студент,
    d.discipline_name AS дисциплина,
    g.grade AS оценка,
    g.grade_date AS дата
FROM grades g
JOIN students s    ON g.student_id = s.student_id
JOIN disciplines d ON g.discipline_id = d.discipline_id
WHERE g.grade < 4
ORDER BY g.grade, s.last_name;


SELECT
    s.last_name || ' ' || s.first_name AS студент,
    ROUND(AVG(g.grade), 2) AS средний_балл
FROM grades g
JOIN students s ON g.student_id = s.student_id
GROUP BY s.student_id, s.last_name, s.first_name
HAVING AVG(g.grade) > 4.5
ORDER BY средний_балл DESC;

CREATE TABLE IF NOT EXISTS audit_log (
    log_id     SERIAL PRIMARY KEY,
    table_name VARCHAR(50),
    operation  VARCHAR(10),
    record_id  INT,
    old_data   JSONB,
    new_data   JSONB,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(50) DEFAULT CURRENT_USER
);


CREATE OR REPLACE FUNCTION audit_students_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, operation, record_id, new_data)
        VALUES ('students', 'INSERT', NEW.student_id, to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, operation, record_id, old_data, new_data)
        VALUES ('students', 'UPDATE', NEW.student_id, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, operation, record_id, old_data)
        VALUES ('students', 'DELETE', OLD.student_id, to_jsonb(OLD));
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_students_audit
AFTER INSERT OR UPDATE OR DELETE ON students
FOR EACH ROW EXECUTE FUNCTION audit_students_changes();


INSERT INTO students (last_name, first_name, birth_date, group_id)
VALUES ('Новиков', 'Пётр', '2007-05-05', 1);

UPDATE students SET first_name = 'Петр' WHERE last_name = 'Новиков';

DELETE FROM students WHERE last_name = 'Новиков';

SELECT * FROM audit_log ORDER BY changed_at, log_id;   -- 3 записи: INSERT, UPDATE, DELETE


CREATE OR REPLACE FUNCTION check_grade_range()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.grade < 2 OR NEW.grade > 5 THEN
        RAISE EXCEPTION 'Оценка должна быть от 2 до 5, получено: %', NEW.grade;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_grade
BEFORE INSERT OR UPDATE ON grades
FOR EACH ROW EXECUTE FUNCTION check_grade_range();


DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'teacher_role') THEN
        CREATE ROLE teacher_role;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'student_role') THEN
        CREATE ROLE student_role;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'teacher_ivanov') THEN
        CREATE USER teacher_ivanov WITH PASSWORD 'secure_password_1';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'student_petrov') THEN
        CREATE USER student_petrov WITH PASSWORD 'secure_password_2';
    END IF;
END $$;

-- Назначаем роли
GRANT teacher_role TO teacher_ivanov;
GRANT student_role TO student_petrov;


GRANT SELECT ON students    TO teacher_role;
GRANT SELECT ON lessons     TO teacher_role;
GRANT SELECT ON groups      TO teacher_role;
GRANT SELECT ON disciplines TO teacher_role;


CREATE TABLE IF NOT EXISTS user_students (
    db_user    VARCHAR(50) PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(student_id) ON DELETE CASCADE
);

INSERT INTO user_students (db_user, student_id)
SELECT 'student_petrov', student_id
FROM students
WHERE last_name = 'Петров'
ON CONFLICT (db_user) DO NOTHING;

CREATE OR REPLACE VIEW v_my_grades AS
SELECT
    gr.grade_id,
    s.student_id,
    d.discipline_name,
    gr.grade,
    gr.grade_date
FROM grades gr
JOIN students s    ON gr.student_id = s.student_id
JOIN disciplines d ON gr.discipline_id = d.discipline_id
JOIN user_students us ON us.student_id = s.student_id
WHERE us.db_user = current_user;      

GRANT SELECT ON v_my_grades TO student_role;

SET ROLE student_petrov;
SELECT * FROM v_my_grades;       
SELECT * FROM students;           
RESET ROLE;

SET ROLE teacher_ivanov;
SELECT * FROM students;           
DELETE FROM students;             
RESET ROLE;

