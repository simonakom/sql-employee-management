----------------Company table----------------------------------------------------------------------

CREATE TABLE company (
    company_id SERIAL PRIMARY KEY,                
    company_name VARCHAR(100) NOT NULL,           
    address VARCHAR(255) NOT NULL,               
    phone_number VARCHAR(15) NOT NULL            
);

INSERT INTO company (company_name, address, phone_number) VALUES 
('TechCorp', '123 Tech Street', '123-45678'),
('MedCorp', '456 Wellness Street', '567-384645'),
('CosmeticsCorp', '789 Beauty Street', '767-86535'),
('FoodCorp', '275 Gourmet Street', '456-87543');

SELECT * FROM company

----------------Employee table (without salary)----------------------------------------------------

CREATE TABLE employee (
    employee_id SERIAL PRIMARY KEY,      
	company_id INT NOT NULL,
    forename VARCHAR(100) NOT NULL,       
    surname VARCHAR(100) NOT NULL,       
    birth_date DATE NOT NULL,           
    sex VARCHAR(10) CHECK (sex IN ('Male', 'Female', 'Other')) NOT NULL, 
    FOREIGN KEY (company_id) REFERENCES company (company_id)
);

----------------Employee table (with salary)-------------------------------------------------------

--> Add salary_type column with default value and constraints
ALTER TABLE employee
ADD COLUMN salary_type VARCHAR(10) CHECK (salary_type IN ('Hourly', 'Monthly', 'None')) DEFAULT 'None' NOT NULL;

--> Add salary column with default value
ALTER TABLE employee
ADD COLUMN salary DECIMAL(10, 2) DEFAULT 0.00 NOT NULL;

INSERT INTO employee (company_id, forename, surname, birth_date, sex, salary_type, salary) 
VALUES 
(1, 'John', 'Doe', '1985-03-10', 'Male', 'Monthly', 5000),  
(2, 'Jane', 'Smith', '1990-07-25', 'Female', 'Hourly', 30),  
(4, 'Chris', 'Miller', '1987-06-22', 'Female', 'Monthly', 5500), 
(4, 'Sophia', 'Taylor', '1996-05-05', 'Female', 'Hourly', 27),   
(1, 'Alice', 'Johnson', '1988-11-15', 'Female', 'Monthly', 4500);

--> Insert without specifying salary_type and salary (uses default values)
INSERT INTO employee (company_id, forename, surname, birth_date, sex) 
VALUES 
(4, 'Laura', 'White', '1989-08-17', 'Female'), 	               ----> Default salary_type ('None') and salary (0.00)
(3, 'Michael', 'Wilson', '1993-03-30', 'Male'), 	
(1, 'Kevin', 'Moore', '1991-01-22', 'Male'); 		

SELECT * FROM employee

-------------------Queries-------------------------------------------------------------------------

--1. Select the company name which employs most females

SELECT company.company_name, COUNT(employee.employee_id) AS female_count     -----> selects the company_name from company table and counts the number of female employees in each company by counting the employee_id from the employee table
FROM employee                                                                -----> data from the employee table
JOIN company ON employee.company_id = company.company_id                     -----> matches rows where company_id from employee table equals the company_id in company table
WHERE employee.sex = 'Female'                                                -----> filters the employees to include only female
GROUP BY company.company_name                                                -----> groups the result by company_name
ORDER BY female_count DESC                                                   -----> sorting descending order
LIMIT 1;                                                                     -----> limits the result to only 1 row (first)

--2. Select the company name which pays the highest monthly salary (do not convert to hourly rate)

SELECT company.company_name, MAX(employee.salary) AS highest_monthly_salary   -----> selects the company_name from company table and MAX function calculates the maximum salary for employees in each company where the salary type is 'Monthly'
FROM employee                                                                 -----> data from the employee table
JOIN company ON employee.company_id = company.company_id                      -----> matches rows where company_id from employee table equals the company_id in company table
WHERE employee.salary_type = 'Monthly'                                        -----> considering employees who have a monthly salary
GROUP BY company.company_name                                                 -----> groups the result by company_name                 
ORDER BY highest_monthly_salary DESC                                          -----> sorting descending order
LIMIT 1;                                                                      -----> limits the result to only 1 row (first)

-- 3. Find all employees who do not have a salary

SELECT employee.forename, employee.surname, company.company_name
FROM employee
JOIN company ON employee.company_id = company.company_id                    -----> join the employee table with the company table using the company_id
WHERE employee.salary_type = 'None'                                         -----> check if salary_type is set to 'None'
  AND employee.salary = 0.00;                                               -----> check if salary is 0.00


---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
----------------Employee may have more than company (many-to-many)---------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Table to link employees and companies

CREATE TABLE employee_company (
    PRIMARY KEY (employee_id, company_id),                                   ----->  uniqueness of the pair
    employee_id INT,
    company_id INT,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    FOREIGN KEY (company_id) REFERENCES company(company_id)
);

INSERT INTO employee_company (employee_id, company_id) VALUES
(1, 1),  
(1, 2),  
(2, 2),  
(3, 1),  
(4, 3),  
(5, 4), 
(6, 2),  
(7, 2);  

SELECT * FROM employee_company

-------------------Queries-------------------------------------------------------------------------

--1. Select the company name wich employs the most females

SELECT company.company_name, COUNT(employee.employee_id) AS female_count
FROM employee
JOIN employee_company ON employee.employee_id = employee_company.employee_id
JOIN company ON employee_company.company_id = company.company_id
WHERE employee.sex = 'Female'
GROUP BY company.company_name
ORDER BY female_count DESC
LIMIT 1;

--2. Select the company name which pays the highest monthly salary

SELECT company.company_name, MAX(employee.salary) AS highest_monthly_salary
FROM employee
JOIN employee_company ON employee.employee_id = employee_company.employee_id
JOIN company ON employee_company.company_id = company.company_id
WHERE employee.salary_type = 'Monthly'
GROUP BY company.company_name
ORDER BY highest_monthly_salary DESC
LIMIT 1;

--3. Find all employees who do not have a salary

SELECT employee.forename, employee.surname, company.company_name
FROM employee
JOIN employee_company ON employee.employee_id = employee_company.employee_id
JOIN company ON employee_company.company_id = company.company_id
WHERE employee.salary_type = 'None'  
  AND employee.salary = 0.00;        

