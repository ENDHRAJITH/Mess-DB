-- ============================================
-- MESS MANAGEMENT SYSTEM - ENHANCED DATABASE
-- With Triggers, Views, and Indexes
-- ============================================

CREATE DATABASE IF NOT EXISTS mess_management;
USE mess_management;

-- ============================================
-- TABLES
-- ============================================

CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin','student') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_username (username),
  INDEX idx_role (role)
);

CREATE TABLE students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  name VARCHAR(100),
  department VARCHAR(50),
  year INT,
  room_no VARCHAR(10),
  email VARCHAR(100),
  phone VARCHAR(15),
  status ENUM('active','inactive') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  INDEX idx_name (name),
  INDEX idx_department (department),
  INDEX idx_status (status),
  INDEX idx_room (room_no)
);

CREATE TABLE attendance (
  attendance_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT,
  date DATE,
  breakfast ENUM('present','absent') DEFAULT 'absent',
  lunch ENUM('present','absent') DEFAULT 'absent',
  dinner ENUM('present','absent') DEFAULT 'absent',
  day_status ENUM('present','leave') DEFAULT 'leave',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
  UNIQUE KEY unique_attendance (student_id, date),
  INDEX idx_date (date),
  INDEX idx_student_date (student_id, date),
  INDEX idx_day_status (day_status)
);

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
  payment_status ENUM('pending','paid') DEFAULT 'pending',
  payment_date TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
  UNIQUE KEY unique_bill (student_id, month, year),
  INDEX idx_month_year (month, year),
  INDEX idx_payment_status (payment_status)
);

CREATE TABLE payment_history (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  bill_id INT,
  student_id INT,
  amount INT,
  payment_method VARCHAR(50),
  transaction_id VARCHAR(100),
  payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (bill_id) REFERENCES monthly_bill(bill_id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
  INDEX idx_student_payment (student_id, payment_date)
);

-- ============================================
-- VIEWS
-- ============================================

-- View: Active Students with Full Details
CREATE OR REPLACE VIEW vw_active_students AS
SELECT 
  s.student_id,
  s.name,
  s.department,
  s.year,
  s.room_no,
  s.email,
  s.phone,
  u.username,
  s.created_at
FROM students s
JOIN users u ON s.user_id = u.user_id
WHERE s.status = 'active'
ORDER BY s.name;

-- View: Monthly Attendance Summary
CREATE OR REPLACE VIEW vw_monthly_attendance_summary AS
SELECT 
  s.student_id,
  s.name,
  s.department,
  MONTH(a.date) as month,
  YEAR(a.date) as year,
  COUNT(*) as total_records,
  SUM(CASE WHEN a.day_status = 'present' THEN 1 ELSE 0 END) as present_days,
  SUM(CASE WHEN a.day_status = 'leave' THEN 1 ELSE 0 END) as leave_days,
  ROUND(SUM(CASE WHEN a.day_status = 'present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as attendance_percentage
FROM students s
LEFT JOIN attendance a ON s.student_id = a.student_id
WHERE s.status = 'active'
GROUP BY s.student_id, s.name, s.department, MONTH(a.date), YEAR(a.date);

-- View: Outstanding Bills
CREATE OR REPLACE VIEW vw_outstanding_bills AS
SELECT 
  s.student_id,
  s.name,
  s.department,
  s.room_no,
  mb.bill_id,
  mb.month,
  mb.year,
  mb.total_amount,
  mb.payment_status,
  DATEDIFF(CURRENT_DATE, mb.created_at) as days_pending
FROM students s
JOIN monthly_bill mb ON s.student_id = mb.student_id
WHERE mb.payment_status = 'pending'
ORDER BY mb.year DESC, mb.month DESC;

-- View: Student Payment History
CREATE OR REPLACE VIEW vw_student_payment_history AS
SELECT 
  s.student_id,
  s.name,
  ph.payment_id,
  ph.amount,
  ph.payment_method,
  ph.transaction_id,
  ph.payment_date,
  mb.month,
  mb.year
FROM students s
JOIN payment_history ph ON s.student_id = ph.student_id
JOIN monthly_bill mb ON ph.bill_id = mb.bill_id
ORDER BY ph.payment_date DESC;

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger: Auto-calculate day_status before insert
DELIMITER $$
CREATE TRIGGER trg_attendance_before_insert
BEFORE INSERT ON attendance
FOR EACH ROW
BEGIN
  IF (NEW.breakfast = 'present' OR NEW.lunch = 'present' OR NEW.dinner = 'present') THEN
    SET NEW.day_status = 'present';
  ELSE
    SET NEW.day_status = 'leave';
  END IF;
END$$
DELIMITER ;

-- Trigger: Auto-calculate day_status before update
DELIMITER $$
CREATE TRIGGER trg_attendance_before_update
BEFORE UPDATE ON attendance
FOR EACH ROW
BEGIN
  IF (NEW.breakfast = 'present' OR NEW.lunch = 'present' OR NEW.dinner = 'present') THEN
    SET NEW.day_status = 'present';
  ELSE
    SET NEW.day_status = 'leave';
  END IF;
END$$
DELIMITER ;

-- Trigger: Update bill payment status when payment is made
DELIMITER $$
CREATE TRIGGER trg_payment_after_insert
AFTER INSERT ON payment_history
FOR EACH ROW
BEGIN
  UPDATE monthly_bill 
  SET payment_status = 'paid', 
      payment_date = NEW.payment_date
  WHERE bill_id = NEW.bill_id;
END$$
DELIMITER ;

-- Trigger: Prevent deletion of students with unpaid bills
DELIMITER $$
CREATE TRIGGER trg_prevent_student_delete
BEFORE DELETE ON students
FOR EACH ROW
BEGIN
  DECLARE unpaid_bills INT;
  
  SELECT COUNT(*) INTO unpaid_bills
  FROM monthly_bill
  WHERE student_id = OLD.student_id AND payment_status = 'pending';
  
  IF unpaid_bills > 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot delete student with unpaid bills';
  END IF;
END$$
DELIMITER ;

-- ============================================
-- SAMPLE DATA
-- ============================================

-- Admin User
INSERT INTO users (username, password, role) VALUES ('admin', 'admin@123', 'admin');

-- 20 Student Users
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
INSERT INTO students (user_id, name, department, year, room_no, email, phone, status) VALUES 
(2, 'Rajesh Kumar', 'Computer Science', 2, 'A101', 'rajesh@college.edu', '9876543210', 'active'),
(3, 'Priya Sharma', 'Electronics', 3, 'B205', 'priya@college.edu', '9876543211', 'active'),
(4, 'Arun Prakash', 'Mechanical', 1, 'C304', 'arun@college.edu', '9876543212', 'active'),
(5, 'Divya Lakshmi', 'Civil', 2, 'A102', 'divya@college.edu', '9876543213', 'active'),
(6, 'Karthik Raja', 'Computer Science', 4, 'B206', 'karthik@college.edu', '9876543214', 'active'),
(7, 'Meena Kumari', 'Information Tech', 3, 'C305', 'meena@college.edu', '9876543215', 'active'),
(8, 'Vijay Anand', 'Electrical', 2, 'A103', 'vijay@college.edu', '9876543216', 'active'),
(9, 'Lakshmi Priya', 'Computer Science', 1, 'B207', 'lakshmi@college.edu', '9876543217', 'active'),
(10, 'Suresh Babu', 'Mechanical', 3, 'C306', 'suresh@college.edu', '9876543218', 'active'),
(11, 'Kavitha Devi', 'Electronics', 2, 'A104', 'kavitha@college.edu', '9876543219', 'active'),
(12, 'Ganesh Kumar', 'Civil', 4, 'B208', 'ganesh@college.edu', '9876543220', 'active'),
(13, 'Sangeetha Rani', 'Information Tech', 1, 'C307', 'sangeetha@college.edu', '9876543221', 'active'),
(14, 'Murugan Raj', 'Computer Science', 2, 'A105', 'murugan@college.edu', '9876543222', 'active'),
(15, 'Nithya Shree', 'Electrical', 3, 'B209', 'nithya@college.edu', '9876543223', 'active'),
(16, 'Ramesh Kannan', 'Mechanical', 1, 'C308', 'ramesh@college.edu', '9876543224', 'active'),
(17, 'Deepa Lakshmi', 'Electronics', 4, 'A106', 'deepa@college.edu', '9876543225', 'active'),
(18, 'Senthil Kumar', 'Civil', 2, 'B210', 'senthil@college.edu', '9876543226', 'active'),
(19, 'Vasantha Devi', 'Information Tech', 3, 'C309', 'vasantha@college.edu', '9876543227', 'active'),
(20, 'Bala Murugan', 'Computer Science', 1, 'A107', 'bala@college.edu', '9876543228', 'active'),
(21, 'Anitha Rani', 'Electrical', 2, 'B211', 'anitha@college.edu', '9876543229', 'active');

-- Sample Attendance Data (Last 7 days for first 5 students)
INSERT INTO attendance (student_id, date, breakfast, lunch, dinner) VALUES
-- Student 1 - Rajesh Kumar
(1, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'present', 'present', 'present'),
(1, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'present', 'absent', 'present'),
(1, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 'absent', 'absent', 'absent'),
(1, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'present', 'present', 'present'),
(1, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'present', 'present', 'absent'),
(1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'present', 'present', 'present'),
(1, CURDATE(), 'present', 'present', 'present'),

-- Student 2 - Priya Sharma
(2, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'present', 'present', 'present'),
(2, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'present', 'present', 'present'),
(2, DATE_SUB(CURDATE(), INTERVAL 4 DAY), 'present', 'absent', 'present'),
(2, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'absent', 'absent', 'absent'),
(2, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'absent', 'absent', 'absent'),
(2, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'present', 'present', 'present'),
(2, CURDATE(), 'present', 'present', 'present');
