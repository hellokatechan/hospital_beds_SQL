-- create database /schema 
DROP DATABASE IF EXISTS Hospital;
CREATE DATABASE Hospital;
USE Hospital;

-- import business csv using import wizard 
SELECT *
FROM business;

ALTER TABLE business
MODIFY COLUMN ims_org_id VARCHAR(15) PRIMARY KEY,
MODIFY COLUMN business_name VARCHAR(255) DEFAULT NULL,
MODIFY COLUMN ttl_license_beds INT,
MODIFY COLUMN ttl_census_beds INT,
MODIFY COLUMN ttl_staffed_beds INT,
MODIFY COLUMN bed_cluster_id VARCHAR(1) DEFAULT NULL;

-- import bed_type csv using import wizard 
SELECT * 
FROM bed_type;

ALTER TABLE bed_type
MODIFY COLUMN bed_id VARCHAR(2) PRIMARY KEY,
MODIFY COLUMN bed_code VARCHAR(2) DEFAULT NULL,
MODIFY COLUMN bed_desc VARCHAR(50) DEFAULT NULL;

-- import bed_fact csv using import wizard
-- check if bed_fact has been imported successfully 
SELECT * 
FROM bed_fact;

ALTER TABLE bed_fact
MODIFY COLUMN ims_org_id VARCHAR(13) DEFAULT NULL,
MODIFY COLUMN bed_id VARCHAR(2) DEFAULT NULL, 
MODIFY COLUMN license_beds INT,
MODIFY COLUMN census_beds INT,
MODIFY COLUMN staffed_beds INT,
ADD CONSTRAINT fk_ims_org_id 
	FOREIGN KEY (ims_org_id)
    REFERENCES business (ims_org_id),
ADD CONSTRAINT fk_bed_id
	FOREIGN KEY (bed_id)
    REFERENCES bed_type (bed_id);


-- EDA (Jump to line 79 for homework questions) 
-- how many unique business/org is within the business table? 22202 
SELECT COUNT(DISTINCT business.ims_org_id)
FROM business; 
-- how many hospitals have unit ICU or unit SICU?
SELECT COUNT(DISTINCT business.ims_org_id)
FROM bed_fact 
JOIN business
ON bed_fact.ims_org_id = business.ims_org_id
WHERE bed_fact.bed_id = 4 OR bed_fact.bed_id =15;  
-- How many unique hospitals? 22192
SELECT COUNT(DISTINCT business.ims_org_id)
FROM bed_fact
JOIN business
ON bed_fact.ims_org_id = business.ims_org_id; 
-- First, test out the left join
SELECT business.business_name, license_beds, census_beds, staffed_beds
FROM business
LEFT JOIN bed_fact
ON bed_fact.ims_org_id = business.ims_org_id; 
-- Which hospitals have unit ICU OR unit SICU? 3551 
SELECT COUNT(business_name)
FROM bed_fact
LEFT JOIN business
ON bed_fact.ims_org_id = business.ims_org_id
WHERE bed_id IN(15,4);
-- Which hopitals have unit ICU AND unit SICU? 179
SELECT COUNT(business_name)
FROM bed_fact
JOIN business
ON bed_fact.ims_org_id = business.ims_org_id
WHERE bed_id = 15 AND bed_fact.ims_org_id IN(SELECT bed_fact.ims_org_id FROM bed_fact WHERE bed_id =4); 

-- Question 4a: Show the top 10 hospitals that have bed_id 15 or bed_id 4
-- For license beds
SELECT RANK() OVER(ORDER BY SUM(license_beds) DESC), business_name, SUM(license_beds) AS total_license_beds
FROM bed_fact
JOIN business
ON bed_fact.ims_org_id = business.ims_org_id
WHERE bed_id IN(15,4)
GROUP BY business_name
ORDER BY SUM(license_beds) DESC LIMIT 10;

-- For census beds
SELECT RANK() OVER(ORDER BY SUM(census_beds) DESC), business_name, SUM(census_beds) AS total_census_beds
FROM bed_fact
JOIN business
ON bed_fact.ims_org_id = business.ims_org_id
WHERE bed_id IN(15,4)
GROUP BY business_name
ORDER BY SUM(census_beds) DESC LIMIT 10;

-- For staffed beds
SELECT RANK() OVER(ORDER BY SUM(staffed_beds) DESC), business_name, SUM(staffed_beds) AS total_staffed_beds
FROM bed_fact
JOIN business
ON bed_fact.ims_org_id = business.ims_org_id
WHERE bed_id IN (15,4) 
OR bed_id = 15
OR bed_id = 4
GROUP BY business_name
ORDER BY SUM(staffed_beds) DESC LIMIT 10;

-- Question 5a: Show the top 10 hospitals that have both bed_id 15 and bed_id 4
-- For License Beds 
SELECT RANK() OVER(ORDER BY SUM(license_beds) DESC), business_name, SUM(license_beds) AS total_license_beds
FROM bed_fact
LEFT JOIN business
ON bed_fact.ims_org_id = business.ims_org_id
WHERE bed_id = 15 AND bed_fact.ims_org_id IN(SELECT bed_fact.ims_org_id FROM bed_fact WHERE bed_id =4) 
GROUP BY business_name
ORDER BY SUM(license_beds) DESC LIMIT 10; 

-- For Census Beds
SELECT RANK() OVER(ORDER BY SUM(census_beds) DESC), business_name, SUM(census_beds) AS total_census_beds
FROM bed_fact
LEFT JOIN business
ON bed_fact.ims_org_id = business.ims_org_id
WHERE bed_id = 15 AND bed_fact.ims_org_id IN(SELECT bed_fact.ims_org_id FROM bed_fact WHERE bed_id =4) 
GROUP BY business_name
ORDER BY SUM(census_beds) DESC LIMIT 10;

-- For Staffed Beds
SELECT RANK() OVER(ORDER BY SUM(staffed_beds) DESC), business_name, SUM(staffed_beds) AS total_staffed_beds
FROM bed_fact
LEFT JOIN business
ON bed_fact.ims_org_id = business.ims_org_id
WHERE bed_id = 15 AND bed_fact.ims_org_id IN(SELECT bed_fact.ims_org_id FROM bed_fact WHERE bed_id =4) 
GROUP BY business_name
ORDER BY SUM(staffed_beds) DESC LIMIT 10; 

-- test line
SELECT * 
FROM bed_fact

