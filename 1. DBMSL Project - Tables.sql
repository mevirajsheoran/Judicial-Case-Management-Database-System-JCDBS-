 use judicialcasedb;

-- 1. Court Table
CREATE TABLE Court (
    Court_ID INT PRIMARY KEY,
    Court_Name VARCHAR(100),
    Location VARCHAR(255),
    Jurisdiction_Level VARCHAR(50)
);

-- 2. Case_Category Table
CREATE TABLE Case_Category (
    Category_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Description TEXT
);

-- 3. Person Table
CREATE TABLE Person (
    Person_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Date_of_Birth DATE,
    Contact VARCHAR(20),
    Address VARCHAR(255),
    National_ID VARCHAR(50) UNIQUE
);

-- 4. Lawyer Table
CREATE TABLE Lawyer (
    Lawyer_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Contact VARCHAR(20),
    Specialization VARCHAR(100),
    Bar_Registration_Number VARCHAR(50) UNIQUE,
    Experience_Years INT
);

-- 5. Police Station Table
CREATE TABLE Police_Station (
    Station_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Location VARCHAR(255),
    Station_Code VARCHAR(20) UNIQUE,
    Contact_Number VARCHAR(20)
);

-- 6. Case_Details Table
CREATE TABLE Case_Details (
    Case_ID INT PRIMARY KEY,
    Case_Number VARCHAR(50) UNIQUE,
    Filing_Date DATE,
    Case_Type VARCHAR(100),
    Status VARCHAR(50),
    Category_ID INT,
    Court_ID INT,
    FOREIGN KEY (Category_ID) REFERENCES Case_Category(Category_ID),
    FOREIGN KEY (Court_ID) REFERENCES Court(Court_ID)
);

-- 7. Verdict Table
CREATE TABLE Verdict (
    Verdict_ID INT PRIMARY KEY,
    Case_ID INT UNIQUE,
    Date DATE,
    Decision TEXT,
    Remarks TEXT,
    Penalty DECIMAL(10,2),
    FOREIGN KEY (Case_ID) REFERENCES Case_details(Case_ID)
);

-- Adding verdict to case details 
ALTER TABLE Case_Details ADD COLUMN Verdict_ID INT UNIQUE;
ALTER TABLE Case_Details ADD FOREIGN KEY (Verdict_ID) REFERENCES Verdict(Verdict_ID);

-- 8. Judge Table
CREATE TABLE Judge (
    Judge_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Designation VARCHAR(100),
    Experience_Years INT,
    Court_ID INT,
    FOREIGN KEY (Court_ID) REFERENCES Court(Court_ID)
);

-- 9. Petitioner Table 
CREATE TABLE Petitioner (
    Person_ID INT PRIMARY KEY,
    Petition_Filed_Date DATE,
    Legal_Representative INT,
    FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID),
    FOREIGN KEY (Legal_Representative) REFERENCES Lawyer(Lawyer_ID)
);

-- 10. Respondent Table
CREATE TABLE Respondent (
    Person_ID INT PRIMARY KEY,
    Response_Submitted_Date DATE,
    Legal_Representative INT,
    FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID),
    FOREIGN KEY (Legal_Representative) REFERENCES Lawyer(Lawyer_ID)
);

-- 11. Police_Officer Table
CREATE TABLE Police_Officer (
    Person_ID INT PRIMARY KEY,
    Police_Station_ID INT,
    Badge_Number VARCHAR(50),
    Officer_Rank VARCHAR(50),  
    Department VARCHAR(100),
    FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID),
    FOREIGN KEY (Police_Station_ID) REFERENCES Police_Station(Station_ID)
);

-- 12. Witness Table
CREATE TABLE Witness (
    Person_ID INT PRIMARY KEY,
    Testimony_Date DATE,
    Type_of_Witness VARCHAR(100),
    FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID)
);

-- 13. Court Staff Table 
CREATE TABLE Court_Staff (
    Staff_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Role VARCHAR(100),
    Contact VARCHAR(20),
    Court_ID INT,
    FOREIGN KEY (Court_ID) REFERENCES Court(Court_ID)
);

-- 14. Hearing Table 
CREATE TABLE Hearing (
    Hearing_ID INT PRIMARY KEY,
    Case_ID INT,
    Judge_ID INT,
    Date DATE,
    Time TIME,
    Description TEXT,
    Outcome VARCHAR(255),
    FOREIGN KEY (Case_ID) REFERENCES Case_details(Case_ID),
    FOREIGN KEY (Judge_ID) REFERENCES Judge(Judge_ID)
);

-- 15. FIR Table 
CREATE TABLE FIR (
    FIR_ID INT PRIMARY KEY,
    Case_ID INT,
    Police_Station_ID INT,
    Filed_By INT,
    Date DATE,
    Details TEXT,
    Crime_Location VARCHAR(255),
    FOREIGN KEY (Case_ID) REFERENCES Case_details(Case_ID),
    FOREIGN KEY (Police_Station_ID) REFERENCES Police_Station(Station_ID),
    FOREIGN KEY (Filed_By) REFERENCES Police_Officer(Person_ID)
);

-- 16. Evidence Table 
CREATE TABLE Evidence (
    Evidence_ID INT PRIMARY KEY,
    Case_ID INT,
    Type VARCHAR(100),
    Description TEXT,
    Collected_By INT,
    Submission_Date DATE,
    FOREIGN KEY (Case_ID) REFERENCES Case_details(Case_ID),
    FOREIGN KEY (Collected_By) REFERENCES Police_Officer(Person_ID)
);

-- 17. Legal Act Table 
CREATE TABLE Legal_Act (
    Act_ID INT PRIMARY KEY,
    Act_Name VARCHAR(255),
    Section VARCHAR(100),
    Description TEXT,
    Enactment_Year INT
);

-- 18. Charges Table 
CREATE TABLE Charges (
    Charge_ID INT PRIMARY KEY,
    Case_ID INT,
    Legal_Act_ID INT,
    Description TEXT,
    Severity_Level VARCHAR(50),
    Charge_Date DATE,
    FOREIGN KEY (Case_ID) REFERENCES Case_details(Case_ID),
    FOREIGN KEY (Legal_Act_ID) REFERENCES Legal_Act(Act_ID)
);

-- 19. Bail Table 
CREATE TABLE Bail (
    Bail_ID INT PRIMARY KEY,
    Case_ID INT,
    Person_ID INT,
    Granted_Date DATE,
    Conditions TEXT,
    Bail_Amount DECIMAL(10,2),
    Status VARCHAR(50),
    FOREIGN KEY (Case_ID) REFERENCES Case_details(Case_ID),
    FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID)
);

-- 20. Settlement Table 
CREATE TABLE Settlement (
    Settlement_ID INT PRIMARY KEY,
    Case_ID INT,
    Terms TEXT,
    Date DATE,
    Agreement_Signed BOOLEAN,
    FOREIGN KEY (Case_ID) REFERENCES Case_details(Case_ID)
);

-- 21. Case_History Table
CREATE TABLE Case_History (
    History_ID INT PRIMARY KEY,
    Case_ID INT,
    Date DATE,
    Status_Update TEXT,
    Notes TEXT,
    Updated_By INT,
    FOREIGN KEY (Case_ID) REFERENCES Case_details(Case_ID),
    FOREIGN KEY (Updated_By) REFERENCES Court_Staff(Staff_ID)
);

-- 22. Court Room Table
CREATE TABLE Court_Room (
    Room_ID INT PRIMARY KEY,
    Court_ID INT,
    Room_Number VARCHAR(20),
    Capacity INT,
    Availability_Status VARCHAR(50),
    FOREIGN KEY (Court_ID) REFERENCES Court(Court_ID)
);

-- 23. Appeal Table 
CREATE TABLE Appeal (
    Appeal_ID INT PRIMARY KEY,
    Case_ID INT,
    Filed_By INT,
    Date DATE,
    Reason TEXT,
    Status VARCHAR(50),
    Appeal_Level VARCHAR(50),
    FOREIGN KEY (Case_ID) REFERENCES Case_details(Case_ID),
    FOREIGN KEY (Filed_By) REFERENCES Person(Person_ID)
);

-- CHANGES FOR PROCEDURES 

-- Schema Fix for Hearing.Hearing_ID
-- Purpose: Added AUTO_INCREMENT to Hearing_ID to auto-generate IDs for new hearings.
-- Why: Original schema lacked AUTO_INCREMENT, causing Error 1364 (no default value) in Add_New_Hearing.
-- How it helps: Allows inserts into Hearing without specifying Hearing_ID, ensuring unique IDs.
ALTER TABLE Hearing MODIFY Hearing_ID INT AUTO_INCREMENT;

-- Schema Fix for Case_History.History_ID
-- Purpose: Added AUTO_INCREMENT to History_ID for auto-generated case history IDs.
-- Why: Lack of AUTO_INCREMENT caused Error 1364 in Assign_Court_Staff and Update_Appeal_Status.
-- How it helps: Enables automatic ID generation for Case_History inserts, fixing insert failures.
ALTER TABLE Case_History MODIFY History_ID INT AUTO_INCREMENT;


SELECT V.Case_ID, E.Collected_By, V.Decision
FROM Case_Details CD
JOIN Verdict V ON CD.Case_ID = V.Case_ID
JOIN Evidence E ON E.Case_ID = CD.Case_ID
JOIN Police_Officer PO ON E.Collected_By = PO.Person_ID
WHERE Verdict_ID=1;

