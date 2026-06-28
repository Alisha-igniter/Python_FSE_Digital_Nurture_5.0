USE college_db;

-- TASK 1: Subqueries

SELECT student_id, first_name, last_name 
FROM students 
WHERE student_id IN (
    SELECT student_id FROM enrollments 
    GROUP BY student_id 
    HAVING COUNT(course_id) > (
        SELECT AVG(course_count) FROM (
            SELECT COUNT(course_id) AS course_count FROM enrollments GROUP BY student_id
        ) AS temp
    )
);

SELECT course_id, course_name FROM courses c
WHERE EXISTS (SELECT 1 FROM enrollments e WHERE e.course_id = c.course_id)
AND NOT EXISTS (SELECT 1 FROM enrollments e WHERE e.course_id = c.course_id AND (e.grade != 'A' OR e.grade IS NULL));

SELECT p1.prof_name, p1.department_id, p1.salary
FROM professors p1
WHERE p1.salary = (
    SELECT MAX(p2.salary) 
    FROM professors p2 
    WHERE p2.department_id = p1.department_id
);

SELECT dept_summary.dept_name, dept_summary.avg_salary
FROM (
    SELECT d.dept_name, AVG(p.salary) AS avg_salary
    FROM departments d
    JOIN professors p ON d.department_id = p.department_id
    GROUP BY d.department_id, d.dept_name
) AS dept_summary
WHERE dept_summary.avg_salary > 85000;


-- TASK 2: Creating and Using Views

CREATE OR REPLACE VIEW vw_student_enrollment_summary AS
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS full_name,
    d.dept_name,
    COUNT(e.course_id) AS courses_enrolled,
    AVG(CASE e.grade 
        WHEN 'A' THEN 4 
        WHEN 'B' THEN 3 
        WHEN 'C' THEN 2 
        WHEN 'D' THEN 1 
        WHEN 'F' THEN 0 
        ELSE NULL 
    END) AS GPA
FROM students s
LEFT JOIN departments d ON s.department_id = d.department_id
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, d.dept_name;

CREATE OR REPLACE VIEW vw_course_stats AS
SELECT 
    c.course_name,
    c.course_code,
    COUNT(e.enrollment_id) AS total_enrollments,
    AVG(CASE e.grade 
        WHEN 'A' THEN 4 
        WHEN 'B' THEN 3 
        WHEN 'C' THEN 2 
        WHEN 'D' THEN 1 
        WHEN 'F' THEN 0 
        ELSE NULL 
    END) AS avg_gpa
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name, c.course_code;

SELECT * FROM vw_student_enrollment_summary WHERE GPA > 3.0;


-- DROP both views and recreate a view subset WITH CHECK OPTION 
DROP VIEW IF EXISTS vw_student_enrollment_summary;
DROP VIEW IF EXISTS vw_course_stats;

CREATE VIEW vw_cs_students_subset AS
SELECT student_id, first_name, last_name, department_id, enrollment_year 
FROM students 
WHERE department_id = 1
WITH CHECK OPTION;


-- TASK 3: Stored Procedures and Transactions

CREATE TABLE IF NOT EXISTS department_transfer_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    old_dept_id INT,
    new_dept_id INT,
    transfer_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE PROCEDURE sp_enroll_student(IN p_student_id INT, IN p_course_id INT, IN p_enroll_date DATE)
BEGIN
    DECLARE v_exists INT;
    SELECT COUNT(*) INTO v_exists FROM enrollments WHERE student_id = p_student_id AND course_id = p_course_id;
    
    IF v_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duplicate Enrollment Error: Student already enrolled in this course.';
    ELSE
        INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES (p_student_id, p_course_id, p_enroll_date, NULL);
    END IF;
END $$

CREATE PROCEDURE sp_transfer_student(IN p_student_id INT, IN p_new_dept_id INT)
BEGIN
    DECLARE v_old_dept_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;
        SELECT department_id INTO v_old_dept_id FROM students WHERE student_id = p_student_id;
        
        UPDATE students SET department_id = p_new_dept_id WHERE student_id = p_student_id;
        INSERT INTO department_transfer_log (student_id, old_dept_id, new_dept_id) VALUES (p_student_id, v_old_dept_id, p_new_dept_id);
    COMMIT;
END $$

DELIMITER ;

START TRANSACTION;
    INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES (1, 3, '2026-06-01', NULL);
    SAVEPOINT sp1;
COMMIT;