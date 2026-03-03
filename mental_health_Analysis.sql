----------------------------------
-- DATABASE CREATION
----------------------------------
CREATE DATABASE mental_health_project;
USE mental_health_project;

----------------------------------
-- TABLE CREATION
----------------------------------
CREATE TABLE mental_health_survey (
    gender VARCHAR(20),
    age INT,
    university VARCHAR(50),
    degree_level VARCHAR(50),
    degree_major VARCHAR(50),
    academic_year VARCHAR(10),
    cgpa varchar(10),
    residential_status varchar(50),
    campus_discrimination varchar(50),
    sports_engagement varchar(20),
    average_sleep varchar(20),
    study_satisfaction int,
    academic_workload int,
    academic_pressure INT,
    financial_concerns int,
    social_relationships INT,
    depression INT,
    anxiety int,
    self_efficacy INT,
    isolation int,
    future_insecurity int,
    stress_relief_activities VARCHAR(100),
    mental_health int
);


--------------------------------------------
-- Data Understanding
--------------------------------------------
SELECT COUNT(*) FROM mental_health_survey;

SELECT * FROM mental_health_survey LIMIT 5;

------------------------------------------
-- Data Cleaning
------------------------------------------
-- 1. check null values
SELECT *
FROM mental_health_survey
WHERE Age IS NULL OR depression IS NULL;  -- 0

SELECT 
COUNT(*) - COUNT(gender) AS gender_nulls,
COUNT(*) - COUNT(age) AS age_nulls,
COUNT(*) - COUNT(depression) AS depression_nulls
FROM mental_health_survey;

SELECT *
FROM mental_health_survey
WHERE age < 16 OR age > 40;

SELECT DISTINCT gender FROM mental_health_survey;

SELECT *
FROM mental_health_survey
WHERE depression NOT BETWEEN 1 AND 5;

SELECT DISTINCT average_sleep 
FROM mental_health_survey;

-- detect outliers
SELECT MIN(depression), MAX(depression) FROM mental_health_survey;

------------------------------------------------
-- Exploratory Data Analysis
------------------------------------------------
-- 1. Gender Distribution
SELECT gender, COUNT(*) AS total_students
FROM mental_health_survey
GROUP BY gender;

-- 2. Average Age
SELECT ROUND(AVG(age),2) AS average_age
FROM mental_health_survey;

-- 3. students by Academic Year
SELECT academic_year, COUNT(*) AS total
FROM mental_health_survey
GROUP BY academic_year
ORDER BY total DESC;

-- Mental Health Score Analysis
-- 4. Average Depression Level
SELECT ROUND(AVG(depression),2) AS avg_depression
FROM mental_health_survey;

-- 5. Average Anxiety Level
SELECT ROUND(AVG(anxiety),2) AS avg_anxiety
FROM mental_health_survey;

-- 6. Overall Mental Health Score
SELECT ROUND(AVG(mental_health),2) AS avg_mental_health
FROM mental_health_survey;

-- Find High-Risk Students
SELECT *
FROM mental_health_survey
WHERE depression >= 4
AND anxiety >= 4;

SELECT COUNT(*) AS high_risk_students
FROM mental_health_survey
WHERE depression >= 4
AND anxiety >= 4;

-- Gender vs Depression
SELECT gender,
       ROUND(AVG(depression),2) AS avg_depression
FROM mental_health_survey
GROUP BY gender;
-- Female students are experiencing more depression

-- Academic Pressure Impact
SELECT academic_pressure,
       ROUND(AVG(depression),2) AS avg_depression
FROM mental_health_survey
GROUP BY academic_pressure
ORDER BY academic_pressure;
-- Depression is increaing with pressure


-- Financial Concerns Impact
SELECT financial_concerns,
       ROUND(AVG(anxiety),2) AS avg_anxiety
FROM mental_health_survey
GROUP BY financial_concerns
ORDER BY financial_concerns;

-- Sleep vs Depression
SELECT average_sleep,
       ROUND(AVG(depression),2) AS avg_depression
FROM mental_health_survey
GROUP BY average_sleep;


-- Social Relationships vs Mental Health
SELECT social_relationships,
       ROUND(AVG(mental_health),2) AS avg_mh_score
FROM mental_health_survey
GROUP BY social_relationships
ORDER BY social_relationships;


-- Create Composite Mental Health Risk Score
-- Create Risk Score Column
ALTER TABLE mental_health_survey
ADD COLUMN risk_score INT;

SET SQL_SAFE_UPDATES = 0;

UPDATE mental_health_survey
SET risk_score =
    academic_pressure +
    financial_concerns +
    depression +
    anxiety +
    isolation +
    future_insecurity;
SET SQL_SAFE_UPDATES = 1;

-- Categorize Students by Risk Level
ALTER TABLE mental_health_survey
ADD COLUMN risk_category VARCHAR(20);

SET SQL_SAFE_UPDATES = 0;
UPDATE mental_health_survey
SET risk_category =
CASE 
    WHEN risk_score >= 20 THEN 'High Risk'
    WHEN risk_score BETWEEN 12 AND 19 THEN 'Moderate Risk'
    ELSE 'Low Risk'
END;
SET SQL_SAFE_UPDATES = 1;

-- Distribution of Risk Categories
SELECT risk_category, COUNT(*) AS total_students
FROM mental_health_survey
GROUP BY risk_category
ORDER BY total_students DESC;

-- Top 5 Highest Risk Students
SELECT *
FROM (
    SELECT *,
           RANK() OVER (ORDER BY risk_score DESC) AS risk_rank
    FROM mental_health_survey
) ranked
WHERE risk_rank <= 5;


-- Top Factors Affecting Depression
-- Academic Pressure Impact
SELECT academic_pressure,
       ROUND(AVG(depression),2) AS avg_depression
FROM mental_health_survey
GROUP BY academic_pressure
ORDER BY avg_depression DESC;

-- Financial Concern Impact
SELECT financial_concerns,
       ROUND(AVG(depression),2) AS avg_depression
FROM mental_health_survey
GROUP BY financial_concerns
ORDER BY avg_depression DESC;

-- Isolation Impact
SELECT isolation,
       ROUND(AVG(depression),2) AS avg_depression
FROM mental_health_survey
GROUP BY isolation
ORDER BY avg_depression DESC;

-- High Risk Percentage
SELECT 
ROUND(
    (SUM(CASE WHEN risk_category = 'High Risk' THEN 1 ELSE 0 END) 
    / COUNT(*)) * 100, 2
) AS high_risk_percentage
FROM mental_health_survey;