 use judicialcasedb;

-- 1. Retrieve Pending Criminal Cases
-- Use Case: Court clerks prioritize pending criminal cases
SELECT cd.Case_Number, cd.Filing_Date, cd.Status, c.Court_Name
FROM Case_Details cd
JOIN Court c ON cd.Court_ID = c.Court_ID
JOIN Case_Category cc ON cd.Category_ID = cc.Category_ID
WHERE cc.Name = 'Criminal' AND cd.Status = 'Pending';


-- 2. List Lawyers Handling Family Cases with Over 8 Years of Experience
-- Use Case: Litigants find qualified family law attorneys for divorce or custody disputes.
SELECT Name, Contact, Specialization, Experience_Years
FROM Lawyer
WHERE Specialization = 'Family' AND Experience_Years > 8
ORDER BY Experience_Years DESC;


-- 3. Find Cases with Verdicts Involving Penalties Over 6000
-- Use Case: Legal researchers analyze high-penalty verdicts for sentencing patterns.
SELECT cd.Case_Number, v.Date, v.Decision, v.Penalty
FROM Case_Details cd
JOIN Verdict v ON cd.Verdict_ID = v.Verdict_ID
WHERE v.Penalty > 6000
ORDER BY v.Penalty DESC;


-- 4. Identify Judges Handling Multiple Ongoing Cases
-- Use Case: Court administration balances judicial workloads.
SELECT j.Name, j.Designation, COUNT(h.Case_ID) AS Case_Count
FROM Judge j
JOIN Hearing h ON j.Judge_ID = h.Judge_ID
JOIN Case_Details cd ON h.Case_ID = cd.Case_ID
WHERE cd.Status = 'Ongoing'
GROUP BY j.Judge_ID, j.Name, j.Designation
HAVING Case_Count > 1;


-- 5. List FIRs Filed in Connaught Place Station in January 2023
-- Use Case: Police track complaints to focus investigations.
SELECT f.FIR_ID, f.Date, f.Details, f.Crime_Location
FROM FIR f
JOIN Police_Station p ON f.Police_Station_ID = p.Station_ID
WHERE p.Name = 'Connaught Place Station' AND f.Date LIKE '2023-01%';


-- 6. Cases Scheduled for Hearings in February 2023
-- Use Case: Court staff prepare schedules and notify parties.
SELECT cd.Case_Number, h.Date, h.Time, c.Court_Name
FROM Case_Details cd
JOIN Hearing h ON cd.Case_ID = h.Case_ID
JOIN Court c ON cd.Court_ID = c.Court_ID
WHERE h.Date LIKE '2023-02%'
ORDER BY h.Date;


-- 7. Evidence Collected by Inspector-Ranked Officers
-- Use Case: Prosecutors verify evidence chain of custody.
SELECT e.Evidence_ID, e.Type, e.Description, cd.Case_Number
FROM Evidence e
JOIN Case_Details cd ON e.Case_ID = cd.Case_ID
JOIN Police_Officer po ON e.Collected_By = po.Person_ID
WHERE po.Officer_Rank = 'Inspector';


-- 8. Bail Applications Granted in January 2023
-- Use Case: Judges track approved bail requests.
SELECT b.Bail_ID, cd.Case_Number, p.Name, b.Bail_Amount, b.Status
FROM Bail b
JOIN Case_Details cd ON b.Case_ID = cd.Case_ID
JOIN Person p ON b.Person_ID = p.Person_ID
WHERE b.Status = 'Granted' AND b.Granted_Date LIKE '2023-01%';


-- 9. Witnesses Providing Expert Testimony in 2023
-- Use Case: Lawyers prepare expert witnesses for trials.
SELECT p.Name, w.Testimony_Date, w.Type_of_Witness, cd.Case_Number
FROM Witness w
JOIN Person p ON w.Person_ID = p.Person_ID
JOIN Case_Details cd ON cd.Case_ID IN (SELECT Case_ID FROM Hearing)
WHERE w.Type_of_Witness = 'Expert' AND w.Testimony_Date LIKE '2023%';


-- 10. Appeals Granted at High Court Level
-- Use Case: Appellate courts review granted appeals for scheduling.
SELECT a.Appeal_ID, cd.Case_Number, p.Name AS Filed_By, a.Reason
FROM Appeal a
JOIN Case_Details cd ON a.Case_ID = cd.Case_ID
JOIN Person p ON a.Filed_By = p.Person_ID
WHERE a.Status = 'Granted' AND a.Appeal_Level = 'High';