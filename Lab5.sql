--1.	Write the code for the Function called Get_Descr that will for a provided Section ID return its Course DESCRIPTION… 
--Solution
CREATE OR REPLACE FUNCTION Get_Descr (
  v_section_id    IN section.section_id%TYPE)
RETURN VARCHAR2
AS
  v_desc          course.description%TYPE;
  v_course_no     course.course_no%TYPE;
  v_status        VARCHAR2(100);
  e_section_id    EXCEPTION;
BEGIN
  SELECT course_no INTO v_course_no
  FROM section
  WHERE section_id = v_section_id;
  
  SELECT description INTO v_desc
  FROM course
  WHERE course_no = v_course_no;
    IF v_section_id IS NULL THEN
      RAISE e_section_id;
    ELSE
      v_status := 'Course Description for Section Id ' || v_section_id || ' is ' || v_desc;
    END IF;
  RETURN v_status;
  EXCEPTION
    WHEN e_section_id THEN
      v_status := 'Course Description for Sectiond Id ' || v_section_id || ' is NULL';
      RETURN v_status;
    WHEN NO_DATA_FOUND THEN
      v_status := 'There is NO such Section id: ' || v_section_id;
      RETURN v_status;
END;
/
--Outputs
/*SELECT Get_Descr(150)
FROM DUAL;
Course Description for Section Id 150 is Intro to Java Programming

SELECT Get_Descr(999)
FROM DUAL;
There is NO such Section id: 999*/

--2.	Write the code for procedure called show_bizdays that will display what business days (NOT Saturday, Sunday) are ahead (present day will be included)… 
--Solution
CREATE OR REPLACE PROCEDURE show_bizdays (
  date_in   IN DATE     DEFAULT SYSDATE,
  day_in    IN NUMBER   DEFAULT 30)
AS
  v_day_type CHAR(1);
  v_start DATE := date_in;
  v_count NUMBER := 1;
BEGIN
  WHILE v_count < day_in + 1
  LOOP
    SELECT SUBSTR(TO_CHAR(v_start, 'DAY'), 0, 1)
    INTO v_day_type
    FROM dual;
    IF v_day_type = 'S' THEN
      v_start := v_start + 2;
    ELSE
      DBMS_OUTPUT.PUT_LINE ('The index is : ' || v_count || 
        ' and the table value is: ' || v_start);
      v_count := v_count + 1;
      v_start := v_start +1;
    END IF; 
  END LOOP;
END;
/
--Outputs
/*EXECUTE show_bizdays;
PL/SQL procedure successfully completed.
The index is : 1 and the table value is: 06-DEC-18
The index is : 2 and the table value is: 07-DEC-18
The index is : 3 and the table value is: 10-DEC-18
The index is : 4 and the table value is: 11-DEC-18
The index is : 5 and the table value is: 12-DEC-18
The index is : 6 and the table value is: 13-DEC-18
The index is : 7 and the table value is: 14-DEC-18
The index is : 8 and the table value is: 17-DEC-18
The index is : 9 and the table value is: 18-DEC-18
The index is : 10 and the table value is: 19-DEC-18
The index is : 11 and the table value is: 20-DEC-18
The index is : 12 and the table value is: 21-DEC-18
The index is : 13 and the table value is: 24-DEC-18
The index is : 14 and the table value is: 25-DEC-18
The index is : 15 and the table value is: 26-DEC-18
The index is : 16 and the table value is: 27-DEC-18
The index is : 17 and the table value is: 28-DEC-18
The index is : 18 and the table value is: 31-DEC-18
The index is : 19 and the table value is: 01-JAN-19
The index is : 20 and the table value is: 02-JAN-19
The index is : 21 and the table value is: 03-JAN-19
The index is : 22 and the table value is: 04-JAN-19
The index is : 23 and the table value is: 07-JAN-19
The index is : 24 and the table value is: 08-JAN-19
The index is : 25 and the table value is: 09-JAN-19
The index is : 26 and the table value is: 10-JAN-19
The index is : 27 and the table value is: 11-JAN-19
The index is : 28 and the table value is: 14-JAN-19
The index is : 29 and the table value is: 15-JAN-19
The index is : 30 and the table value is: 16-JAN-19

EXECUTE show_bizdays(SYSDATE+7, 10);
PL/SQL procedure successfully completed.
The index is : 1 and the table value is: 13-DEC-18
The index is : 2 and the table value is: 14-DEC-18
The index is : 3 and the table value is: 17-DEC-18
The index is : 4 and the table value is: 18-DEC-18
The index is : 5 and the table value is: 19-DEC-18
The index is : 6 and the table value is: 20-DEC-18
The index is : 7 and the table value is: 21-DEC-18
The index is : 8 and the table value is: 24-DEC-18
The index is : 9 and the table value is: 25-DEC-18
The index is : 10 and the table value is: 26-DEC-18*/

--3.	Write the Package specification called Lab5 for the Procedure and Function created for this Lab…
--Solution
CREATE OR REPLACE PACKAGE Lab5 IS 
  FUNCTION Get_Descr (
    v_section_id  IN section.section_id%TYPE)
  RETURN VARCHAR2;
  
  PROCECURE show_bizdays (
    date_in IN DATE,
    day_in  IN NUMBER);
END Lab5;

CREATE OR REPLACE PACKAGE BODY Lab5 AS
FUNCTION Get_Descr (
  v_section_id    IN section.section_id%TYPE)
RETURN VARCHAR2
AS
  v_desc          course.description%TYPE;
  v_course_no     course.course_no%TYPE;
  v_status        VARCHAR2(100);
  e_section_id    EXCEPTION;
BEGIN
  SELECT course_no INTO v_course_no
  FROM section
  WHERE section_id = v_section_id;
  
  SELECT description INTO v_desc
  FROM course
  WHERE course_no = v_course_no;
    IF v_section_id IS NULL THEN
      RAISE e_section_id;
    ELSE
      v_status := 'Course Description for Section Id ' || v_section_id || ' is ' || v_desc;
    END IF;
  RETURN v_status;
  EXCEPTION
    WHEN e_section_id THEN
      v_status := 'Course Description for Sectiond Id ' || v_section_id || ' is NULL';
      RETURN v_status;
    WHEN NO_DATA_FOUND THEN
      v_status := 'There is NO such Section id: ' || v_section_id;
      RETURN v_status;
END Get_Descr;

PROCEDURE show_bizdays (
  date_in   IN DATE     DEFAULT SYSDATE,
  day_in    IN NUMBER   DEFAULT 30)
AS
  v_day_type CHAR(1);
  v_start DATE := date_in;
  v_count NUMBER := 1;
BEGIN
  WHILE v_count < day_in + 1
  LOOP
    SELECT SUBSTR(TO_CHAR(v_start, 'DAY'), 0, 1)
    INTO v_day_type
    FROM dual;
    IF v_day_type = 'S' THEN
      v_start := v_start + 2;
    ELSE
      DBMS_OUTPUT.PUT_LINE ('The index is : ' || v_count || 
        ' and the table value is: ' || v_start);
      v_count := v_count + 1;
      v_start := v_start +1;
    END IF; 
  END LOOP;
END show_bizdays;
END Lab5;
/
--Outputs
--Same as Q2

--4.	Now OVERLOAD your Package with NEW variation of Procedure show_bizdays that will accept only ONE input parameter…. 

--Solution
CREATE OR REPLACE FUNCTION instruct_status
CREATE OR REPLACE PACKAGE Lab5 IS
  PROCEDURE show_bizdays(date_in, day_in);
  PROCEDURE show_bizdays(date_in);
END Lab5;
/

CREATE OR REPLACE PACKAGE BODY Lab5 IS
PROCEDURE show_bizdays (
  date_in   IN DATE     DEFAULT SYSDATE,
  day_in    IN NUMBER   DEFAULT 30)
AS
  v_day_type CHAR(1);
  v_start DATE := date_in;
  v_count NUMBER := 1;
BEGIN
  WHILE v_count < day_in + 1
  LOOP
    SELECT SUBSTR(TO_CHAR(v_start, 'DAY'), 0, 1)
    INTO v_day_type
    FROM dual;
    IF v_day_type = 'S' THEN
      v_start := v_start + 2;
    ELSE
      DBMS_OUTPUT.PUT_LINE ('The index is : ' || v_count || 
        ' and the table value is: ' || v_start);
      v_count := v_count + 1;
      v_start := v_start +1;
    END IF; 
  END LOOP;
END show_bizdays;

PROCEDURE show_bizdays (
  date_in   IN DATE     DEFAULT SYSDATE)
AS
  v_day_in    NUMBER;
  v_day_type CHAR(1);
  v_start DATE := date_in;
  v_count NUMBER := 1;
BEGIN
  v_day_in := &Enter_How_Many_Days;
  WHILE v_count < day_in + 1
  LOOP
    SELECT SUBSTR(TO_CHAR(v_start, 'DAY'), 0, 1)
    INTO v_day_type
    FROM dual;
    IF v_day_type = 'S' THEN
      v_start := v_start + 2;
    ELSE
      DBMS_OUTPUT.PUT_LINE ('The index is : ' || v_count || 
        ' and the table value is: ' || v_start);
      v_count := v_count + 1;
      v_start := v_start +1;
    END IF; 
  END LOOP;
END show_bizdays;
END Lab5;
/

--Outputs
--Same as Q2
