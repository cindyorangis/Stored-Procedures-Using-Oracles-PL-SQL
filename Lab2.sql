--1.	Write the PL/SQL code that may be used as a temperature system converter--
--Solution
DECLARE 
  v_scale     CHAR(1);
  v_temp_in   NUMBER(2);
  v_temp_out  NUMBER(3,1);
BEGIN
  v_scale := '&Enter_input_scale';
  DBMS_OUTPUT.PUT_LINE('Enter your input scale (C or F) for temperature: ' || v_scale );
  v_temp_in := &Enter_temperature_value;
  IF v_scale = 'C' THEN
    DBMS_OUTPUT.PUT_LINE('Enter your temperature value to be converted: ' || v_temp_in );
    v_temp_out := v_temp_in * (9/5) + 32;
    DBMS_OUTPUT.PUT_LINE('Your converted temperature in F is exactly ' || v_temp_out);
  ELSIF v_scale = 'F' THEN
    DBMS_OUTPUT.PUT_LINE('Enter your temperature value to be converted: ' || v_temp_in );
    v_temp_out := (v_temp_in - 32) * (5/9);
    DBMS_OUTPUT.PUT_LINE('Your converted temperature in C is exactly ' || v_temp_out);
  ELSE
    DBMS_OUTPUT.PUT_LINE('This is NOT a valid scale. Must be C or F.');
  END IF;
END;
/
--Outputs
/*PL/SQL procedure successfully completed.
Enter your input scale (C or F) for temperature: A
This is NOT a valid scale. Must be C or F.
PL/SQL procedure successfully completed.
Enter your input scale (C or F) for temperature: C
Enter your temperature value to be converted: 30
Your converted temperature in F is exactly 86
PL/SQL procedure successfully completed.
Enter your input scale (C or F) for temperature: F
Enter your temperature value to be converted: -25
Your converted temperature in C is exactly -31.7*/

--2.	Write a PL/SQL block that will ask for Instructor’s Id and then will figure out how many sections does that person teach.
--Solution

DECLARE 
  v_id      instructor.instructor_id%TYPE := &instructid;
  v_fname   instructor.first_name%TYPE;
  v_lname   instructor.last_name%TYPE;
  v_count   NUMBER(2);
BEGIN
  SELECT COUNT(*) INTO v_count
    FROM SECTION
    WHERE INSTRUCTOR_ID = v_id;
    
    BEGIN
      SELECT FIRST_NAME, LAST_NAME 
      INTO v_fname, v_lname
      FROM INSTRUCTOR
      WHERE INSTRUCTOR_ID = v_id;
      
      CASE
      WHEN v_id IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE('Instructor, ' || v_fname || ' ' || v_lname ||
        ', teaches ' || v_count || ' section(s)');
      ELSE
        DBMS_OUTPUT.PUT_LINE('This is not a valid instructor');
      END CASE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_id := NULL;
    END;
    
    CASE
      WHEN v_count > 9 THEN
        DBMS_OUTPUT.PUT_LINE('This instructor needs to rest in the next term.');
      WHEN v_count = 9 THEN
        DBMS_OUTPUT.PUT_LINE('This instructor teaches enough sections.');
      ELSE 
        DBMS_OUTPUT.PUT_LINE('This instructor may teach more sections.');
    END CASE;
END;
/
--Outputs
/*PL/SQL procedure successfully completed.
This instructor may teach more sections.

PL/SQL procedure successfully completed.
Instructor, Tom Wojick, teaches 10 section(s)
This instructor needs to rest in the next term.

PL/SQL procedure successfully completed.
Instructor, Fernand Hanks, teaches 9 section(s)
This instructor teaches enough sections.

PL/SQL procedure successfully completed.
Instructor, Rick Chow, teaches 0 section(s)
This instructor may teach more sections.*/

--3.	Write a PL/SQL block that will ask for a Positive Integer input and then will calculate the sum of all Even (or Odd) integers between 1 and that value, depending whether the input value is Even or Odd. Use WHILE LOOP control logic.
--Solution
DECLARE
  v_start     NUMBER := 0;
  v_end       NUMBER := &Enter_Positive_Integer;
  v_sum       NUMBER := 0;
  v_evenodd   VARCHAR2(4);
BEGIN
  IF (MOD(v_end, 2) = 0) THEN
    v_evenodd := 'Even';
    WHILE v_start < v_end LOOP
      v_start := v_start + 2;
      v_sum := v_sum + v_start;
    END LOOP;
  ELSIF (MOD(v_end, 2) = 1) THEN
    v_start := -1;
    v_evenodd := 'Odd';
      WHILE v_start < v_end LOOP
        v_start := v_start + 2;
        v_sum := v_sum + v_start;
      END LOOP;
  END IF;
  DBMS_OUTPUT.PUT_LINE('The sum of ' || v_evenodd || ' integers between 1 and ' 
    || v_start || ' is ' || v_sum);
END;
/



--Output
/*PL/SQL procedure successfully completed.
The sum of Even integers between 1 and 12 is 42

PL/SQL procedure successfully completed.
The sum of Odd integers between 1 and 901 is 203401*/

--4.	Write a PL/SQL block that will ask for department’s Location ID and then will figure out how many departments exist there and how many employees work on that location.
--Solution
DECLARE
  loc_count       NUMBER(2) := 0;
  dep_count       NUMBER(2) := 0;
  emp_count       NUMBER(2) := 0;
  v_locid         NUMBER(4) := 1400;
BEGIN
  SELECT COUNT(*) INTO loc_count
  FROM DEPARTMENTS
  WHERE LOCATION_ID = v_locid
  GROUP BY LOCATION_ID;
  
  <<Outer_Loop>>
  FOR i IN 1..loc_count LOOP
    dep_count := dep_count + 1;
    DBMS_OUTPUT.PUT_LINE('Outer Loop: Department #' 
    || dep_count);
    
    SELECT COUNT(EMPLOYEE_ID) INTO dep_count
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID = (SELECT DEPARTMENT_ID
                            FROM DEPARTMENTS
                            WHERE LOCATION_ID = v_locid)
    GROUP BY DEPARTMENT_ID;
    
    <<Inner_Loop>>
    FOR j IN 1..dep_count LOOP
      emp_count := emp_count + 1;
      DBMS_OUTPUT.PUT_LINE('* Inner Loop: Employee #'
        || emp_count);
    END LOOP;
  END LOOP;
END;
/
--Output
/*PL/SQL procedure successfully completed.
Outer Loop: Department #1
* Inner Loop: Employee #1
* Inner Loop: Employee #2
* Inner Loop: Employee #3
* Inner Loop: Employee #4
* Inner Loop: Employee #5*/
