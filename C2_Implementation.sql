-- DROP TABLES COMMANDS
DROP TABLE TOPIC_DIM;
DROP TABLE PROGRAM_DIM;
DROP TABLE LOCATION_DIM;
DROP TABLE MARITAL_STATUS_DIM;
DROP TABLE OCCUPATION_DIM;
DROP TABLE AGE_DIM;
DROP TABLE PROGRAM_LENGTH_DIM;
DROP TABLE TIME_DIM;
DROP TABLE EVENT_SIZE_DIM;
DROP TABLE PROGRAM_EVENT_HISTORY_DIM;
DROP TABLE MEDIA_DIM;
DROP TABLE SUBSCRIPTION_FACT_V1;
DROP TABLE INTEREST_FACT_V1;
DROP TABLE REGISTRATION_FACT_V1;
DROP TABLE ATTENDANCE_FACT_V1;
DROP TABLE PROGRAM_DIM2;
DROP TABLE PERSON_DIM;
DROP TABLE SUBSCRIPTION_DIM;
DROP TABLE ADDRES_DIM;
DROP TABLE EVENT_DIM;
DROP TABLE ATTENDANCE_DIM;
DROP TABLE REG_DIM;
DROP TABLE INTEREST_FACT_V2;
DROP TABLE REGISTRATION_FACT_V2;
DROP TABLE SUBSCRIPTION_FACT_V2;
DROP TABLE ATTENDANCE_FACT_V2;


-- VERSION-1 STAR SCHEMA - HIGH AGGREGATION (LEVEL 2)

-- CREATING DIMENSION TABLES.

-- TOPIC_DIM
CREATE TABLE TOPIC_DIM AS
SELECT * 
FROM TOPIC;

-- Check content of created table
SELECT * FROM TOPIC_DIM;

-- LOCATION_DIM

CREATE TABLE LOCATION_DIM AS 
SELECT DISTINCT ADDRESS_STATE
FROM ADDRESS;

-- Check content of created table
SELECT * FROM LOCATION_DIM;

-- Alter table to add Location ID
ALTER TABLE LOCATION_DIM ADD (LOCATION_ID NUMBER(1));

-- Create sequence to populate Location ID
CREATE SEQUENCE LOCATION_SEQ_ID
START WITH 1
INCREMENT BY 1
MAXVALUE 10
MINVALUE 1
NOCYCLE;

-- Udate LOCATION_DIM with LOCATION_ID values
UPDATE LOCATION_DIM SET LOCATION_ID = LOCATION_SEQ_ID.NEXTVAL;

-- drop sequence
DROP SEQUENCE LOCATION_SEQ_ID;

-- Check content of amended table
SELECT * FROM LOCATION_DIM;

-- MARITAL_STATUS_DIM

CREATE TABLE MARITAL_STATUS_DIM AS
SELECT DISTINCT PERSON_MARITAL_STATUS
FROM PERSON;

-- Check content of created table
SELECT * FROM MARITAL_STATUS_DIM;

-- Alter table to add Marital_satus_id 
ALTER TABLE MARITAL_STATUS_DIM ADD (MARITAL_STATUS_ID NUMBER(1));

-- Create sequence to populate Location ID
CREATE SEQUENCE MARITAL_STATUS_SEQ_ID
START WITH 1
INCREMENT BY 1
MAXVALUE 10
MINVALUE 1
NOCYCLE;

-- Update LOCATION_DIM with LOCATION_ID values
UPDATE MARITAL_STATUS_DIM SET MARITAL_STATUS_ID = MARITAL_STATUS_SEQ_ID.NEXTVAL;

-- drop sequence
DROP SEQUENCE MARITAL_STATUS_SEQ_ID;

-- Check content of amended table
SELECT * FROM MARITAL_STATUS_DIM;

-- OCCUPATION_DIM

CREATE TABLE OCCUPATION_DIM
(
OCCUPATION_ID NUMBER(1),
OCCUPATION_NAME VARCHAR2(20)
);

-- insert values into table
INSERT INTO OCCUPATION_DIM VALUES (1, 'Student');
INSERT INTO OCCUPATION_DIM VALUES (2, 'Staff');
INSERT INTO OCCUPATION_DIM VALUES (3, 'Community');

-- checking content of created table
SELECT * FROM OCCUPATION_DIM;

-- AGE_DIM

CREATE TABLE AGE_DIM
(
AGE_GROUP_ID NUMBER(1),
AGE_GROUP VARCHAR2(20),
AGE_GROUP_DESCRIPTION VARCHAR2(20)
);

-- insert values into table
INSERT INTO AGE_DIM VALUES (1, 'Child', '0-16 years old');
INSERT INTO AGE_DIM VALUES (2, 'Young adults', '17-30 years old');
INSERT INTO AGE_DIM VALUES (3, 'Middle-aged adults', '31-45 years old');
INSERT INTO AGE_DIM VALUES (4, 'Old-aged adults', 'Over 45 years old');

-- checking content of created table
SELECT * FROM AGE_DIM;

-- PROGRAM_DIM

CREATE TABLE PROGRAM_DIM AS
SELECT PROGRAM_ID, PROGRAM_NAME, PROGRAM_DETAILS, PROGRAM_FEE, PROGRAM_FREQUENCY
FROM PROGRAM;

-- Check content of created table
SELECT * FROM PROGRAM_DIM;

-- PROGRAM_LENGTH_DIM

CREATE TABLE PROGRAM_LENGTH_DIM
(
PROGRAM_LENGTH_ID NUMBER(1),
PROGRAM_LENGTH VARCHAR2(20),
PROGRAM_LENGTH_DESCRIPTION VARCHAR2(40)
);

-- insert values into table
INSERT INTO PROGRAM_LENGTH_DIM VALUES (1, 'short', 'event < three sessions');
INSERT INTO PROGRAM_LENGTH_DIM VALUES (2, 'medium', 'event between three to six sessions');
INSERT INTO PROGRAM_LENGTH_DIM VALUES (3, 'long', 'event > six sessions');

-- checking content of created table
SELECT * FROM PROGRAM_LENGTH_DIM;

-- TIME_DIM

CREATE TABLE TIME_DIM AS
SELECT
DISTINCT TO_CHAR(SUBSCRIPTION_DATE, 'YYYYMM') AS TIME_ID,
TO_CHAR(SUBSCRIPTION_DATE, 'YYYY') AS YEAR,
TO_CHAR(SUBSCRIPTION_DATE, 'MM') AS MONTH
FROM SUBSCRIPTION
UNION
SELECT
DISTINCT TO_CHAR(ATT_DATE, 'YYYYMM') AS TIME_ID,
TO_CHAR(ATT_DATE, 'YYYY') AS YEAR,
TO_CHAR(ATT_DATE, 'MM') AS MONTH
FROM ATTENDANCE
UNION
SELECT
DISTINCT TO_CHAR(REG_DATE, 'YYYYMM') AS TIME_ID,
TO_CHAR(REG_DATE, 'YYYY') AS YEAR,
TO_CHAR(REG_DATE, 'MM') AS MONTH
FROM REGISTRATION;

-- checking content of created table
SELECT * FROM TIME_DIM;

-- PROGRAM_EVENT_HISTORY_DIM

CREATE TABLE PROGRAM_EVENT_HISTORY_DIM
AS SELECT DISTINCT PROGRAM_ID, EVENT_START_DATE, EVENT_END_DATE, EVENT_COST
FROM EVENT;

-- checking content of created table
SELECT * FROM PROGRAM_EVENT_HISTORY_DIM;

-- EVENT_SIZE_DIM

CREATE TABLE EVENT_SIZE_DIM
(
EVENT_SIZE_ID NUMBER(1),
EVENT_SIZE VARCHAR2(20),
EVENT_SIZE_DESCRIPTION VARCHAR2(40)
);

-- insert values into table
INSERT INTO EVENT_SIZE_DIM VALUES (1, 'small', 'event <= 10 people');
INSERT INTO EVENT_SIZE_DIM VALUES (2, 'medium', 'event between 11 and 30 people');
INSERT INTO EVENT_SIZE_DIM VALUES (3, 'large', 'event > 30 people');

-- checking content of created table
SELECT * FROM EVENT_SIZE_DIM;

-- MEDIA_DIM

CREATE TABLE MEDIA_DIM AS
SELECT * 
FROM MEDIA_CHANNEL;

-- checking content of created table
SELECT * FROM MEDIA_DIM;



-- CREATING A FACT TABLES

-- INTEREST_FACT_V1
--Create temp fact
CREATE TABLE TEMP_INTEREST_FACT_V1 AS
SELECT T.TOPIC_ID, PE.PERSON_MARITAL_STATUS, (CASE 
WHEN PE.PERSON_JOB = 'Student' THEN 'Student'
WHEN PE.PERSON_JOB = 'Staff' THEN 'Staff'
ELSE 'Community'
END) AS OCCUPATION, A.ADDRESS_STATE, 
(CASE 
WHEN PE.PERSON_AGE >=0 AND PE.PERSON_AGE <=16 THEN 'Child'
WHEN PE.PERSON_AGE >=17 AND PE.PERSON_AGE <=30 THEN 'Young adults'
WHEN PE.PERSON_AGE >=31 AND PE.PERSON_AGE <=45 THEN 'Middle-aged adults'
ELSE 'Old-aged adults'
END) AS AGE
FROM TOPIC T, PERSON PE, ADDRESS A, PERSON_INTEREST PI
WHERE A.ADDRESS_ID = PE.ADDRESS_ID AND
PE.PERSON_ID = PI.PERSON_ID AND
PI.TOPIC_ID = T.TOPIC_ID;

-- Check content of created table
SELECT * FROM TEMP_INTEREST_FACT_V1;

-- Alter temp fact, add required attributes
ALTER TABLE TEMP_INTEREST_FACT_V1
ADD (MARITAL_STATUS_ID NUMBER(1));

ALTER TABLE TEMP_INTEREST_FACT_V1
ADD (OCCUPATION_ID NUMBER(1));

ALTER TABLE TEMP_INTEREST_FACT_V1
ADD (LOCATION_ID NUMBER(1));

ALTER TABLE TEMP_INTEREST_FACT_V1
ADD (AGE_GROUP_ID NUMBER(1));

-- Check altered table
SELECT * FROM TEMP_INTEREST_FACT_V1;

-- Update values in the temp fact 
UPDATE TEMP_INTEREST_FACT_V1 TF
SET TF.MARITAL_STATUS_ID = (SELECT S.MARITAL_STATUS_ID
FROM MARITAL_STATUS_DIM S
WHERE S.PERSON_MARITAL_STATUS = TF.PERSON_MARITAL_STATUS);

UPDATE TEMP_INTEREST_FACT_V1 TF
SET TF.OCCUPATION_ID = (SELECT S.OCCUPATION_ID
FROM OCCUPATION_DIM S
WHERE S.OCCUPATION_NAME = TF.OCCUPATION);

UPDATE TEMP_INTEREST_FACT_V1 TF
SET TF.LOCATION_ID = (SELECT S.LOCATION_ID
FROM LOCATION_DIM S
WHERE S.ADDRESS_STATE = TF.ADDRESS_STATE);

UPDATE TEMP_INTEREST_FACT_V1 TF
SET TF.AGE_GROUP_ID = (SELECT S.AGE_GROUP_ID
FROM AGE_DIM S
WHERE S.AGE_GROUP = TF.AGE);

-- Create INTEREST_FACT_V1
CREATE TABLE INTEREST_FACT_V1 AS
SELECT TOPIC_ID,MARITAL_STATUS_ID, OCCUPATION_ID, LOCATION_ID,AGE_GROUP_ID,
COUNT(*) AS NUMBEROFPEOPLEINTERESTED
FROM TEMP_INTEREST_FACT_V1
GROUP BY TOPIC_ID,MARITAL_STATUS_ID, OCCUPATION_ID, LOCATION_ID,AGE_GROUP_ID;

-- Check content of created table
SELECT * FROM INTEREST_FACT_V1;

-- Drop temp fact
DROP TABLE TEMP_INTEREST_FACT_V1;


-- SUBSCRIPTION_FACT_V1

-- Creating temp fact
CREATE TABLE TEMP_SUBSCRIPTION_FACT_V1 AS
SELECT P.PROGRAM_ID,P.PROGRAM_LENGTH, PE.PERSON_MARITAL_STATUS,PE.PERSON_JOB , a.address_state, 
PE.PERSON_AGE, S.SUBSCRIPTION_DATE
FROM PROGRAM P, PERSON PE, ADDRESS A, SUBSCRIPTION S
WHERE A.ADDRESS_ID = PE.ADDRESS_ID AND
PE.PERSON_ID = S.PERSON_ID AND
S.PROGRAM_ID = P.PROGRAM_ID;

-- checking content of created table
SELECT * FROM TEMP_SUBSCRIPTION_FACT_V1;

-- altering temp fact, adding required attributes
-- add PROGRAM_LENGTH_ID
ALTER TABLE TEMP_SUBSCRIPTION_FACT_V1
ADD (PROGRAM_LENGTH_ID NUMBER(1));

-- add MARITAL_STATUS_ID
ALTER TABLE TEMP_SUBSCRIPTION_FACT_V1
ADD (MARITAL_STATUS_ID NUMBER(1));

-- add OCCUPATION_ID
ALTER TABLE TEMP_SUBSCRIPTION_FACT_V1
ADD (OCCUPATION_ID NUMBER(1));

-- add LOCATION_ID
ALTER TABLE TEMP_SUBSCRIPTION_FACT_V1
ADD (LOCATION_ID NUMBER(1));

-- add AGE_GROUP_ID
ALTER TABLE TEMP_SUBSCRIPTION_FACT_V1
ADD (AGE_GROUP_ID NUMBER(1));

-- add TIME_ID
ALTER TABLE TEMP_SUBSCRIPTION_FACT_V1
ADD (TIME_ID VARCHAR(6));

-- add PROGRAM_LENGTH_SIZE
ALTER TABLE TEMP_SUBSCRIPTION_FACT_V1 
ADD (PROGRAM_LENGTH_SIZE NUMBER(3));

-- updating values of created attributes
-- update PROGRAM_LENGTH_SIZE
UPDATE TEMP_SUBSCRIPTION_FACT_V1
SET PROGRAM_LENGTH_SIZE = SUBSTR(PROGRAM_LENGTH, 1, INSTR(PROGRAM_LENGTH, ' ')-1);

-- update PROGRAM_LENGTH_ID
UPDATE TEMP_SUBSCRIPTION_FACT_V1
SET PROGRAM_LENGTH_ID = CASE
WHEN PROGRAM_LENGTH_SIZE < 3 THEN 1
WHEN PROGRAM_LENGTH_SIZE >=3 AND PROGRAM_LENGTH_SIZE <=6 THEN 2
ELSE 3
END;

-- update MARITAL_STATUS_ID
UPDATE TEMP_SUBSCRIPTION_FACT_V1 TF
SET TF.MARITAL_STATUS_ID = (SELECT S.MARITAL_STATUS_ID
FROM MARITAL_STATUS_DIM S
WHERE S.PERSON_MARITAL_STATUS = TF.PERSON_MARITAL_STATUS);

-- update OCCUPATION_ID
UPDATE TEMP_SUBSCRIPTION_FACT_V1
SET OCCUPATION_ID = CASE
WHEN PERSON_JOB = 'Student' THEN 1
WHEN PERSON_JOB = 'Staff' THEN 2
ELSE 3
END;
-- update LOCATION_ID
UPDATE TEMP_SUBSCRIPTION_FACT_V1 TF
SET TF.LOCATION_ID = (SELECT S.LOCATION_ID
FROM LOCATION_DIM S
WHERE S.ADDRESS_STATE = TF.ADDRESS_STATE);

-- update AGE_GROUP_ID
UPDATE TEMP_SUBSCRIPTION_FACT_V1 TF
SET TF.AGE_GROUP_ID = CASE 
WHEN PERSON_AGE >=0 AND PERSON_AGE <=16 THEN 1
WHEN PERSON_AGE >=17 AND PERSON_AGE <=30 THEN 2
WHEN PERSON_AGE >=31 AND PERSON_AGE <=45 THEN 3
ELSE 4
END;

-- update TIME_ID
UPDATE TEMP_SUBSCRIPTION_FACT_V1
SET TIME_ID = TO_CHAR(SUBSCRIPTION_DATE,'YYYYMM');

-- Checking content of altered table
SELECT * FROM TEMP_SUBSCRIPTION_FACT_V1;

-- commit changes
COMMIT;

-- SUBSCRIPTION_FACT_V1
CREATE TABLE SUBSCRIPTION_FACT_V1 AS
SELECT PROGRAM_ID, PROGRAM_LENGTH_ID, MARITAL_STATUS_ID, OCCUPATION_ID, LOCATION_ID, AGE_GROUP_ID, TIME_ID,
COUNT(*) AS NUMBEROFPEOPLESUBSCRIBED
FROM TEMP_SUBSCRIPTION_FACT_V1
GROUP BY PROGRAM_ID, PROGRAM_LENGTH_ID, MARITAL_STATUS_ID, OCCUPATION_ID, LOCATION_ID, AGE_GROUP_ID, TIME_ID;

-- Checking content of created table
SELECT * FROM SUBSCRIPTION_FACT_V1;

-- Drop temp fact
DROP TABLE TEMP_SUBSCRIPTION_FACT_V1;



-- REGISTRATION_FACT_V1

-- Create temp fact
CREATE table TEMP_REGISTRATION_FACT_V1 AS
SELECT (CASE 
WHEN PE.PERSON_MARITAL_STATUS = 'Not married' THEN 1
WHEN PE.PERSON_MARITAL_STATUS = 'Divorced' THEN 2
ELSE 3
END) AS MARITAL_STATUS_ID, (CASE 
WHEN PE.PERSON_JOB = 'Student' then 1
when PE.PERSON_JOB = 'Staff' then 2
else 3
end) AS OCCUPATION_ID, a.address_state, (CASE 
WHEN PE.person_age >=0 and PE.person_age <=16 then 1
when PE.person_age >=17 and PE.person_age <=30 then 2
when PE.person_age >=31 and PE.person_age <=45 then 3
else 4
end) AS AGE_GROUP_ID, (CASE 
WHEN E.EVENT_SIZE<= 10 THEN  1
when E.EVENT_SIZE >10 and E.EVENT_SIZE <=30 then 2
else 3
end) AS EVENT_SIZE_ID, M.MEDIA_ID, TO_CHAR(R.REG_DATE, 'YYYYMM') AS TIME_ID, R.REG_NUM_OF_PEOPLE_REGISTERED
FROM ADDRESS A, PERSON PE, REGISTRATION R, MEDIA_CHANNEL M, EVENT E
WHERE A.ADDRESS_ID = PE.ADDRESS_ID AND
PE.PERSON_ID = R.PERSON_ID AND
R.EVENT_ID = E.EVENT_ID AND
R.MEDIA_ID = M.MEDIA_ID;

-- Check content of created table
select * from TEMP_REGISTRATION_FACT_V1;

-- alter table, add location_id
ALTER TABLE TEMP_REGISTRATION_FACT_V1
ADD (LOCATION_ID NUMBER(1));

-- update location_id
UPDATE TEMP_REGISTRATION_FACT_V1 TF
SET TF.LOCATION_ID = (SELECT S.LOCATION_ID
FROM LOCATION_DIM S
WHERE S.ADDRESS_STATE = TF.ADDRESS_STATE);

-- Check content of altered and updated table
select * from TEMP_REGISTRATION_FACT_V1;

-- Create REGISTRATION_FACT_V1
CREATE TABLE REGISTRATION_FACT_V1 AS
SELECT MARITAL_STATUS_ID, OCCUPATION_ID, LOCATION_ID, AGE_GROUP_ID,
EVENT_SIZE_ID, MEDIA_ID, TIME_ID, SUM(REG_NUM_OF_PEOPLE_REGISTERED) AS NumberOfPeopleRegistered
FROM TEMP_REGISTRATION_FACT_V1
GROUP BY  MARITAL_STATUS_ID, OCCUPATION_ID, LOCATION_ID, AGE_GROUP_ID,
EVENT_SIZE_ID, MEDIA_ID, TIME_ID ;

-- Check content of created table
SELECT * FROM REGISTRATION_FACT_V1;

-- Drop temp fact
DROP TABLE TEMP_REGISTRATION_FACT_V1;


-- ATTENDANCE_FACT_V1


-- Creating the ATTENDANCE_TEMP_FACT
CREATE TABLE ATTENDANCE_TEMP_FACT 
    AS
        SELECT 
            PR.PROGRAM_ID,
            PR.PROGRAM_LENGTH,
            PE.PERSON_MARITAL_STATUS,
            PE.PERSON_JOB,
            AD.ADDRESS_STATE,
            PE.PERSON_AGE,
            ev.event_size,
            att.att_date,
            ATT.ATT_NUM_OF_PEOPLE_ATTENDED,
            ATT.ATT_DONATION_AMOUNT
        FROM 
            PROGRAM PR JOIN EVENT EV
                ON PR.PROGRAM_ID = EV.PROGRAM_ID
            JOIN ATTENDANCE ATT 
                ON ATT.EVENT_ID = EV.EVENT_ID
            JOIN PERSON PE
                ON PE.PERSON_ID = ATT.PERSON_ID
            JOIN ADDRESS AD
                ON AD.ADDRESS_ID = PE.ADDRESS_ID;
                
-- Adding the identifiers of newly created dimensions.
ALTER TABLE ATTENDANCE_TEMP_FACT ADD (PROGRAM_LENGTH_ID NUMBER(2));
ALTER TABLE ATTENDANCE_TEMP_FACT ADD (MARITAL_STATUS_ID NUMBER(2));
ALTER TABLE ATTENDANCE_TEMP_FACT ADD (OCCUPATION_ID NUMBER(2));
ALTER TABLE ATTENDANCE_TEMP_FACT ADD (LOCATION_ID NUMBER(2));
ALTER TABLE ATTENDANCE_TEMP_FACT ADD (AGE_GROUP_ID NUMBER(2));
ALTER TABLE ATTENDANCE_TEMP_FACT ADD (EVENT_SIZE_ID NUMBER(2));
ALTER TABLE ATTENDANCE_TEMP_FACT ADD (PROGRAM_LENGTH_SIZE NUMBER(3));
ALTER TABLE ATTENDANCE_TEMP_FACT ADD (TIME_ID VARCHAR2(6));

-- Update the PROGRAM_LENGTH_SIZE to capture the number of sessions
UPDATE ATTENDANCE_TEMP_FACT ATT_TF
SET ATT_TF.PROGRAM_LENGTH_SIZE = 
    SUBSTR(ATT_TF.PROGRAM_LENGTH, 1, INSTR(ATT_TF.PROGRAM_LENGTH, ' ')-1);

-- update the PROGRAM_LENGTH_ID identifier
UPDATE ATTENDANCE_TEMP_FACT
SET PROGRAM_LENGTH_ID = 1
WHERE PROGRAM_LENGTH_SIZE < 3;

UPDATE ATTENDANCE_TEMP_FACT
SET PROGRAM_LENGTH_ID = 2
WHERE PROGRAM_LENGTH_SIZE >= 3 
     AND PROGRAM_LENGTH_SIZE <= 6;
     
UPDATE ATTENDANCE_TEMP_FACT
SET PROGRAM_LENGTH_ID = 3
WHERE PROGRAM_LENGTH_SIZE > 6;

-- update the MARITAL_STATUS_ID identifier
UPDATE ATTENDANCE_TEMP_FACT
SET MARITAL_STATUS_ID = 1
WHERE PERSON_MARITAL_STATUS = 'Not married' ;

UPDATE ATTENDANCE_TEMP_FACT
SET MARITAL_STATUS_ID = 2
WHERE PERSON_MARITAL_STATUS = 'Divorced' ;

UPDATE ATTENDANCE_TEMP_FACT
SET MARITAL_STATUS_ID = 3
WHERE PERSON_MARITAL_STATUS = 'Married' ;

-- update the OCCUPATION_ID identifier
UPDATE ATTENDANCE_TEMP_FACT
SET OCCUPATION_ID = 1
WHERE person_job = 'Student' ;

UPDATE ATTENDANCE_TEMP_FACT
SET OCCUPATION_ID = 2
WHERE person_job = 'Staff' ;

UPDATE ATTENDANCE_TEMP_FACT
SET OCCUPATION_ID = 3
WHERE person_job NOT IN ('Student','Staff') ;

-- update the LOCATION_ID identifier
UPDATE ATTENDANCE_TEMP_FACT
SET LOCATION_ID = 1
WHERE ADDRESS_STATE = 'QLD' ;

UPDATE ATTENDANCE_TEMP_FACT
SET LOCATION_ID = 2
WHERE ADDRESS_STATE = 'SA' ;

UPDATE ATTENDANCE_TEMP_FACT
SET LOCATION_ID = 3
WHERE ADDRESS_STATE = 'NSW' ;

UPDATE ATTENDANCE_TEMP_FACT
SET LOCATION_ID = 4
WHERE ADDRESS_STATE = 'WA' ;

UPDATE ATTENDANCE_TEMP_FACT
SET LOCATION_ID = 5
WHERE ADDRESS_STATE = 'ACT' ;

UPDATE ATTENDANCE_TEMP_FACT
SET LOCATION_ID = 6
WHERE ADDRESS_STATE = 'VIC' ;

UPDATE ATTENDANCE_TEMP_FACT
SET LOCATION_ID = 7
WHERE ADDRESS_STATE = 'TAS' ;

-- update the AGE_GROUP_ID identifier
UPDATE ATTENDANCE_TEMP_FACT
SET AGE_GROUP_ID = 1
WHERE PERSON_AGE <= 16;

UPDATE ATTENDANCE_TEMP_FACT
SET AGE_GROUP_ID = 2
WHERE PERSON_AGE >= 17 
AND PERSON_AGE <=30;

UPDATE ATTENDANCE_TEMP_FACT
SET AGE_GROUP_ID = 3
WHERE PERSON_AGE >= 31 
AND PERSON_AGE <=45;

UPDATE ATTENDANCE_TEMP_FACT
SET AGE_GROUP_ID = 4
WHERE PERSON_AGE > 45;

-- update the EVENT_SIZE_ID identifier
UPDATE ATTENDANCE_TEMP_FACT
SET EVENT_SIZE_ID = 1
WHERE EVENT_SIZE <= 10;

UPDATE ATTENDANCE_TEMP_FACT
SET EVENT_SIZE_ID = 2
WHERE EVENT_SIZE >= 11 
AND EVENT_SIZE <= 30;

UPDATE ATTENDANCE_TEMP_FACT
SET EVENT_SIZE_ID = 3
WHERE EVENT_SIZE > 30;

-- update the TIME_ID identifier
UPDATE ATTENDANCE_TEMP_FACT ATT
SET TIME_ID = TO_CHAR(ATT.ATT_DATE, 'YYYYMM');

-- checking the ATTENDANCE_TEMP_FACT after updates
SELECT * FROM ATTENDANCE_TEMP_FACT;

-- Creating the final Attendance fact table
CREATE TABLE ATTENDANCE_FACT_V1
    AS
SELECT 
    PROGRAM_ID,
    PROGRAM_LENGTH_ID,
    MARITAL_STATUS_ID,
    OCCUPATION_ID, 
    LOCATION_ID, 
    AGE_GROUP_ID, 
    EVENT_SIZE_ID,
    SUM(ATT_NUM_OF_PEOPLE_ATTENDED) NO_PEOPLE_ATTENDED,
    SUM(ATT_DONATION_AMOUNT) TOTAL_DONATION
FROM 
    ATTENDANCE_TEMP_FACT
GROUP BY 
    PROGRAM_ID,
    PROGRAM_LENGTH_ID,
    MARITAL_STATUS_ID,
    OCCUPATION_ID, 
    LOCATION_ID, 
    AGE_GROUP_ID, 
    EVENT_SIZE_ID;

-- Observe the Attendance fact table
SELECT * FROM ATTENDANCE_FACT_V1;

-- Drop temp fact
DROP TABLE ATTENDANCE_TEMP_FACT;


-- VERSION-2 NO AGGREGATION (LEVEL 0)

-- CREATING DIMENSIONS:

--EVENT_DIM

CREATE TABLE EVENT_DIM AS
SELECT EVENT_ID, EVENT_START_DATE,EVENT_END_DATE,EVENT_SIZE, EVENT_LOCATION, EVENT_COST  
FROM EVENT;

-- Check content of created table
SELECT * FROM EVENT_DIM;

--PROGRAM_DIM2

CREATE TABLE PROGRAM_DIM2 AS
SELECT PROGRAM_ID, PROGRAM_NAME, PROGRAM_DETAILS, PROGRAM_FEE,PROGRAM_LENGTH, PROGRAM_FREQUENCY
FROM PROGRAM;

-- Check content of created table
SELECT * FROM PROGRAM_DIM2;

-- PERSON_DIM

CREATE TABLE PERSON_DIM AS
SELECT PERSON_ID, PERSON_NAME, PERSON_PHONE, PERSON_AGE, PERSON_EMAIL, PERSON_GENDER, PERSON_JOB, PERSON_MARITAL_STATUS
FROM PERSON;

-- Check content of created table
SELECT * FROM PERSON_DIM;

-- SUBSCRIPTION_DIM

CREATE TABLE SUBSCRIPTION_DIM AS
SELECT SUBSCRIPTION_ID, SUBSCRIPTION_DATE
FROM SUBSCRIPTION;

-- Check content of created table
SELECT * FROM SUBSCRIPTION_DIM;


-- ADDRES_DIM

CREATE TABLE ADDRES_DIM AS
SELECT * 
FROM ADDRESS;

-- Check content of created table
SELECT * FROM ADDRES_DIM;

-- ATTENDANCE_DIM

CREATE TABLE ATTENDANCE_DIM AS
SELECT ATT_ID, ATT_DATE
FROM ATTENDANCE;

-- Check content of created table
SELECT * FROM ATTENDANCE_DIM;

-- REG_DIM
CREATE TABLE REG_DIM 
    AS
        SELECT REG_ID, REG_DATE FROM REGISTRATION;

-- Check Registration dimension
SELECT * FROM REG_DIM;

-- CREATING FACT TABLES

-- INTEREST_FACT_V2
CREATE TABLE INTEREST_FACT_V2 
    AS
        SELECT 
            T.TOPIC_ID,
            PE.PERSON_ID,
            AD.ADDRESS_ID,
            COUNT(*) NO_PEOPLE_INTERESTED
        FROM 
            PERSON PE JOIN PERSON_INTEREST PI
                ON PE.PERSON_ID = PI.PERSON_ID
            JOIN TOPIC T
                ON T.TOPIC_ID = PI.TOPIC_ID
            JOIN ADDRESS AD
                ON AD.ADDRESS_ID = PE.ADDRESS_ID
        GROUP BY 
            T.TOPIC_ID, PE.PERSON_ID, AD.ADDRESS_ID;

-- Observe the created Interest Fact table
SELECT * FROM INTEREST_FACT_V2 ;

-- REGISTRATION_FACT_V2

CREATE TABLE REGISTRATION_FACT_V2
    AS
        SELECT 
        PE.PERSON_ID, AD.ADDRESS_ID,
        RE.EVENT_ID, RE.MEDIA_ID,
        RE.REG_ID,
        SUM(RE.REG_NUM_OF_PEOPLE_REGISTERED) NO_PEOPLE_REGISTERED
    FROM 
        PERSON PE JOIN REGISTRATION RE
            ON PE.PERSON_ID = RE.PERSON_ID
        JOIN ADDRESS AD
            ON AD.ADDRESS_ID = PE.ADDRESS_ID
    GROUP BY 
        PE.PERSON_ID, AD.ADDRESS_ID,
        RE.EVENT_ID, RE.MEDIA_ID,
        RE.REG_ID;

-- Observe the created Registration Fact table
SELECT * FROM REGISTRATION_FACT_V2;


-- SUBSCRIPTION_FACT_V2

CREATE TABLE SUBSCRIPTION_FACT_V2
AS
SELECT 
    PR.PROGRAM_ID,
    PE.PERSON_ID,
    SU.SUBSCRIPTION_ID,
    AD.ADDRESS_ID,
    COUNT(*) NO_PEOPLE_SUBSCRIPTION
FROM 
    PERSON PE JOIN ADDRESS AD
    ON PE.ADDRESS_ID = AD.ADDRESS_ID
    JOIN SUBSCRIPTION SU
    ON SU.PERSON_ID = PE.PERSON_ID
    JOIN PROGRAM PR
    ON PR.PROGRAM_ID = SU.PROGRAM_ID
GROUP BY 
    PR.PROGRAM_ID,
    PE.PERSON_ID,
    SU.SUBSCRIPTION_ID,
    AD.ADDRESS_ID;
    
-- Observe the created Subscription Fact table
SELECT * FROM SUBSCRIPTION_FACT_V2;

--ATTENDANCE_FACT_V2

-- Create ATTENDANCE_FACT_V2
CREATE TABLE ATTENDANCE_FACT_V2 AS
SELECT P.PROGRAM_ID, PE.PERSON_ID, A.ADDRESS_ID, E.EVENT_ID, 
ATT.ATT_ID, SUM(ATT.ATT_NUM_OF_PEOPLE_ATTENDED) AS NumberOfPeopleAttended,
SUM(ATT.ATT_DONATION_AMOUNT) AS TotalDonation
FROM ADDRESS A, PERSON PE, ATTENDANCE ATT, EVENT E, PROGRAM P
WHERE A.ADDRESS_ID = PE.ADDRESS_ID AND
PE.PERSON_ID = ATT.PERSON_ID AND
ATT.EVENT_ID = E.EVENT_ID AND
E.PROGRAM_ID = P.PROGRAM_ID
GROUP BY P.PROGRAM_ID, PE.PERSON_ID, A.ADDRESS_ID, E.EVENT_ID, 
ATT.ATT_ID;

-- check content of created table
SELECT * FROM ATTENDANCE_FACT_V2;

















