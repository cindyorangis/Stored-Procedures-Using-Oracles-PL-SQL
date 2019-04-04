--1.	Write a stored Procedure called mine that will accept as Input TWO character parameters… 
--Solution
CREATE OR REPLACE PROCEDURE mine 
  (i_date   IN  VARCHAR2,
  i_letter  IN  VARCHAR2)
AS
  v_date      VARCHAR(5);
  v_letter    VARCHAR2(1);
  v_day       VARCHAR(10);
  v_stored    NUMBER;
BEGIN
  v_date := i_date;
  v_letter := UPPER(i_letter);
  
  SELECT TO_CHAR(LAST_DAY(TO_DATE(v_date, 'MM/YY')), 'Day')
  INTO v_day
  FROM DUAL;
  DBMS_OUTPUT.PUT_LINE('Last day of the month ' || v_date || ' is ' || v_day);
  
  IF v_letter = 'P' THEN
    SELECT COUNT(*)
    INTO v_stored
    FROM user_objects
    WHERE UPPER(object_type) = 'PROCEDURE';
    DBMS_OUTPUT.PUT_LINE('Number of stored objects of type ' || v_letter ||
      ' is ' || v_stored);
  ELSIF v_letter = 'F' THEN
    SELECT COUNT(*)
    INTO v_stored
    FROM user_objects
    WHERE UPPER(object_type) = 'FUNCTION';
    DBMS_OUTPUT.PUT_LINE('Number of stored objects of type ' || v_letter ||
      ' is ' || v_stored);
  ELSE 
    DBMS_OUTPUT.PUT_LINE('You have entered an Invalid letter for the stored object. Try P, F, B.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('You have entered an Invalid FORMAT for the MONTH and YEAR. Try MM/YY.');
END;
/
--Outputs
/*EXECUTE  mine ('11/09','P');
PL/SQL procedure successfully completed.
Last day of the month 11/09 is Monday   
Number of stored objects of type P is 3

EXECUTE  mine ('12/09','f');
PL/SQL procedure successfully completed.
Last day of the month 12/09 is Thursday 
Number of stored objects of type F is 0

EXECUTE  mine ('01/10','T');
PL/SQL procedure successfully completed.
Last day of the month 01/10 is Sunday   
You have entered an Invalid letter for the stored object. Try P, F, B.

EXECUTE  mine ('13/09','P');
PL/SQL procedure successfully completed.
You have entered an Invalid FORMAT for the MONTH and YEAR. Try MM/YY.*/

--2.	Write a stored Procedure called add_zip that will accept as Input THREE parameters for three columns in the table ZIPCODE(ZIP, CITY and STATE)… 
--Solution
CREATE OR REPLACE PROCEDURE add_zip
  (i_zip    IN zipcode.zip%TYPE,
  i_city    IN zipcode.city%TYPE,
  i_state   IN zipcode.state%TYPE)
AS
  v_zip     zipcode.zip%TYPE;
  v_city    zipcode.city%TYPE;
  v_state   zipcode.state%TYPE;
  v_temp    zipcode.zip%TYPE;
  v_flag    VARCHAR(10);
  v_zipnum  NUMBER;
BEGIN
  v_zip   := i_zip;
  v_city  := i_city;
  v_state := i_state;
  
  SELECT zip
  INTO v_temp
  FROM zipcode
  WHERE zip = v_zip;
  
  v_flag := 'FAILURE';
  
  SELECT COUNT(*)
  INTO v_zipnum
  FROM zipcode
  WHERE zip = v_zip;
  
  IF v_zipnum >= 1 THEN
  DBMS_OUTPUT.PUT_LINE('This ZIPCODE ' || v_zip || ' is already in the Database. Try again.');
  END IF;
  
EXCEPTION
  WHEN NO_DATA_FOUND THEN 
    v_flag := 'SUCCESS';
    INSERT INTO zipcode
    VALUES (v_zip, v_city, v_state, user, sysdate, user, sysdate);
    
    SELECT COUNT(*)
    INTO v_zipnum
    FROM zipcode
    WHERE zip = v_zip;
END;
/
--Outputs
/*EXECUTE add_zip(‘18104’, ‘Chicago’, ‘MI’);
SELECT * FROM zipcode
WHERE state = 'MI';
ZIP   CITY                      ST CREATED_BY                     CREATED_DATE MODIFIED_BY               MODIFIED_DATE
----- ------------------------- -- ------------------------------ ------------ ------------------------------ -------------
48104 Ann Arbor                 MI AMORRISO                       03-AUG-99    ARISCHER                       24-NOV-99    
18104 Chicago                   MI DBS501_183A18                  08-NOV-18    DBS501_183A18               08-NOV-18    

EXECUTE add_zip('48104','Chicago','MI');
PL/SQL procedure successfully completed.
This ZIPCODE 48104 is already in the Database. Try again.*/

--3.	Re-write the previous question so that you can use a stored BOOLEAN FUNCTION called exist_zip that will check if the provided zip code already exists in the database or not…
--Solution

CREATE OR REPLACE FUNCTION exist_zip
  (p_zip  IN   zipcode.zip%TYPE)
  RETURN VARCHAR2
AS
  v_zip         zipcode.zip%TYPE;
  v_zip_count   NUMBER;
  v_exist       VARCHAR2(5);
BEGIN  
  SELECT COUNT(*)
  INTO v_zip_count
  FROM zipcode
  WHERE zip = p_zip;
  
  IF v_zip_count = 1 THEN
    v_exist := 'TRUE';
  ELSE
    v_exist := 'FALSE';
  END IF;
  RETURN v_exist;
END;
/

CREATE OR REPLACE PROCEDURE add_zip2
  (i_zip    IN  zipcode.zip%TYPE,
  i_city    IN  zipcode.city%TYPE,
  i_state   IN  zipcode.state%TYPE)
AS
  v_zip     zipcode.city%TYPE;
  v_city    zipcode.city%TYPE;
  v_state   zipcode.state%TYPE;
  v_temp    zipcode.zip%TYPE;
  v_flag    VARCHAR2(10);
  v_zipnum  NUMBER;
  
  FUNCTION exist_zip(v_zip   zipcode.zip%TYPE) RETURN VARCHAR2 IS
  p_zip     zipcode.zip%TYPE;
  BEGIN
    SELECT zip
    INTO v_temp
    FROM zipcode
    WHERE zip = v_zip;
    RETURN v_temp;
  END;
BEGIN
  v_zip   := i_zip;
  v_city  := i_city;
  v_state := i_state;

  v_flag := 'FAILURE';
  
  SELECT COUNT(*)
  INTO v_zipnum
  FROM zipcode
  WHERE zip = v_zip;
  
  IF v_zipnum >= 1 THEN
  DBMS_OUTPUT.PUT_LINE('This ZIPCODE ' || v_zip || ' is already in the Database. Try again.');
  END IF;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_flag := 'SUCCESS';
      INSERT INTO zipcode
      VALUES(v_zip, v_city, v_state, user, sysdate, user, sysdate);
      
      SELECT COUNT(*)
      INTO v_zipnum
      FROM zipcode
      WHERE zip = v_zip;
END;
/
--Outputs
/*EXECUTE add_zip2(‘18104’, ‘Chicago’, ‘MI’);
SELECT * FROM zipcode
WHERE state = 'MI';
ZIP   CITY                      ST CREATED_BY                     CREATED_DATE MODIFIED_BY               MODIFIED_DATE
----- ------------------------- -- ------------------------------ ------------ ------------------------------ -------------
48104 Ann Arbor                 MI AMORRISO                       03-AUG-99    ARISCHER                       24-NOV-99    
18104 Chicago                   MI DBS501_183A18                  08-NOV-18    DBS501_183A18               08-NOV-18    

EXECUTE add_zip2('48104','Chicago','MI');
PL/SQL procedure successfully completed.
This ZIPCODE 48104 is already in the Database. Try again.*/

--4.	Write a stored CHARACTER FUNCTION called instruct_status that will accept as Input TWO parameters – instructor’s First and Last name entered in the Upper case… 
--Solution
CREATE OR REPLACE FUNCTION instruct_status
  (i_first_name   IN instructor.first_name%TYPE,
  i_last_name     IN instructor.last_name%TYPE)
  RETURN VARCHAR2
AS
  v_instructor_id instructor.instructor_id%TYPE;
  v_section_count NUMBER;
  v_status        VARCHAR2(60);
BEGIN
  SELECT instructor_id
  INTO v_instructor_id
  FROM instructor
  WHERE UPPER(first_name) = i_first_name
  AND UPPER(last_name) = i_last_name;
  
  SELECT COUNT(*)
  INTO v_section_count
  FROM section
  WHERE instructor_id = v_instructor_id;
  
  IF v_section_count > 9 THEN
    v_status := 'This Instructor will teach ' || v_section_count || 
      ' courses and needs a vacation';
  ELSIF v_section_count BETWEEN 1 AND 9 THEN
    v_status := 'This Instructor will teach ' || v_section_count || ' courses';
  ELSIF v_section_count = 0 THEN
    v_status := 'This instructor is NOT scheduled to teach';
  ELSE
    RAISE NO_DATA_FOUND;
  END IF;
  RETURN v_status;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_status := 'There is NO such instructor.';
    RETURN v_status;
END;
/

--Outputs
/*Function INSTRUCT_STATUS compiled
SELECT last_name, instruct_status(first_name, last_name) AS "Instructor Status"
FROM instructor
ORDER BY last_name;
LAST_NAME		Instructor Status
-----------------------	-----------------------------
Chow                      	This Instructor is NOT scheduled to teach                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
Frantzen                  	This Instructor will teach 10 courses and needs a vacation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
Hanks                     	This Instructor will teach 9 courses                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
Lowry                     	This Instructor will teach 9 courses                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
Morris                    	This Instructor will teach 10 courses and needs a vacation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
Pertez                    	This Instructor will teach 10 courses and needs a vacation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
Schorin                   	This Instructor will teach 10 courses and needs a vacation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
Smythe                    	This Instructor will teach 10 courses and needs a vacation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
Willig                    	This Instructor is NOT scheduled to teach                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
Wojick                    	This Instructor will teach 10 courses and needs a vacation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
 10 rows selected

SELECT instruct_status('PETER', 'PAN')
FROM DUAL;
INSTRUCT_STATUS('PETER','PAN')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
------------------------------------------------------------------------------------------------------------------------------------------
There is NO such instructor.  

SELECT instruct_status('IRENE', 'WILLIG')
FROM DUAL;
INSTRUCT_STATUS('IRENE','WILLIG')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
------------------------------------------------------------------------------------------------------------------------------------------
This instructor is NOT scheduled to teach*/
