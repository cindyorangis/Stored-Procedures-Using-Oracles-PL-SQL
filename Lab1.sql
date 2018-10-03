/* 1.	Walkthrough the following PL/SQL code and try to guess what the 3 values will be printed during its execution
PL/SQL procedure successfully completed.*/
-- Local V_MINE is here: 700
-- Outer V_MINE is here: 500
-- Outer V_MINE is here: 1400

-- 2.	Write a PL/SQL block
-- Solution
DECLARE
  v_course  VARCHAR2(40);
  v_number  NUMBER(8,2);
  v_room    CONSTANT VARCHAR2(4) := '704B';
  v_boolean BOOLEAN;
  v_date    DATE := SYSDATE + 7;
BEGIN
  v_course := 'Introduction to Oracle Database';
  v_course := 'C++ advanced';
      IF v_course = 'SQL' THEN
        DBMS_OUTPUT.PUT_LINE('Name of the course is: ' || v_course);
      ELSIF v_room = '704B' THEN
        IF v_course IS NOT NULL THEN
          DBMS_OUTPUT.PUT_LINE('Name of the course is: ' || v_course || 
            ' and Room is: ' || v_room);
        ELSE
          DBMS_OUTPUT.PUT_LINE('Course is unknown' || v_room);
        END IF;
      ELSE
        DBMS_OUTPUT.PUT_LINE('Course and location could not be determined');
      END IF;
END;
/
-- Outputs
/* PL/SQL procedure successfully completed.
Course: Introduction to Oracle Database
Room: 704B
Date: 27-SEP-18
Name of the course is: Introduction to Oracle Database and Room is: 704B
PL/SQL procedure successfully completed.
Course: Introduction to Oracle Database
Room: 704B
Date: 27-SEP-18
Name of the course is: C++ advanced and Room is: 704B */

-- 3.	Perform the following tasks:
-- A.	Create a table called Lab1_tab
CREATE TABLE Lab1_tab (
  Id  NUMBER,
  LName VARCHAR2(20));
-- B.	Create a sequence called Lab1_seq
CREATE SEQUENCE Lab1_seq
  START WITH 1
  INCREMENT BY 5;
-- C.	Write a PL/SQL block that performs the following in this order:
-- a.	 Declare two variables to hold the values for columns of the table Lab1_tab
-- Solution
DECLARE 
  v_Id    Student.STUDENT_ID%TYPE;
  v_LName Student.LAST_NAME%TYPE;
BEGIN
  BEGIN
    SELECT LAST_NAME
    INTO v_LName
    FROM STUDENT
    WHERE STUDENT_ID IN (SELECT STUDENT_ID
                              FROM ENROLLMENT
                              GROUP BY STUDENT_ID
                              HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                                                    FROM ENROLLMENT
                                                    GROUP BY STUDENT_ID))
    AND LENGTH(LAST_NAME) < 9;
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      v_LName := 'Multiple Names';
  END;

  INSERT INTO Lab1_tab (Id, LName)
    VALUES(Lab1_seq.NEXTVAL, v_LName);
-- c.	 Then the student with the least enrollments is inserted in the table, use sequence as well
  BEGIN
    SELECT LAST_NAME
    INTO v_LName
    FROM STUDENT
    WHERE STUDENT_ID IN (SELECT STUDENT_ID
                              FROM ENROLLMENT
                              GROUP BY STUDENT_ID
                              HAVING COUNT(*) = (SELECT MIN(COUNT(*))
                                                    FROM ENROLLMENT
                                                    GROUP BY STUDENT_ID))
    AND LENGTH(LAST_NAME) < 9;
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      v_LName := 'Multiple Names';
  END;
  
  INSERT INTO Lab1_tab (Id, LName)
    VALUES(Lab1_seq.NEXTVAL, v_LName);
-- d.	 Insert the instructor’s last name teaching the least amount of courses if his/her last name does NOT end on “s”. Here do not use the sequence to generate the ID; instead use your first variable
  BEGIN
    SELECT LAST_NAME
    INTO v_LName
    FROM INSTRUCTOR
    WHERE INSTRUCTOR_ID IN (SELECT INSTRUCTOR_ID
                            FROM SECTION
                            GROUP BY INSTRUCTOR_ID
                            HAVING COUNT(*) = (SELECT MIN(COUNT(*))
                                              FROM SECTION
                                              GROUP BY INSTRUCTOR_ID))
    AND LAST_NAME NOT LIKE '%s';
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      v_LName := 'Multiple Names';
  END;
  
  INSERT INTO Lab1_tab(Id, LName)
    VALUES(1, v_LName);
-- e.	 Insert the instructor teaching the most number of courses and use the sequence to populate his/her Id
  BEGIN
    SELECT LAST_NAME
    INTO v_LName
    FROM INSTRUCTOR
    WHERE INSTRUCTOR_ID IN (SELECT INSTRUCTOR_ID
                              FROM SECTION
                              GROUP BY INSTRUCTOR_ID
                              HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                                                    FROM SECTION
                                                    GROUP BY INSTRUCTOR_ID))
    AND LAST_NAME NOT LIKE '%s';
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      v_LName := 'Multiple Names';
  END;
  
  INSERT INTO Lab1_tab(Id, LName)
    VALUES(Lab1_seq.NEXTVAL, v_LName);
END;
/
-- f.	Save your changes and display the content of your table Lab1_tab
-- Output
/* SELECT * FROM LAB1_TAB;
        ID LNAME              
---------- --------------------
         1 Williams            
         6 Multiple Names      
         1 Lowry               
        11 Multiple Names  */
