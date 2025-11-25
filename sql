-- ============================================
-- MESS MANAGEMENT SYSTEM - DATABASE SETUP
-- ============================================

-- Create Database
CREATE DATABASE IF NOT EXISTS mess_management;
USE mess_management;

-- ============================================
-- TABLE: users
-- Stores login credentials for admin and students
-- ============================================
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin','student') NOT NULL
);

-- ============================================
-- TABLE: students
-- Stores student personal details
-- ============================================
CREATE TABLE students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  name VARCHAR(100),
  department VARCHAR(50),
  year INT,
  room_no VARCHAR(10),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================
-- TABLE: attendance
-- Stores daily meal attendance (3 slots)
-- ============================================
CREATE TABLE attendance (
  attendance_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT,
  date DATE,
  breakfast ENUM('present','absent') DEFAULT 'absent',
  lunch ENUM('present','absent') DEFAULT 'absent',
  dinner ENUM('present','absent') DEFAULT 'absent',
  day_status ENUM('present','leave') DEFAULT 'leave',
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

-- ============================================
-- TABLE: monthly_bill
-- Stores calculated monthly bills
-- ============================================
CREATE TABLE monthly_bill (
  bill_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT,
  month INT,
  year INT,
  total_days INT,
  leave_days INT,
  present_days INT,
  amount_per_day INT DEFAULT 108,
  total_amount INT,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

-- ============================================
-- INSERT SAMPLE DATA
-- ============================================

-- Admin User (username: admin, password: admin@123)
INSERT INTO users (username, password, role) VALUES ('admin', 'admin@123', 'admin');

-- 20 Student Users (username: student1-20, password: student@123)
INSERT INTO users (username, password, role) VALUES 
('student1', 'student@123', 'student'),
('student2', 'student@123', 'student'),
('student3', 'student@123', 'student'),
('student4', 'student@123', 'student'),
('student5', 'student@123', 'student'),
('student6', 'student@123', 'student'),
('student7', 'student@123', 'student'),
('student8', 'student@123', 'student'),
('student9', 'student@123', 'student'),
('student10', 'student@123', 'student'),
('student11', 'student@123', 'student'),
('student12', 'student@123', 'student'),
('student13', 'student@123', 'student'),
('student14', 'student@123', 'student'),
('student15', 'student@123', 'student'),
('student16', 'student@123', 'student'),
('student17', 'student@123', 'student'),
('student18', 'student@123', 'student'),
('student19', 'student@123', 'student'),
('student20', 'student@123', 'student');

-- 20 Student Details
INSERT INTO students (user_id, name, department, year, room_no) VALUES 
(2, 'Rajesh Kumar', 'Computer Science', 2, 'A101'),
(3, 'Priya Sharma', 'Electronics', 3, 'B205'),
(4, 'Arun Prakash', 'Mechanical', 1, 'C304'),
(5, 'Divya Lakshmi', 'Civil', 2, 'A102'),
(6, 'Karthik Raja', 'Computer Science', 4, 'B206'),
(7, 'Meena Kumari', 'Information Tech', 3, 'C305'),
(8, 'Vijay Anand', 'Electrical', 2, 'A103'),
(9, 'Lakshmi Priya', 'Computer Science', 1, 'B207'),
(10, 'Suresh Babu', 'Mechanical', 3, 'C306'),
(11, 'Kavitha Devi', 'Electronics', 2, 'A104'),
(12, 'Ganesh Kumar', 'Civil', 4, 'B208'),
(13, 'Sangeetha Rani', 'Information Tech', 1, 'C307'),
(14, 'Murugan Raj', 'Computer Science', 2, 'A105'),
(15, 'Nithya Shree', 'Electrical', 3, 'B209'),
(16, 'Ramesh Kannan', 'Mechanical', 1, 'C308'),
(17, 'Deepa Lakshmi', 'Electronics', 4, 'A106'),
(18, 'Senthil Kumar', 'Civil', 2, 'B210'),
(19, 'Vasantha Devi', 'Information Tech', 3, 'C309'),
(20, 'Bala Murugan', 'Computer Science', 1, 'A107'),
(21, 'Anitha Rani', 'Electrical', 2, 'B211');

-- Sample Attendance Data (Last 7 days for first 5 students)
INSERT INTO attendance (student_id, date, breakfast, lunch, dinner, day_status) VALUES
-- Student 1 - Rajesh Kumar
(1, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'present', 'present', 'present', 'present'),
(1, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'present', 'absent', 'present', 'present'),
(1, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 'absent', 'absent', 'absent', 'leave'),
(1, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'present', 'present', 'present', 'present'),
(1, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'present', 'present', 'absent', 'present'),
(1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'present', 'present', 'present', 'present'),
(1, CURDATE(), 'present', 'present', 'present', 'present'),

-- Student 2 - Priya Sharma
(2, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'present', 'present', 'present', 'present'),
(2, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'present', 'present', 'present', 'present'),
(2, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 'present', 'absent', 'present', 'present'),
(2, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'absent', 'absent', 'absent', 'leave'),
(2, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'absent', 'absent', 'absent', 'leave'),
(2, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'present', 'present', 'present', 'present'),
(2, CURDATE(), 'present', 'present', 'present', 'present');-- ============================================
-- MESS MANAGEMENT SYSTEM - DATABASE SETUP
-- ============================================

-- Create Database
CREATE DATABASE IF NOT EXISTS mess_management;
USE mess_management;

-- ============================================
-- TABLE: users
-- Stores login credentials for admin and students
-- ============================================
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin','student') NOT NULL
);

-- ============================================
-- TABLE: students
-- Stores student personal details
-- ============================================
CREATE TABLE students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  name VARCHAR(100),
  department VARCHAR(50),
  year INT,
  room_no VARCHAR(10),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================
-- TABLE: attendance
-- Stores daily meal attendance (3 slots)
-- ============================================
CREATE TABLE attendance (
  attendance_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT,
  date DATE,
  breakfast ENUM('present','absent') DEFAULT 'absent',
  lunch ENUM('present','absent') DEFAULT 'absent',
  dinner ENUM('present','absent') DEFAULT 'absent',
  day_status ENUM('present','leave') DEFAULT 'leave',
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

-- ============================================
-- TABLE: monthly_bill
-- Stores calculated monthly bills
-- ============================================
CREATE TABLE monthly_bill (
  bill_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT,
  month INT,
  year INT,
  total_days INT,
  leave_days INT,
  present_days INT,
  amount_per_day INT DEFAULT 108,
  total_amount INT,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

-- ============================================
-- INSERT SAMPLE DATA
-- ============================================

-- Admin User (username: admin, password: admin@123)
INSERT INTO users (username, password, role) VALUES ('admin', 'admin@123', 'admin');

-- 20 Student Users (username: student1-20, password: student@123)
INSERT INTO users (username, password, role) VALUES 
('student1', 'student@123', 'student'),
('student2', 'student@123', 'student'),
('student3', 'student@123', 'student'),
('student4', 'student@123', 'student'),
('student5', 'student@123', 'student'),
('student6', 'student@123', 'student'),
('student7', 'student@123', 'student'),
('student8', 'student@123', 'student'),
('student9', 'student@123', 'student'),
('student10', 'student@123', 'student'),
('student11', 'student@123', 'student'),
('student12', 'student@123', 'student'),
('student13', 'student@123', 'student'),
('student14', 'student@123', 'student'),
('student15', 'student@123', 'student'),
('student16', 'student@123', 'student'),
('student17', 'student@123', 'student'),
('student18', 'student@123', 'student'),
('student19', 'student@123', 'student'),
('student20', 'student@123', 'student');

-- 20 Student Details
INSERT INTO students (user_id, name, department, year, room_no) VALUES 
(2, 'Rajesh Kumar', 'Computer Science', 2, 'A101'),
(3, 'Priya Sharma', 'Electronics', 3, 'B205'),
(4, 'Arun Prakash', 'Mechanical', 1, 'C304'),
(5, 'Divya Lakshmi', 'Civil', 2, 'A102'),
(6, 'Karthik Raja', 'Computer Science', 4, 'B206'),
(7, 'Meena Kumari', 'Information Tech', 3, 'C305'),
(8, 'Vijay Anand', 'Electrical', 2, 'A103'),
(9, 'Lakshmi Priya', 'Computer Science', 1, 'B207'),
(10, 'Suresh Babu', 'Mechanical', 3, 'C306'),
(11, 'Kavitha Devi', 'Electronics', 2, 'A104'),
(12, 'Ganesh Kumar', 'Civil', 4, 'B208'),
(13, 'Sangeetha Rani', 'Information Tech', 1, 'C307'),
(14, 'Murugan Raj', 'Computer Science', 2, 'A105'),
(15, 'Nithya Shree', 'Electrical', 3, 'B209'),
(16, 'Ramesh Kannan', 'Mechanical', 1, 'C308'),
(17, 'Deepa Lakshmi', 'Electronics', 4, 'A106'),
(18, 'Senthil Kumar', 'Civil', 2, 'B210'),
(19, 'Vasantha Devi', 'Information Tech', 3, 'C309'),
(20, 'Bala Murugan', 'Computer Science', 1, 'A107'),
(21, 'Anitha Rani', 'Electrical', 2, 'B211');

-- Sample Attendance Data (Last 7 days for first 5 students)
INSERT INTO attendance (student_id, date, breakfast, lunch, dinner, day_status) VALUES
-- Student 1 - Rajesh Kumar
(1, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'present', 'present', 'present', 'present'),
(1, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'present', 'absent', 'present', 'present'),
(1, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 'absent', 'absent', 'absent', 'leave'),
(1, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'present', 'present', 'present', 'present'),
(1, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'present', 'present', 'absent', 'present'),
(1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'present', 'present', 'present', 'present'),
(1, CURDATE(), 'present', 'present', 'present', 'present'),

-- Student 2 - Priya Sharma
(2, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'present', 'present', 'present', 'present'),
(2, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'present', 'present', 'present', 'present'),
(2, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 'present', 'absent', 'present', 'present'),
(2, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'absent', 'absent', 'absent', 'leave'),
(2, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'absent', 'absent', 'absent', 'leave'),
(2, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'present', 'present', 'present', 'present'),
(2, CURDATE(), 'present', 'present', 'present', 'present');
