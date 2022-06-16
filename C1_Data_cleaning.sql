-- Drop tables
drop table TOPIC;
drop table PROGRAM;
drop table EVENT;
drop table MEDIA_CHANNEL;
drop table EVENT_MARKETING;
drop table PERSON;
drop table ADDRESS;
drop table VOLUNTEER;
drop table PARTICIPANT;
drop table FOLLOW_UP;
drop table PERSON_INTEREST;
drop table SUBSCRIPTION;
drop table ATTENDANCE;
drop table REGISTRATION;


-- copying all tables from MonExplore account

create table TOPIC as
select * from MonExplore.TOPIC;

create table PROGRAM as
select * from MonExplore.PROGRAM;

create table EVENT as
select * from MonExplore.EVENT;

create table MEDIA_CHANNEL as
select * from MonExplore.MEDIA_CHANNEL;

create table EVENT_MARKETING as
select * from MonExplore.EVENT_MARKETING;

create table PERSON as
select * from MonExplore.PERSON;

create table ADDRESS as
select * from MonExplore.ADDRESS;

create table VOLUNTEER as
select * from MonExplore.VOLUNTEER;

create table PARTICIPANT as
select * from MonExplore.PARTICIPANT;

create table FOLLOW_UP as
select * from MonExplore.FOLLOW_UP;

create table PERSON_INTEREST as
select * from MonExplore.PERSON_INTEREST;

create table SUBSCRIPTION as
select * from MonExplore.SUBSCRIPTION;

create table ATTENDANCE as
select * from MonExplore.ATTENDANCE;

create table REGISTRATION as
select * from MonExplore.REGISTRATION;

-- Error 1
-- EVENT table
-- observe event table
select * from event;

-- Checking event table for records, where start date is greater than end date:
select * from event
where to_date(event_start_date) > to_date(event_end_date);

-- Update event 162:
update event
set event_start_date = TO_DATE('17-SEP-2020', 'DD-MON-YYYY'),
event_end_date = TO_DATE('17-OCT-2020', 'DD-MON-YYYY')
where event_id = 162;

-- observe changes
SELECT * FROM EVENT
WHERE EVENT_ID = 162;

-- Update event 163:
UPDATE EVENT
SET EVENT_START_DATE = TO_DATE('17-OCT-2020', 'DD-MON-YYYY'),
EVENT_END_DATE = TO_DATE('18-OCT-2020', 'DD-MON-YYYY')
WHERE EVENT_ID = 163;

-- observe changes
SELECT * FROM EVENT
WHERE EVENT_ID = 163;

--commit changes
COMMIT;

-- Error 2
--PERSON table
--Checking table for duplicate records:

SELECT PERSON_ID, COUNT(*)
FROM PERSON
GROUP BY PERSON_ID
HAVING COUNT(*) > 1;

--Looking for found duplicate records in table:
SELECT * FROM PERSON
WHERE PERSON_ID = 'PE057' OR PERSON_ID = 'PE078' OR PERSON_ID = 'PE021'
ORDER BY PERSON_ID;

-- Create new table with distinct PK:
CREATE TABLE PERSON2 AS
SELECT DISTINCT *
FROM PERSON;

--Checking new table for duplicate records:
SELECT PERSON_ID, COUNT(*)
FROM PERSON2
GROUP BY PERSON_ID
HAVING COUNT(*) > 1;

--Dropping old table person:
DROP TABLE PERSON;

--Recreating table person with distinct PK:
CREATE TABLE PERSON AS
SELECT  *
FROM PERSON2;

--Drop table person2:
DROP TABLE PERSON2;


--Error 3:
--Table EVENT

-- Checking if event size contains out of range values
SELECT * FROM EVENT
WHERE EVENT_SIZE < 0;

-- Updating event table:
UPDATE EVENT
SET EVENT_SIZE = EVENT_SIZE * (-1)
WHERE EVENT_SIZE < 0;

-- Checking results:
SELECT * FROM EVENT
WHERE EVENT_SIZE < 0;

--commit changes
COMMIT;

-- Error 4:
-- Table EVENT

-- Checking invalid FK values (program_id):
SELECT * FROM EVENT
WHERE PROGRAM_ID NOT IN (
SELECT PROGRAM_ID FROM PROGRAM);

-- Checking found invalid FK in PROGRAM table:
SELECT * FROM PROGRAM
WHERE PROGRAM_ID = 'PR000';

SELECT * FROM PROGRAM
WHERE PROGRAM_ID = 'PR020';

-- Checking event_id with invalid FK in connected tables:
SELECT * FROM EVENT_MARKETING
WHERE EVENT_ID = 31 OR EVENT_ID = 101;

SELECT * FROM ATTENDANCE
WHERE EVENT_ID = 31 OR EVENT_ID = 101
ORDER BY EVENT_ID;

-- Updating EVENT table:
UPDATE EVENT
SET PROGRAM_ID = NULL
WHERE PROGRAM_ID NOT IN (
SELECT PROGRAM_ID FROM PROGRAM);

-- Checking results:
SELECT * FROM EVENT
WHERE EVENT_ID = 31 OR EVENT_ID = 101;

SELECT * FROM EVENT
WHERE PROGRAM_ID NOT IN (
SELECT PROGRAM_ID FROM PROGRAM);

-- Commit changes:
COMMIT;

-- Error 5:
-- MEDIA_CHANNEL table

-- Observe table:
SELECT * FROM MEDIA_CHANNEL;

-- Observe REGISTRATION table FK in MEDIA_CHANNEL
SELECT * FROM REGISTRATION
WHERE MEDIA_ID NOT IN (SELECT MEDIA_ID FROM MEDIA_CHANNEL);

-- Observe EVENT_MARKETING table FK in MEDIA_CHANNEL
SELECT *
FROM EVENT_MARKETING 
WHERE MEDIA_ID NOT IN
(SELECT MEDIA_ID FROM MEDIA_CHANNEL);

-- Delete incorrect PK:
DELETE FROM MEDIA_CHANNEL
WHERE MEDIA_ID IS NULL;

-- Observe changes:
SELECT * FROM MEDIA_CHANNEL;

-- Error 6:
-- TOPIC table

-- Observe table:
SELECT * FROM TOPIC;

-- Observe PROGRAM table:
SELECT * FROM PROGRAM
WHERE TOPIC_ID = 'T010';

--Observe PERSON_INTEREST table:
SELECT * FROM PERSON_INTEREST
WHERE TOPIC_ID = 'T010';

--Delete null record from topic:
DELETE FROM TOPIC WHERE TOPIC_ID = 'T010';

-- Observe TOPIC:
SELECT * FROM TOPIC;

-- Delete records from PERSON_INTEREST:
DELETE FROM PERSON_INTEREST
WHERE TOPIC_ID = 'T010';

-- Observe PERSON_INTEREST:
SELECT * FROM PERSON_INTEREST
WHERE TOPIC_ID = 'T010';

-- Commit changes:
COMMIT;

-- Error 7
-- Volunteer table

-- VOLUNTEER START DATE AND END DATE ARE INCORRECT
SELECT * FROM VOLUNTEER WHERE VOL_START_DATE > VOL_END_DATE ;

-- Update the volunteer table where person id = PE110.
UPDATE VOLUNTEER 
SET VOL_START_DATE = VOL_END_DATE, 
VOL_END_DATE = VOL_START_DATE
WHERE VOL_START_DATE > VOL_END_DATE ;

-- Checking the table after update.
SELECT * FROM VOLUNTEER WHERE VOL_START_DATE > VOL_END_DATE ;

-- Error 8 
-- Volunteer table

-- Volunteer whos details we dont have in Person table.
SELECT * FROM VOLUNTEER
WHERE PERSON_ID NOT IN 
(SELECT DISTINCT PERSON_ID FROM PERSON);

-- Delete the volunteer whose data we dont have in Person table
DELETE FROM VOLUNTEER
WHERE PERSON_ID NOT IN 
(SELECT DISTINCT PERSON_ID FROM PERSON);

-- Check table after delete
SELECT * FROM VOLUNTEER
WHERE PERSON_ID NOT IN 
(SELECT DISTINCT PERSON_ID FROM PERSON);

-- Error 9
-- Attendance table

-- Records where attendance is recorded after the event end date
SELECT * FROM ATTENDANCE AE
JOIN EVENT EV
ON EV.EVENT_ID = AE.EVENT_ID
WHERE EV.EVENT_END_DATE < AE.ATT_DATE;

-- We further check the Program table 
-- to see the number of sessions of Program PR011.
SELECT * FROM PROGRAM WHERE PROGRAM_ID = 'PR011';

-- Further investigate to see the attendance of person PE043 for event 71.
SELECT * FROM ATTENDANCE WHERE EVENT_ID = '71' AND PERSON_ID = 'PE043';

-- The Sessions dor program PR011 runs weekly.
-- Change the attendance date to 14/APR/19 for attendance record no 802
UPDATE ATTENDANCE
SET ATT_DATE = TO_DATE('14-APR-2019', 'DD-MON-YYYY')
WHERE ATT_ID = 802;

-- Checking the attendance table after the update.
SELECT * FROM ATTENDANCE AE
JOIN EVENT EV
ON EV.EVENT_ID = AE.EVENT_ID
WHERE EV.EVENT_END_DATE < AE.ATT_DATE;

-- Error 10
-- Registration table

-- There can be no registration for an event after it has commenced.
SELECT * FROM REGISTRATION RE
JOIN EVENT EV
ON RE.EVENT_ID = EV.EVENT_ID
WHERE RE.REG_DATE > EV.EVENT_START_DATE;

-- CORRESPONDING ATTENDANCE FOR THE EVENT REGISTRATION.
SELECT * FROM ATTENDANCE
WHERE (PERSON_ID, EVENT_ID) IN (
    SELECT RE.PERSON_ID, RE.EVENT_ID FROM REGISTRATION RE
    JOIN EVENT EV
    ON RE.EVENT_ID = EV.EVENT_ID
    WHERE RE.REG_DATE > EV.EVENT_START_DATE
);

-- DELETE ATTENDANCE AS THESE ARE INVALID
DELETE FROM ATTENDANCE ATT
WHERE (ATT.PERSON_ID, ATT.EVENT_ID) IN (
    SELECT RE.PERSON_ID, RE.EVENT_ID FROM REGISTRATION RE
    JOIN EVENT EV
    ON RE.EVENT_ID = EV.EVENT_ID
    WHERE RE.REG_DATE > EV.EVENT_START_DATE
);

-- DELETE THE REGISTRATIONS
DELETE FROM REGISTRATION WHERE REG_ID IN (
SELECT REG_ID FROM REGISTRATION RE
JOIN EVENT EV
ON RE.EVENT_ID = EV.EVENT_ID
WHERE RE.REG_DATE > EV.EVENT_START_DATE);

-- ERROR 11
-- TABLE ATTENDANCE

-- We check the donation amount where it is valid or not.
SELECT * FROM ATTENDANCE
WHERE ATT_DONATION_AMOUNT < 0;

-- MAKING THE AMOUNT AS POSITIVE
UPDATE ATTENDANCE ATT
SET ATT.ATT_DONATION_AMOUNT = ATT.ATT_DONATION_AMOUNT*(-1)
WHERE ATT_ID IN (SELECT ATT_ID FROM ATTENDANCE
WHERE ATT_DONATION_AMOUNT < 0);

-- Checking the donation amount after the update.
SELECT * FROM ATTENDANCE
WHERE ATT_DONATION_AMOUNT < 0;

-- ERROR 12
-- SUBSCRIPTION TABLE
-- DUPLICATE ROWS
SELECT SUBSCRIPTION_ID, COUNT(*) 
FROM SUBSCRIPTION 
GROUP BY SUBSCRIPTION_ID
HAVING COUNT(*) > 1;

-- Create a new Subscription table without the duplicated rows.
CREATE TABLE SUBSCRIPTION1  AS 
SELECT DISTINCT * FROM SUBSCRIPTION;

-- delete the old Subscription table
DROP TABLE SUBSCRIPTION;

-- Create new table that has the name Subscription.
CREATE TABLE SUBSCRIPTION AS 
SELECT DISTINCT * FROM SUBSCRIPTION1;

-- drop subscription1 table
DROP TABLE SUBSCRIPTION1;

-- CHECK THE NEW TABLE
SELECT SUBSCRIPTION_ID, COUNT(*) 
FROM SUBSCRIPTION 
GROUP BY SUBSCRIPTION_ID
HAVING COUNT(*) > 1;


















