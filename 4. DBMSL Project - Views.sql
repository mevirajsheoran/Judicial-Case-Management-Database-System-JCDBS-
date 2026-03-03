 use judicialcasedb;

-- 1. View: Pending_Cases_Overview
-- Use Case: Clerks monitor pending cases for scheduling.
CREATE VIEW Pending_Cases_Overview AS
SELECT cd.Case_ID, cd.Case_Number, cd.Filing_Date, cc.Name AS Category, c.Court_Name
FROM Case_Details cd
JOIN Case_Category cc ON cd.Category_ID = cc.Category_ID
JOIN Court c ON cd.Court_ID = c.Court_ID
WHERE cd.Status = 'Pending';

SELECT * FROM Pending_Cases_Overview;


-- 2. View: Lawyer_Client_List
-- Use Case: Bar associations track lawyer-client assignments.
CREATE VIEW Lawyer_Client_List AS
SELECT l.Name AS Lawyer_Name, l.Specialization, p.Name AS Client_Name, cd.Case_Number
FROM Lawyer l
JOIN Petitioner pt ON pt.Legal_Representative = l.Lawyer_ID
JOIN Person p ON pt.Person_ID = p.Person_ID
JOIN Case_Details cd ON cd.Case_ID IN (SELECT Case_ID FROM Hearing)
UNION
SELECT l.Name, l.Specialization, p.Name, cd.Case_Number
FROM Lawyer l
JOIN Respondent rs ON rs.Legal_Representative = l.Lawyer_ID
JOIN Person p ON rs.Person_ID = p.Person_ID
JOIN Case_Details cd ON cd.Case_ID IN (SELECT Case_ID FROM Hearing);

SELECT * FROM Lawyer_Client_List;


-- 3. View: Court_Availability
-- Use Case: Managers assign courtrooms for hearings.
CREATE VIEW Court_Availability AS
SELECT cr.Room_Number, c.Court_Name, cr.Capacity, cr.Availability_Status
FROM Court_Room cr
JOIN Court c ON cr.Court_ID = c.Court_ID
WHERE cr.Availability_Status = 'Available';

SELECT * FROM Court_Availability;


-- 4. View: Police_Station_Activity
-- Use Case: Police departments assess station workloads.
CREATE VIEW Police_Station_Activity AS
SELECT ps.Name AS Station_Name, COUNT(f.FIR_ID) AS FIR_Count
FROM Police_Station ps
LEFT JOIN FIR f ON ps.Station_ID = f.Police_Station_ID
GROUP BY ps.Station_ID, ps.Name;

SELECT * FROM Police_Station_Activity;


-- 5. View: Judge_Case_Assignments
-- Use Case: Judges review their assigned cases.
CREATE VIEW Judge_Case_Assignments AS
SELECT j.Name AS Judge_Name, j.Designation, cd.Case_Number, h.Date
FROM Judge j
JOIN Hearing h ON j.Judge_ID = h.Judge_ID
JOIN Case_Details cd ON h.Case_ID = cd.Case_ID
WHERE h.Date >= '2023-01-01'
ORDER BY h.Date;

SELECT * FROM Judge_Case_Assignments;