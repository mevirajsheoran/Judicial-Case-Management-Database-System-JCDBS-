 use judicialcasedb;

-- 1. Procedure: Add_New_Hearing
-- Use Case: Clerks schedule hearings.
DELIMITER //
CREATE PROCEDURE Add_New_Hearing(
    IN p_case_id INT,
    IN p_judge_id INT,
    IN p_date DATE,
    IN p_time TIME,
    IN p_description TEXT
)
BEGIN
    INSERT INTO Hearing (Case_ID, Judge_ID, Date, Time, Description, Outcome)
    VALUES (p_case_id, p_judge_id, p_date, p_time, p_description, 'Scheduled');
END //
DELIMITER ;

CALL Add_New_Hearing(1, 1, '2025-05-01', '10:00:00', 'Bail review');

SELECT Hearing_ID, Case_ID, Judge_ID, Date, Time, Description, Outcome
FROM Hearing
WHERE Case_ID = 1 AND Date = '2025-05-01' AND Description = 'Bail review';


-- 2. Procedure: Finalize_Case
-- Use Case: Judges finalize cases.
DELIMITER //
CREATE PROCEDURE Finalize_Case(
    IN p_case_id INT,
    IN p_verdict_id INT,
    IN p_decision TEXT,
    IN p_penalty DECIMAL(10,2)
)
BEGIN
    DECLARE verdict_exists INT;
    
    -- Check if a verdict already exists for the case
    SELECT COUNT(*) INTO verdict_exists
    FROM Verdict
    WHERE Case_ID = p_case_id;
    
    IF verdict_exists > 0 THEN
        -- Update existing verdict
        UPDATE Verdict
        SET Decision = p_decision,
            Penalty = p_penalty,
            Date = CURDATE(),
            Remarks = 'Updated via procedure'
        WHERE Case_ID = p_case_id;
        UPDATE Case_Details
        SET Status = 'Closed'
        WHERE Case_ID = p_case_id;
    ELSE
        -- Insert new verdict
        INSERT INTO Verdict (Verdict_ID, Case_ID, Date, Decision, Remarks, Penalty)
        VALUES (p_verdict_id, p_case_id, CURDATE(), p_decision, 'Finalized via procedure', p_penalty);
        UPDATE Case_Details
        SET Status = 'Closed', Verdict_ID = p_verdict_id
        WHERE Case_ID = p_case_id;
    END IF;
END //
DELIMITER ;

CALL Finalize_Case(1, 21, 'Guilty', 5000.00);

SELECT v.Verdict_ID, v.Case_ID, v.Decision, v.Penalty, v.Date, v.Remarks, cd.Status
FROM Verdict v
JOIN Case_Details cd ON v.Case_ID = cd.Case_ID
WHERE v.Case_ID = 1;


-- 3. Procedure: Assign_Court_Staff
-- Use Case: Managers assign clerks to cases.
DELIMITER //
CREATE PROCEDURE Assign_Court_Staff(
    IN p_staff_id INT,
    IN p_case_id INT
)
BEGIN
    INSERT INTO Case_History (Case_ID, Date, Status_Update, Notes, Updated_By)
    VALUES (p_case_id, CURDATE(), 'Staff Assigned', 'Court staff assigned to case', p_staff_id);
END //
DELIMITER ;

CALL Assign_Court_Staff(1, 1);

SELECT History_ID, Case_ID, Date, Status_Update, Notes, Updated_By
FROM Case_History
WHERE Case_ID = 1 AND Status_Update = 'Staff Assigned' AND Updated_By = 1;


-- 4. Procedure: Update_Appeal_Status
-- Use Case: Appellate courts update appeal outcomes.
DELIMITER //
CREATE PROCEDURE Update_Appeal_Status(
    IN p_appeal_id INT,
    IN p_status VARCHAR(50)
)
BEGIN
    UPDATE Appeal SET Status = p_status, Date = CURDATE()
    WHERE Appeal_ID = p_appeal_id;
END //
DELIMITER ;

CALL Update_Appeal_Status(1, 'Granted');

SELECT Appeal_ID, Case_ID, Status, Date
FROM Appeal
WHERE Appeal_ID = 1;


-- 5. Procedure: Record_Settlement
-- Use Case: Mediators log agreements.
DELIMITER //
CREATE PROCEDURE Record_Settlement(
    IN p_case_id INT,
    IN p_settlement_id INT,
    IN p_terms TEXT
)
BEGIN
    INSERT INTO Settlement (Settlement_ID, Case_ID, Terms, Date, Agreement_Signed)
    VALUES (p_settlement_id, p_case_id, p_terms, CURDATE(), TRUE);
    UPDATE Case_Details SET Status = 'Closed' WHERE Case_ID = p_case_id;
END //
DELIMITER ;

CALL Record_Settlement(2, 21, 'Payment of 2000 agreed');

SELECT s.Settlement_ID, s.Case_ID, s.Terms, s.Date, s.Agreement_Signed, cd.Status
FROM Settlement s
JOIN Case_Details cd ON s.Case_ID = cd.Case_ID
WHERE s.Case_ID = 2 AND s.Settlement_ID = 21;
