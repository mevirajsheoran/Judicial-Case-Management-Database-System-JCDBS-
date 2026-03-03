# Judicial Case Management Database System (JCDBS) - Complete Documentation

## Table of Contents
1. [Overview](#1-overview)
2. [Database Architecture](#2-database-architecture)
3. [Schema Design](#3-schema-design)
4. [Tables Reference](#4-tables-reference)
5. [Relationships & ER Diagram](#5-relationships--er-diagram)
6. [Views](#6-views)
7. [Stored Procedures](#7-stored-procedures)
8. [Functions](#8-functions)
9. [Triggers](#9-triggers)
10. [Sample Queries](#10-sample-queries)
11. [Data Dictionary](#11-data-dictionary)
12. [Installation & Setup](#12-installation--setup)
13. [Usage Examples](#13-usage-examples)

---

## 1. Overview

### 1.1 System Purpose
The **Judicial Case Management Database System (JCDBS)** is a comprehensive MySQL database designed to manage all aspects of court operations including:
- Case tracking and management
- Court scheduling and room allocation
- Lawyer and judge assignments
- Evidence and FIR management
- Bail processing and appeals
- Verdict and settlement recording
- Case history auditing

### 1.2 Key Features
- **Complete Case Lifecycle Management**: From filing to verdict
- **Multi-Level Court Support**: Handles District, High, and Supreme Courts
- **Personnel Management**: Lawyers, judges, police officers, court staff
- **Evidence Tracking**: Chain of custody for all evidence
- **Automated Triggers**: Status updates and audit logging
- **Stored Procedures**: Standardized workflows
- **Custom Functions**: Business logic encapsulation

### 1.3 Technology Stack
- **Database**: MySQL 8.0+
- **Schema**: Normalized to 3NF (Third Normal Form)
- **Total Tables**: 23
- **Total Records**: 380+ sample records across all tables

---

## 2. Database Architecture

### 2.1 Database Name
```sql
judicialcasedb
```

### 2.2 Core Entity Groups

| Group | Tables | Purpose |
|-------|--------|---------|
| **Master Data** | Court, Case_Category, Legal_Act | Reference data |
| **People** | Person, Lawyer, Judge, Police_Officer, Witness, Petitioner, Respondent | Stakeholders |
| **Case Management** | Case_Details, Case_History, Verdict, Charges | Case lifecycle |
| **Police Operations** | Police_Station, FIR, Evidence | Investigation |
| **Court Operations** | Hearing, Court_Room, Court_Staff | Scheduling |
| **Legal Processes** | Bail, Appeal, Settlement | Legal remedies |

### 2.3 Design Patterns
- **Inheritance (Generalization)**: `Person` is the base entity for `Lawyer`, `Judge`, `Police_Officer`, `Witness`, `Petitioner`, `Respondent`
- **Soft References**: Used for loose coupling between entities
- **Audit Trail**: `Case_History` tracks all status changes
- **Status Enumeration**: Status fields use controlled vocabulary

---

## 3. Schema Design

### 3.1 Table Count Summary
```
Total Tables: 23
- Master Tables: 3
- Person Tables: 7
- Case Tables: 6
- Court Tables: 3
- Police Tables: 3
- Legal Tables: 3
```

### 3.2 Normalization Level
The schema is normalized to **Third Normal Form (3NF)**:
- No repeating groups (1NF)
- No partial dependencies (2NF)
- No transitive dependencies (3NF)

### 3.3 Naming Conventions
- **Tables**: PascalCase (e.g., `Case_Details`, `Police_Station`)
- **Columns**: snake_case (e.g., `Filing_Date`, `Case_Number`)
- **Primary Keys**: `TableName_ID` (e.g., `Case_ID`, `Court_ID`)
- **Foreign Keys**: Same name as referenced primary key

---

## 4. Tables Reference

### 4.1 Master Tables

#### 4.1.1 Court
Stores court information including jurisdiction levels.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Court_ID | INT | PRIMARY KEY | Unique court identifier |
| Court_Name | VARCHAR(100) | | Court name |
| Location | VARCHAR(255) | | Court address |
| Jurisdiction_Level | VARCHAR(50) | | District/High/Supreme |

#### 4.1.2 Case_Category
Classifies cases by type.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Category_ID | INT | PRIMARY KEY | Category identifier |
| Name | VARCHAR(100) | | Category name (Criminal, Civil, etc.) |
| Description | TEXT | | Detailed description |

#### 4.1.3 Legal_Act
Reference table for laws and acts.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Act_ID | INT | PRIMARY KEY | Act identifier |
| Act_Name | VARCHAR(255) | | Name of the legal act |
| Section | VARCHAR(100) | | Section reference |
| Description | TEXT | | Act details |
| Enactment_Year | INT | | Year enacted |

---

### 4.2 Person Tables (Generalization Pattern)

#### 4.2.1 Person (Base Entity)
Central entity for all individuals in the system.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Person_ID | INT | PRIMARY KEY | Unique person identifier |
| Name | VARCHAR(100) | | Full name |
| Date_of_Birth | DATE | | Birth date |
| Contact | VARCHAR(20) | | Phone number |
| Address | VARCHAR(255) | | Residential address |
| National_ID | VARCHAR(50) | UNIQUE | Government ID (Aadhar/SSN) |

#### 4.2.2 Lawyer
Inherits from Person via Person_ID.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Lawyer_ID | INT | PRIMARY KEY, FK→Person | Person_ID reference |
| Name | VARCHAR(100) | | Lawyer name (denormalized) |
| Contact | VARCHAR(20) | | Contact number |
| Specialization | VARCHAR(100) | | Area of law |
| Bar_Registration_Number | VARCHAR(50) | UNIQUE | Bar council registration |
| Experience_Years | INT | | Years of practice |

#### 4.2.3 Judge
Inherits from Person conceptually; separate entity.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Judge_ID | INT | PRIMARY KEY | Judge identifier |
| Name | VARCHAR(100) | | Judge name |
| Designation | VARCHAR(100) | | Position/Title |
| Experience_Years | INT | | Years on bench |
| Court_ID | INT | FK→Court | Assigned court |

#### 4.2.4 Police_Officer
Links Person to Police_Station.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Person_ID | INT | PRIMARY KEY, FK→Person | Officer's person ID |
| Police_Station_ID | INT | FK→Police_Station | Station assignment |
| Badge_Number | VARCHAR(50) | | Officer badge number |
| Officer_Rank | VARCHAR(50) | | Rank (Inspector, etc.) |
| Department | VARCHAR(100) | | Department within station |

#### 4.2.5 Witness
Records witness information.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Person_ID | INT | PRIMARY KEY, FK→Person | Witness's person ID |
| Testimony_Date | DATE | | When testimony given |
| Type_of_Witness | VARCHAR(100) | | Expert/Eyewitness/Character |

#### 4.2.6 Petitioner
Case initiators/plaintiffs.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Person_ID | INT | PRIMARY KEY, FK→Person | Petitioner's person ID |
| Petition_Filed_Date | DATE | | When petition filed |
| Legal_Representative | INT | FK→Lawyer | Assigned lawyer |

#### 4.2.7 Respondent
Defendants in cases.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Person_ID | INT | PRIMARY KEY, FK→Person | Respondent's person ID |
| Response_Submitted_Date | DATE | | When response filed |
| Legal_Representative | INT | FK→Lawyer | Defense lawyer |

---

### 4.3 Case Management Tables

#### 4.3.1 Case_Details
Central case information table.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Case_ID | INT | PRIMARY KEY | Case identifier |
| Case_Number | VARCHAR(50) | UNIQUE | Court-assigned number |
| Filing_Date | DATE | | Date case was filed |
| Case_Type | VARCHAR(100) | | Criminal/Civil/etc. |
| Status | VARCHAR(50) | | Pending/Ongoing/Closed |
| Category_ID | INT | FK→Case_Category | Case classification |
| Court_ID | INT | FK→Court | Assigned court |
| Verdict_ID | INT | FK→Verdict | Final verdict (nullable) |

#### 4.3.2 Verdict
Stores court judgments.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Verdict_ID | INT | PRIMARY KEY | Verdict identifier |
| Case_ID | INT | UNIQUE, FK→Case_Details | One verdict per case |
| Date | DATE | | Verdict date |
| Decision | TEXT | | Judgment text |
| Remarks | TEXT | | Additional notes |
| Penalty | DECIMAL(10,2) | | Fine/Compensation amount |

#### 4.3.3 Case_History
Audit trail for case status changes.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| History_ID | INT | PRIMARY KEY, AUTO_INCREMENT | History entry ID |
| Case_ID | INT | FK→Case_Details | Related case |
| Date | DATE | | Update timestamp |
| Status_Update | TEXT | | Description of change |
| Notes | TEXT | | Additional information |
| Updated_By | INT | FK→Court_Staff | Staff member who updated |

#### 4.3.4 Charges
Links cases to applicable legal acts.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Charge_ID | INT | PRIMARY KEY | Charge identifier |
| Case_ID | INT | FK→Case_Details | Related case |
| Legal_Act_ID | INT | FK→Legal_Act | Applicable law |
| Description | TEXT | | Charge details |
| Severity_Level | VARCHAR(50) | | Minor/Felony/etc. |
| Charge_Date | DATE | | When charge filed |

#### 4.3.5 Settlement
Records out-of-court settlements.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Settlement_ID | INT | PRIMARY KEY | Settlement identifier |
| Case_ID | INT | FK→Case_Details | Related case |
| Terms | TEXT | | Settlement terms |
| Date | DATE | | Agreement date |
| Agreement_Signed | BOOLEAN | | Whether signed by all parties |

#### 4.3.6 Bail
Manages bail applications.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Bail_ID | INT | PRIMARY KEY | Bail identifier |
| Case_ID | INT | FK→Case_Details | Related case |
| Person_ID | INT | FK→Person | Bail recipient |
| Granted_Date | DATE | | Date granted |
| Conditions | TEXT | | Bail conditions |
| Bail_Amount | DECIMAL(10,2) | | Financial bond amount |
| Status | VARCHAR(50) | | Granted/Denied/Pending |

#### 4.3.7 Appeal
Tracks appellate court filings.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Appeal_ID | INT | PRIMARY KEY | Appeal identifier |
| Case_ID | INT | FK→Case_Details | Related case |
| Filed_By | INT | FK→Person | Appellant |
| Date | DATE | | Filing date |
| Reason | TEXT | | Grounds for appeal |
| Status | VARCHAR(50) | | Pending/Granted/Dismissed |
| Appeal_Level | VARCHAR(50) | | District/High/Supreme |

---

### 4.4 Court Operations Tables

#### 4.4.1 Hearing
Schedules court proceedings.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Hearing_ID | INT | PRIMARY KEY, AUTO_INCREMENT | Hearing identifier |
| Case_ID | INT | FK→Case_Details | Related case |
| Judge_ID | INT | FK→Judge | Presiding judge |
| Date | DATE | | Hearing date |
| Time | TIME | | Hearing time |
| Description | TEXT | | Purpose/Agenda |
| Outcome | VARCHAR(255) | | Result/Status |

#### 4.4.2 Court_Room
Manages physical courtrooms.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Room_ID | INT | PRIMARY KEY | Room identifier |
| Court_ID | INT | FK→Court | Parent court |
| Room_Number | VARCHAR(20) | | Room designation |
| Capacity | INT | | Seating capacity |
| Availability_Status | VARCHAR(50) | | Available/Occupied/Maintenance |

#### 4.4.3 Court_Staff
Court administrative personnel.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Staff_ID | INT | PRIMARY KEY | Staff identifier |
| Name | VARCHAR(100) | | Staff name |
| Role | VARCHAR(100) | | Position (Clerk, etc.) |
| Contact | VARCHAR(20) | | Contact number |
| Court_ID | INT | FK→Court | Work location |

---

### 4.5 Police Operations Tables

#### 4.5.1 Police_Station
Police station information.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Station_ID | INT | PRIMARY KEY | Station identifier |
| Name | VARCHAR(100) | | Station name |
| Location | VARCHAR(255) | | Address |
| Station_Code | VARCHAR(20) | UNIQUE | Official code |
| Contact_Number | VARCHAR(20) | | Phone number |

#### 4.5.2 FIR (First Information Report)
Initial police reports.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| FIR_ID | INT | PRIMARY KEY | FIR identifier |
| Case_ID | INT | FK→Case_Details | Related case |
| Police_Station_ID | INT | FK→Police_Station | Filing station |
| Filed_By | INT | FK→Police_Officer | Officer who filed |
| Date | DATE | | Filing date |
| Details | TEXT | | Incident description |
| Crime_Location | VARCHAR(255) | | Where crime occurred |

#### 4.5.3 Evidence
Evidence collection and tracking.

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| Evidence_ID | INT | PRIMARY KEY | Evidence identifier |
| Case_ID | INT | FK→Case_Details | Related case |
| Type | VARCHAR(100) | | Digital/Physical/Documentary |
| Description | TEXT | | Evidence details |
| Collected_By | INT | FK→Police_Officer | Collecting officer |
| Submission_Date | DATE | | Date submitted to court |

---

## 5. Relationships & ER Diagram

### 5.1 Entity Relationship Summary

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Court     │────<│ Case_Details│>────│Case_Category│
└──────┬──────┘     └──────┬──────┘     └─────────────┘
       │                   │
       │            ┌──────┴──────┐
       │            │             │
       │       ┌────┴────┐   ┌───┴────┐
       │       │ Verdict │   │Hearing │
       │       └─────────┘   └───┬────┘
       │                         │
┌──────┴──────┐              ┌────┴────┐
│ Court_Room  │              │  Judge  │
└─────────────┘              └────┬────┘
                                 │
┌─────────────┐              ┌────┴────┐
│Police_Station│              │Person   │
└──────┬──────┘              └────┬────┘
       │                   ┌─────┼─────┐
       │              ┌────┘         └────┐
┌──────┴──────┐    ┌──┴───┐           ┌───┴──┐
│Police_Officer│    │Lawyer│           │Witness│
└─────────────┘    └──────┘           └──────┘
       │              │
┌──────┴──────┐    ┌───┴───┐
│    FIR      │    │Petitioner/Respondent
└─────────────┘    └────────┘
```

### 5.2 Foreign Key Relationships

| Child Table | Parent Table | Foreign Key | Cardinality |
|-------------|--------------|-------------|-------------|
| Case_Details | Court | Court_ID | N:1 |
| Case_Details | Case_Category | Category_ID | N:1 |
| Case_Details | Verdict | Verdict_ID | 1:1 |
| Judge | Court | Court_ID | N:1 |
| Petitioner | Person | Person_ID | 1:1 |
| Petitioner | Lawyer | Legal_Representative | N:1 |
| Respondent | Person | Person_ID | 1:1 |
| Respondent | Lawyer | Legal_Representative | N:1 |
| Police_Officer | Person | Person_ID | 1:1 |
| Police_Officer | Police_Station | Police_Station_ID | N:1 |
| Witness | Person | Person_ID | 1:1 |
| Court_Staff | Court | Court_ID | N:1 |
| Hearing | Case_Details | Case_ID | N:1 |
| Hearing | Judge | Judge_ID | N:1 |
| FIR | Case_Details | Case_ID | N:1 |
| FIR | Police_Station | Police_Station_ID | N:1 |
| FIR | Police_Officer | Filed_By | N:1 |
| Evidence | Case_Details | Case_ID | N:1 |
| Evidence | Police_Officer | Collected_By | N:1 |
| Charges | Case_Details | Case_ID | N:1 |
| Charges | Legal_Act | Legal_Act_ID | N:1 |
| Bail | Case_Details | Case_ID | N:1 |
| Bail | Person | Person_ID | N:1 |
| Settlement | Case_Details | Case_ID | N:1 |
| Case_History | Case_Details | Case_ID | N:1 |
| Case_History | Court_Staff | Updated_By | N:1 |
| Court_Room | Court | Court_ID | N:1 |
| Appeal | Case_Details | Case_ID | N:1 |
| Appeal | Person | Filed_By | N:1 |

---

## 6. Views

### 6.1 Pending_Cases_Overview
**Purpose**: Monitor pending cases for court clerks

```sql
CREATE VIEW Pending_Cases_Overview AS
SELECT cd.Case_ID, cd.Case_Number, cd.Filing_Date, 
       cc.Name AS Category, c.Court_Name
FROM Case_Details cd
JOIN Case_Category cc ON cd.Category_ID = cc.Category_ID
JOIN Court c ON cd.Court_ID = c.Court_ID
WHERE cd.Status = 'Pending';
```

**Columns**: Case_ID, Case_Number, Filing_Date, Category, Court_Name

---

### 6.2 Lawyer_Client_List
**Purpose**: Track lawyer-client assignments for bar associations

```sql
CREATE VIEW Lawyer_Client_List AS
SELECT l.Name AS Lawyer_Name, l.Specialization, 
       p.Name AS Client_Name, cd.Case_Number
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
```

**Columns**: Lawyer_Name, Specialization, Client_Name, Case_Number

---

### 6.3 Court_Availability
**Purpose**: Assign courtrooms for hearings

```sql
CREATE VIEW Court_Availability AS
SELECT cr.Room_Number, c.Court_Name, cr.Capacity, 
       cr.Availability_Status
FROM Court_Room cr
JOIN Court c ON cr.Court_ID = c.Court_ID
WHERE cr.Availability_Status = 'Available';
```

**Columns**: Room_Number, Court_Name, Capacity, Availability_Status

---

### 6.4 Police_Station_Activity
**Purpose**: Assess police station workloads

```sql
CREATE VIEW Police_Station_Activity AS
SELECT ps.Name AS Station_Name, COUNT(f.FIR_ID) AS FIR_Count
FROM Police_Station ps
LEFT JOIN FIR f ON ps.Station_ID = f.Police_Station_ID
GROUP BY ps.Station_ID, ps.Name;
```

**Columns**: Station_Name, FIR_Count

---

### 6.5 Judge_Case_Assignments
**Purpose**: Judges review their assigned cases

```sql
CREATE VIEW Judge_Case_Assignments AS
SELECT j.Name AS Judge_Name, j.Designation, cd.Case_Number, h.Date
FROM Judge j
JOIN Hearing h ON j.Judge_ID = h.Judge_ID
JOIN Case_Details cd ON h.Case_ID = cd.Case_ID
WHERE h.Date >= '2023-01-01'
ORDER BY h.Date;
```

**Columns**: Judge_Name, Designation, Case_Number, Date

---

## 7. Stored Procedures

### 7.1 Add_New_Hearing
**Purpose**: Schedule new court hearings

**Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| p_case_id | INT | Case identifier |
| p_judge_id | INT | Presiding judge |
| p_date | DATE | Hearing date |
| p_time | TIME | Hearing time |
| p_description | TEXT | Hearing agenda |

**Logic**: Inserts a new hearing with 'Scheduled' outcome

**Usage**:
```sql
CALL Add_New_Hearing(1, 1, '2025-05-01', '10:00:00', 'Bail review');
```

---

### 7.2 Finalize_Case
**Purpose**: Record case verdict and close case

**Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| p_case_id | INT | Case identifier |
| p_verdict_id | INT | Verdict identifier |
| p_decision | TEXT | Verdict text |
| p_penalty | DECIMAL(10,2) | Fine amount |

**Logic**:
- If verdict exists → Update it
- If verdict doesn't exist → Insert new verdict
- Always updates Case_Details.Status to 'Closed'

**Usage**:
```sql
CALL Finalize_Case(1, 21, 'Guilty', 5000.00);
```

---

### 7.3 Assign_Court_Staff
**Purpose**: Assign clerks to cases and log assignment

**Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| p_staff_id | INT | Staff member identifier |
| p_case_id | INT | Case identifier |

**Logic**: Creates Case_History entry documenting staff assignment

**Usage**:
```sql
CALL Assign_Court_Staff(1, 1);
```

---

### 7.4 Update_Appeal_Status
**Purpose**: Update appeal outcomes

**Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| p_appeal_id | INT | Appeal identifier |
| p_status | VARCHAR(50) | New status |

**Logic**: Updates appeal status and date

**Usage**:
```sql
CALL Update_Appeal_Status(1, 'Granted');
```

---

### 7.5 Record_Settlement
**Purpose**: Log out-of-court settlements

**Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| p_case_id | INT | Case identifier |
| p_settlement_id | INT | Settlement identifier |
| p_terms | TEXT | Settlement terms |

**Logic**:
- Creates settlement record with current date
- Marks Agreement_Signed as TRUE
- Closes the case (Status = 'Closed')

**Usage**:
```sql
CALL Record_Settlement(2, 21, 'Payment of 2000 agreed');
```

---

## 8. Functions

### 8.1 Get_Judge_Experience
**Purpose**: Returns judge's years of experience for a case

**Parameters**: case_id INT
**Returns**: INT (years of experience)

**Logic**:
1. Finds the most recent judge assigned to the case via Hearing
2. Returns that judge's Experience_Years
3. Returns 0 if no judge found

**Usage**:
```sql
SELECT Case_Number, Get_Judge_Experience(Case_ID) AS Judge_Experience_Years
FROM Case_Details WHERE Case_ID = 1;
```

---

### 8.2 Get_Lawyer_Case_Count
**Purpose**: Count active cases per lawyer

**Parameters**: lawyer_id INT
**Returns**: INT (case count)

**Logic**:
1. Counts cases where lawyer represents petitioners
2. Counts cases where lawyer represents respondents
3. Returns union count (unique cases)

**Usage**:
```sql
SELECT Name, Get_Lawyer_Case_Count(Lawyer_ID) AS Active_Cases FROM Lawyer;
```

---

### 8.3 Is_Bail_Eligible
**Purpose**: Check bail eligibility based on charge severity

**Parameters**: 
- case_id INT
- person_id INT

**Returns**: BOOLEAN

**Logic**:
- Returns TRUE if charge severity is 'Minor'
- Returns FALSE otherwise

**Usage**:
```sql
SELECT Case_Number, Is_Bail_Eligible(Case_ID, 1) AS Bail_Eligible 
FROM Case_Details WHERE Case_ID = 5;
```

---

### 8.4 Get_Court_Load
**Purpose**: Count active cases per court

**Parameters**: court_id INT
**Returns**: INT (active case count)

**Logic**: Counts cases with Status IN ('Pending', 'Ongoing')

**Usage**:
```sql
SELECT Court_Name, Get_Court_Load(Court_ID) AS Active_Cases FROM Court;
```

---

### 8.5 Get_Witness_Count
**Purpose**: Count witnesses for trial preparation

**Parameters**: case_id INT
**Returns**: INT (witness count)

**Logic**: Counts witnesses with Testimony_Date for the case

**Usage**:
```sql
SELECT Case_Number, Get_Witness_Count(Case_ID) AS Witnesses FROM Case_Details;
```

---

## 9. Triggers

### 9.1 Update_Case_On_Hearing
**Event**: AFTER INSERT ON Hearing
**Purpose**: Ensures case status reflects hearing activity

**Logic**:
```sql
UPDATE Case_Details
SET Status = 'Ongoing'
WHERE Case_ID = NEW.Case_ID AND Status = 'Pending';
```

**Effect**: Automatically updates case from 'Pending' to 'Ongoing' when first hearing is scheduled.

---

### 9.2 Log_Verdict_Update
**Event**: AFTER INSERT ON Verdict
**Purpose**: Maintains audit trail for verdicts

**Logic**:
```sql
INSERT INTO Case_History (Case_ID, Date, Status_Update, Notes, Updated_By)
VALUES (NEW.Case_ID, CURDATE(), CONCAT('Verdict: ', NEW.Decision), 'Verdict recorded', 1);
```

**Effect**: Creates Case_History entry documenting verdict.

---

### 9.3 Restrict_Felony_Bail
**Event**: BEFORE INSERT ON Bail
**Purpose**: Enforces legal restrictions on bail

**Logic**:
```sql
DECLARE severity VARCHAR(50);
SELECT Severity_Level INTO severity FROM Charges WHERE Case_ID = NEW.Case_ID LIMIT 1;
IF severity = 'Felony' OR severity IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Bail not allowed for felony charges or uncharged cases';
END IF;
```

**Effect**: Prevents bail grants for felony charges or cases without charges.

---

### 9.4 Update_Room_On_Hearing
**Event**: AFTER INSERT ON Hearing
**Purpose**: Manages courtroom availability

**Logic**:
```sql
UPDATE Court_Room
SET Availability_Status = 'Occupied'
WHERE Court_ID = (SELECT Court_ID FROM Case_Details WHERE Case_ID = NEW.Case_ID)
AND Availability_Status = 'Available'
LIMIT 1;
```

**Effect**: Automatically marks a courtroom as occupied when a hearing is scheduled.

---

### 9.5 Log_Appeal_Update
**Event**: AFTER UPDATE ON Appeal
**Purpose**: Tracks appeal progress for transparency

**Logic**:
```sql
INSERT INTO Case_History (Case_ID, Date, Status_Update, Notes, Updated_By)
VALUES (NEW.Case_ID, CURDATE(), CONCAT('Appeal Status: ', NEW.Status), 'Appeal updated', 1);
```

**Effect**: Logs appeal status changes to case history.

---

## 10. Sample Queries

### 10.1 Pending Criminal Cases
**Use Case**: Court clerks prioritize pending criminal cases

```sql
SELECT cd.Case_Number, cd.Filing_Date, cd.Status, c.Court_Name
FROM Case_Details cd
JOIN Court c ON cd.Court_ID = c.Court_ID
JOIN Case_Category cc ON cd.Category_ID = cc.Category_ID
WHERE cc.Name = 'Criminal' AND cd.Status = 'Pending';
```

---

### 10.2 Experienced Family Lawyers
**Use Case**: Find qualified family law attorneys

```sql
SELECT Name, Contact, Specialization, Experience_Years
FROM Lawyer
WHERE Specialization = 'Family' AND Experience_Years > 8
ORDER BY Experience_Years DESC;
```

---

### 10.3 High Penalty Verdicts
**Use Case**: Analyze high-penalty verdicts for sentencing patterns

```sql
SELECT cd.Case_Number, v.Date, v.Decision, v.Penalty
FROM Case_Details cd
JOIN Verdict v ON cd.Verdict_ID = v.Verdict_ID
WHERE v.Penalty > 6000
ORDER BY v.Penalty DESC;
```

---

### 10.4 Judges with Multiple Ongoing Cases
**Use Case**: Balance judicial workloads

```sql
SELECT j.Name, j.Designation, COUNT(h.Case_ID) AS Case_Count
FROM Judge j
JOIN Hearing h ON j.Judge_ID = h.Judge_ID
JOIN Case_Details cd ON h.Case_ID = cd.Case_ID
WHERE cd.Status = 'Ongoing'
GROUP BY j.Judge_ID, j.Name, j.Designation
HAVING Case_Count > 1;
```

---

### 10.5 FIRs by Location and Date
**Use Case**: Track complaints to focus investigations

```sql
SELECT f.FIR_ID, f.Date, f.Details, f.Crime_Location
FROM FIR f
JOIN Police_Station p ON f.Police_Station_ID = p.Station_ID
WHERE p.Name = 'Connaught Place Station' AND f.Date LIKE '2023-01%';
```

---

### 10.6 February 2023 Hearings
**Use Case**: Prepare schedules and notify parties

```sql
SELECT cd.Case_Number, h.Date, h.Time, c.Court_Name
FROM Case_Details cd
JOIN Hearing h ON cd.Case_ID = h.Case_ID
JOIN Court c ON cd.Court_ID = c.Court_ID
WHERE h.Date LIKE '2023-02%'
ORDER BY h.Date;
```

---

### 10.7 Inspector-Collected Evidence
**Use Case**: Verify evidence chain of custody

```sql
SELECT e.Evidence_ID, e.Type, e.Description, cd.Case_Number
FROM Evidence e
JOIN Case_Details cd ON e.Case_ID = cd.Case_ID
JOIN Police_Officer po ON e.Collected_By = po.Person_ID
WHERE po.Officer_Rank = 'Inspector';
```

---

### 10.8 January 2023 Bail Grants
**Use Case**: Judges track approved bail requests

```sql
SELECT b.Bail_ID, cd.Case_Number, p.Name, b.Bail_Amount, b.Status
FROM Bail b
JOIN Case_Details cd ON b.Case_ID = cd.Case_ID
JOIN Person p ON b.Person_ID = p.Person_ID
WHERE b.Status = 'Granted' AND b.Granted_Date LIKE '2023-01%';
```

---

### 10.9 Expert Witnesses in 2023
**Use Case**: Lawyers prepare expert witnesses for trials

```sql
SELECT p.Name, w.Testimony_Date, w.Type_of_Witness, cd.Case_Number
FROM Witness w
JOIN Person p ON w.Person_ID = p.Person_ID
JOIN Case_Details cd ON cd.Case_ID IN (SELECT Case_ID FROM Hearing)
WHERE w.Type_of_Witness = 'Expert' AND w.Testimony_Date LIKE '2023%';
```

---

### 10.10 High Court Granted Appeals
**Use Case**: Appellate courts review granted appeals for scheduling

```sql
SELECT a.Appeal_ID, cd.Case_Number, p.Name AS Filed_By, a.Reason
FROM Appeal a
JOIN Case_Details cd ON a.Case_ID = cd.Case_ID
JOIN Person p ON a.Filed_By = p.Person_ID
WHERE a.Status = 'Granted' AND a.Appeal_Level = 'High';
```

---

## 11. Data Dictionary

### 11.1 Status Values Reference

| Table | Column | Valid Values |
|-------|--------|--------------|
| Case_Details | Status | Pending, Ongoing, Closed |
| Bail | Status | Granted, Denied, Pending |
| Appeal | Status | Pending, Granted, Dismissed |
| Appeal | Appeal_Level | District, High, Supreme |
| Court_Room | Availability_Status | Available, Occupied, Under Maintenance |
| Charges | Severity_Level | Minor, Felony |
| Witness | Type_of_Witness | Expert, Eyewitness, Character |
| Evidence | Type | Digital, Physical, Documentary |
| Court | Jurisdiction_Level | District, High, Supreme |

### 11.2 Specialization Values (Lawyer)

Sample values in database:
- Criminal
- Civil
- Family
- Corporate
- Labor
- Intellectual Property
- Environmental
- Tax
- Immigration
- Constitutional

### 11.3 Designation Values (Judge)

Sample values in database:
- District Judge
- High Court Judge
- Chief Justice
- Magistrate
- Additional Sessions Judge

### 11.4 Officer Rank Values

Sample values in database:
- Inspector
- Sub-Inspector
- Constable
- Assistant Commissioner
- Deputy Commissioner

---

## 12. Installation & Setup

### 12.1 Prerequisites
- MySQL 8.0 or higher
- MySQL Workbench (optional, for GUI)
- Minimum 500MB disk space

### 12.2 Installation Steps

#### Step 1: Create Database
```sql
CREATE DATABASE judicialcasedb;
USE judicialcasedb;
```

#### Step 2: Execute Scripts in Order
1. `1. DBMSL Project - Tables.sql` - Creates schema
2. `2. DBMSL Project - Sample Data.sql` - Inserts sample data
3. `3. DBMSL Project - Queries.sql` - Creates sample queries
4. `4. DBMSL Project - Views.sql` - Creates views
5. `5. DBMSL Project - Functions.sql` - Creates functions
6. `6. DBMSL Project - Procedures.sql` - Creates procedures
7. `7. DBMSL Project - Triggers.sql` - Creates triggers

### 12.3 Schema Modifications for Procedures
The Tables.sql includes ALTER statements for AUTO_INCREMENT:
```sql
ALTER TABLE Hearing MODIFY Hearing_ID INT AUTO_INCREMENT;
ALTER TABLE Case_History MODIFY History_ID INT AUTO_INCREMENT;
```

---

## 13. Usage Examples

### 13.1 Complete Case Workflow

```sql
-- 1. File a new case
INSERT INTO Case_Details (Case_ID, Case_Number, Filing_Date, Case_Type, Status, Category_ID, Court_ID)
VALUES (21, 'C-2025-021', '2025-04-01', 'Criminal', 'Pending', 1, 1);

-- 2. Create an FIR
INSERT INTO FIR (FIR_ID, Case_ID, Police_Station_ID, Filed_By, Date, Details, Crime_Location)
VALUES (21, 21, 1, 1, '2025-04-01', 'Theft reported', 'Connaught Place');

-- 3. Schedule a hearing
CALL Add_New_Hearing(21, 1, '2025-04-15', '10:00:00', 'Initial hearing');

-- 4. Assign charges
INSERT INTO Charges (Charge_ID, Case_ID, Legal_Act_ID, Description, Severity_Level, Charge_Date)
VALUES (21, 21, 1, 'Theft under section 379', 'Minor', '2025-04-05');

-- 5. Apply for bail (will succeed for minor charge)
INSERT INTO Bail (Bail_ID, Case_ID, Person_ID, Granted_Date, Conditions, Bail_Amount, Status)
VALUES (21, 21, 1, '2025-04-10', 'Weekly check-in', 5000.00, 'Granted');

-- 6. Record verdict and close case
CALL Finalize_Case(21, 21, 'Guilty with reduced sentence', 2000.00);
```

### 13.2 Court Administration

```sql
-- Check court workload
SELECT Court_Name, Get_Court_Load(Court_ID) AS Active_Cases 
FROM Court;

-- View available courtrooms
SELECT * FROM Court_Availability;

-- Assign staff to case
CALL Assign_Court_Staff(1, 1);

-- View pending cases
SELECT * FROM Pending_Cases_Overview;
```

### 13.3 Police Operations

```sql
-- View station activity
SELECT * FROM Police_Station_Activity;

-- Find evidence by inspector
SELECT e.*, po.Officer_Rank 
FROM Evidence e
JOIN Police_Officer po ON e.Collected_By = po.Person_ID
WHERE po.Officer_Rank = 'Inspector';
```

### 13.4 Legal Research

```sql
-- Find high-penalty cases
SELECT cd.Case_Number, v.Decision, v.Penalty
FROM Case_Details cd
JOIN Verdict v ON cd.Verdict_ID = v.Verdict_ID
WHERE v.Penalty > 10000
ORDER BY v.Penalty DESC;

-- Find experienced family lawyers
SELECT Name, Experience_Years, Specialization
FROM Lawyer
WHERE Specialization LIKE '%Family%' AND Experience_Years > 10;
```

---

## Appendix A: Sample Data Summary

| Table | Records | Description |
|-------|---------|-------------|
| Court | 5 | District, High, Supreme courts |
| Case_Category | 10 | Criminal, Civil, Family, etc. |
| Person | 50 | Individuals in the system |
| Lawyer | 20 | Various specializations |
| Judge | 10 | Different courts and designations |
| Police_Station | 5 | Major city stations |
| Police_Officer | 20 | Various ranks |
| Case_Details | 20 | Mixed status cases |
| Hearing | 20 | Scheduled hearings |
| FIR | 20 | Filed reports |
| Evidence | 20 | Various types |
| Charges | 20 | Linked to legal acts |
| Verdict | 20 | Case decisions |
| Bail | 20 | Granted bail records |
| Settlement | 20 | Out-of-court agreements |
| Appeal | 20 | Various appeal levels |
| Witness | 20 | Different witness types |
| Petitioner | 20 | Case initiators |
| Respondent | 20 | Defendants |
| Court_Staff | 20 | Clerks and administrators |
| Court_Room | 20 | Various capacities |
| Case_History | 20 | Audit records |
| Legal_Act | 10 | Reference laws |

**Total Records**: 380+

---

## Appendix B: ER Diagram Reference

The file `er.pdf` contains the complete Entity-Relationship diagram showing:
- All 23 entities
- Primary keys (underlined)
- Foreign key relationships (lines connecting entities)
- Cardinality notation
- Entity attributes

---

## Appendix C: Common Tasks Reference

### C.1 Find All Cases for a Lawyer
```sql
SELECT cd.* FROM Case_Details cd
JOIN Hearing h ON cd.Case_ID = h.Case_ID
JOIN Petitioner p ON p.Legal_Representative = [Lawyer_ID]
UNION
SELECT cd.* FROM Case_Details cd
JOIN Hearing h ON cd.Case_ID = h.Case_ID
JOIN Respondent r ON r.Legal_Representative = [Lawyer_ID];
```

### C.2 Calculate Case Duration
```sql
SELECT Case_Number, 
       Filing_Date, 
       v.Date AS Closing_Date,
       DATEDIFF(v.Date, Filing_Date) AS Days_To_Resolution
FROM Case_Details cd
LEFT JOIN Verdict v ON cd.Verdict_ID = v.Verdict_ID
WHERE Status = 'Closed';
```

### C.3 Court Efficiency Metrics
```sql
SELECT c.Court_Name,
       COUNT(DISTINCT cd.Case_ID) AS Total_Cases,
       SUM(CASE WHEN cd.Status = 'Closed' THEN 1 ELSE 0 END) AS Closed_Cases,
       AVG(DATEDIFF(v.Date, cd.Filing_Date)) AS Avg_Resolution_Days
FROM Court c
LEFT JOIN Case_Details cd ON c.Court_ID = cd.Court_ID
LEFT JOIN Verdict v ON cd.Verdict_ID = v.Verdict_ID
GROUP BY c.Court_ID, c.Court_Name;
```

---

## Conclusion

This Judicial Case Management Database System provides a comprehensive solution for managing court operations. The normalized schema ensures data integrity while the stored procedures, functions, and triggers automate common workflows. The sample data and queries enable immediate testing and demonstrate real-world usage scenarios.

**Key Strengths**:
- Complete case lifecycle management
- Normalized schema (3NF)
- Automated audit trails via triggers
- Standardized workflows via procedures
- Business logic encapsulation via functions
- Comprehensive views for reporting

**Database Statistics**:
- 23 tables
- 380+ sample records
- 5 views
- 5 functions
- 5 procedures
- 5 triggers
- 10+ sample queries
