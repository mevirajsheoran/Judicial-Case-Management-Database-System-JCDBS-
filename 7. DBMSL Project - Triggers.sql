 use judicialcasedb;

-- 1. Trigger: Update_Case_On_Hearing
-- Use Case: Ensures case status reflects hearing activity.
DELIMITER //
CREATE TRIGGER after_hearing_insert
AFTER INSERT ON Hearing
FOR EACH ROW
BEGIN
    UPDATE Case_Details
    SET Status = 'Ongoing'
    WHERE Case_ID = NEW.Case_ID AND Status = 'Pending';
END //
DELIMITER ;

INSERT INTO Hearing (Case_ID, Judge_ID, Date, Time, Description, Outcome)
VALUES (4, 1, '2025-05-02', '11:00:00', 'Initial hearing', 'Scheduled');

SELECT Case_ID, Case_Number, Status
FROM Case_Details
WHERE Case_ID = 4;


-- 2. Trigger: Log_Verdict_Update
-- Use Case: Maintains audit trail for verdicts.
DELIMITER //
CREATE TRIGGER after_verdict_insert
AFTER INSERT ON Verdict
FOR EACH ROW
BEGIN
    INSERT INTO Case_History (Case_ID, Date, Status_Update, Notes, Updated_By)
    VALUES (NEW.Case_ID, CURDATE(), CONCAT('Verdict: ', NEW.Decision), 'Verdict recorded', 1);
END //
DELIMITER ;

INSERT INTO Verdict (Verdict_ID, Case_ID, Date, Decision, Remarks, Penalty)
VALUES (22, 4, '2025-04-14', 'Not Guilty', 'Test verdict', 0.00);

SELECT History_ID, Case_ID, Date, Status_Update, Notes, Updated_By
FROM Case_History
WHERE Case_ID = 4 AND Status_Update = 'Verdict: Not Guilty';


-- 3. Trigger: Restrict_Felony_Bail
-- Use Case: Enforces legal restrictions on bail.
DELIMITER //
CREATE TRIGGER before_bail_insert
BEFORE INSERT ON Bail
FOR EACH ROW
BEGIN
    DECLARE severity VARCHAR(50);
    SELECT Severity_Level INTO severity
    FROM Charges
    WHERE Case_ID = NEW.Case_ID
    LIMIT 1;
    IF severity = 'Felony' OR severity IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bail not allowed for felony charges or uncharged cases';
    END IF;
END //
DELIMITER ;

INSERT INTO Bail (Bail_ID, Case_ID, Person_ID, Bail_Amount, Status, Granted_Date)
VALUES (33, 1, 1, 10000.00, 'Pending', '2025-04-14');
-- Error Code 1644 will arise 

-- Since INSERT fails, check Bail table to confirm no entry.
SELECT Bail_ID, Case_ID, Person_ID, Bail_Amount, Status
FROM Bail
WHERE Case_ID = 1 AND Bail_ID = 33;


-- 4. Trigger: Update_Room_On_Hearing
-- Use Case: Manages courtroom availability.
DELIMITER //
CREATE TRIGGER after_hearing_schedule
AFTER INSERT ON Hearing
FOR EACH ROW
BEGIN
    UPDATE Court_Room
    SET Availability_Status = 'Occupied'
    WHERE Court_ID = (SELECT Court_ID FROM Case_Details WHERE Case_ID = NEW.Case_ID)
    AND Availability_Status = 'Available'
    LIMIT 1;
END //
DELIMITER ;

CALL Add_New_Hearing(1, 1, '2025-05-01', '10:00:00', 'Bail review');

SELECT cr.Room_Number, cr.Court_ID, c.Court_Name, cr.Availability_Status
FROM Court_Room cr
JOIN Court c ON cr.Court_ID = c.Court_ID
WHERE cr.Court_ID = (SELECT Court_ID FROM Case_Details WHERE Case_ID = 1)
AND cr.Availability_Status = 'Occupied';


-- 5. Trigger: Log_Appeal_Update
-- Use Case: Tracks appeal progress for transparency.
DELIMITER //
CREATE TRIGGER after_appeal_update
AFTER UPDATE ON Appeal
FOR EACH ROW
BEGIN
    INSERT INTO Case_History (Case_ID, Date, Status_Update, Notes, Updated_By)
    VALUES (NEW.Case_ID, CURDATE(), CONCAT('Appeal Status: ', NEW.Status), 'Appeal updated', 1);
END //
DELIMITER ;

CALL Update_Appeal_Status(1, 'Granted');

SELECT History_ID, Case_ID, Date, Status_Update, Notes, Updated_By
FROM Case_History
WHERE Case_ID = 1 AND Status_Update = 'Appeal Status: Granted';

