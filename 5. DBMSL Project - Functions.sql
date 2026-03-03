 use judicialcasedb;

-- 1. Function: Get_Judge_Experience
-- Use Case: Ensures experienced judges handle complex cases; aids in workload balancing.
DELIMITER //
CREATE FUNCTION Get_Judge_Experience(case_id INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE judge_experience INT;
    SELECT j.Experience_Years INTO judge_experience
    FROM Judge j
    JOIN Hearing h ON j.Judge_ID = h.Judge_ID
    WHERE h.Case_ID = case_id
    ORDER BY h.Date DESC
    LIMIT 1;
    IF judge_experience IS NULL THEN
        SET judge_experience = 0; -- Return 0 if no judge assigned
    END IF;
    RETURN judge_experience;
END //
DELIMITER ;

SELECT Case_Number, Get_Judge_Experience(Case_ID) AS Judge_Experience_Years
FROM Case_Details
WHERE Case_ID = 1;


-- 2. Function: Get_Lawyer_Case_Count
-- Use Case: Bar associations monitor lawyer workloads to ensure fair case distribution.
DELIMITER //
CREATE FUNCTION Get_Lawyer_Case_Count(lawyer_id INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE case_count INT;
    SELECT COUNT(*) INTO case_count
    FROM (
        SELECT Case_ID FROM Petitioner p
        JOIN Case_Details cd ON cd.Case_ID IN (SELECT Case_ID FROM Hearing)
        WHERE p.Legal_Representative = lawyer_id
        UNION
        SELECT Case_ID FROM Respondent r
        JOIN Case_Details cd ON cd.Case_ID IN (SELECT Case_ID FROM Hearing)
        WHERE r.Legal_Representative = lawyer_id
    ) AS cases;
    RETURN case_count;
END //
DELIMITER ;

SELECT Name, Get_Lawyer_Case_Count(Lawyer_ID) AS Active_Cases FROM Lawyer;


-- 3. Function: Is_Bail_Eligible
-- Use Case: Lawyers check bail eligibility based on charge severity for quick legal advice.
DELIMITER //
CREATE FUNCTION Is_Bail_Eligible(case_id INT, person_id INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE charge_severity VARCHAR(50);
    SELECT Severity_Level INTO charge_severity
    FROM Charges
    WHERE Case_ID = case_id
    LIMIT 1;
    IF charge_severity = 'Minor' THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END //
DELIMITER ;

SELECT Case_Number, Is_Bail_Eligible(Case_ID, 1) AS Bail_Eligible FROM Case_Details WHERE Case_ID = 5;

-- 4. Function: Get_Court_Load
-- Use Case: Court administrators assess court workload to allocate resources or transfer cases.
DELIMITER //
CREATE FUNCTION Get_Court_Load(court_id INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE active_cases INT;
    SELECT COUNT(*) INTO active_cases
    FROM Case_Details
    WHERE Court_ID = court_id AND Status IN ('Pending', 'Ongoing');
    RETURN active_cases;
END //
DELIMITER ;

SELECT Court_Name, Get_Court_Load(Court_ID) AS Active_Cases FROM Court;


-- 5. Function: Get_Witness_Count
-- Use Case: Prosecutors determine the number of witnesses for trial preparation.
DELIMITER //
CREATE FUNCTION Get_Witness_Count(case_id INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE witness_count INT;
    SELECT COUNT(*) INTO witness_count
    FROM Witness w
    JOIN Hearing h ON h.Case_ID = case_id
    WHERE w.Testimony_Date IS NOT NULL;
    RETURN witness_count;
END //
DELIMITER ;

SELECT Case_Number, Get_Witness_Count(Case_ID) AS Witnesses FROM Case_Details;