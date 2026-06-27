-- TASK 1: Create the Database and Tables (DDL)
CREATE DATABASE college_db;
USE college_db;

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL,
    hod_name VARCHAR(100),
    budget DECIMAL(12,2)
);

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    date_of_birth DATE,
    department_id INT,
    enrollment_year INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(150) NOT NULL,
    course_code VARCHAR(20) UNIQUE,
    credits INT,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    grade CHAR(2),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

CREATE TABLE professors (
    professor_id INT PRIMARY KEY AUTO_INCREMENT,
    prof_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);


-- TASK 2: Verify Normalisation Analysis
-- 1NF Compliance: Every column holds atomic (single) values. There are no repeating groups or multi-valued fields. If we had stored multiple phone numbers in a single string, it would violate 1NF.
-- 2NF Compliance: The schema satisfies 1NF and all non-key attributes are fully functionally dependent on the primary key. In 'enrollments', the fields depend directly on the primary key 'enrollment_id'.
-- 3NF Compliance: The schema is in 2NF and has no transitive dependencies. Non-key attributes depend only on the primary key. For example, storing 'dept_name' directly in the 'students' table would violate 3NF because 'dept_name' relies on 'department_id', which relies on 'student_id'.


-- TASK 3: Alter and Extend the Schema
ALTER TABLE students ADD COLUMN phone_number VARCHAR(15);

ALTER TABLE courses ADD COLUMN max_seats INT DEFAULT 60;

ALTER TABLE enrollments ADD CONSTRAINT chk_grade CHECK (grade IN ('A', 'B', 'C', 'D', 'F') OR grade IS NULL);

ALTER TABLE departments CHANGE COLUMN hod_name head_of_dept VARCHAR(100);

ALTER TABLE students DROP COLUMN phone_number;
