--Assignment 1, DBS501
--Muchtar Salimov, Cindy Le, Derrick Leung, Kevin Nguyen
--1.
--INPUT:
SET SERVEROUTPUT ON

ACCEPT city_input PROMPT 'Please provide the valid city without department: '

DECLARE
	v_city_name Locations.city%TYPE :='&city_input';
	v_location_id Locations.location_id%TYPE;

	v_highest_dept_id Departments.department_id%TYPE;
	v_new_dept_id Departments.department_id%TYPE;
	v_irrelevant_dept Departments.department_id%TYPE;

	v_manager_id Departments.manager_id%TYPE;
	v_new_dept_name Departments.department_name%TYPE := TO_CHAR('Testing');
BEGIN
	SELECT MAX(department_id)
	INTO v_highest_dept_id
	FROM Departments;

	v_new_dept_id := v_highest_dept_id + 50;

	DECLARE

	BEGIN
		SELECT location_id
		INTO v_location_id
		FROM Locations
		WHERE Locations.city = v_city_name;

		SELECT m.employee_id
		INTO v_manager_id
		FROM Employees e, Employees m
		WHERE e.manager_id = m.employee_id
		GROUP BY e.manager_id
		HAVING COUNT(e.manager_id) = ( SELECT MAX(COUNT(manager_id))
					       FROM Employees
					       GROUP by manager_id);
		DECLARE
		BEGIN
			SELECT department_id
			INTO v_irrelevant_dept
			FROM Departments
			WHERE Departments.location_id = v_location_id;

			DBMS_OUTPUT.PUT_LINE('This city already contains department: ' || v_city_name);
		
		EXCEPTION
			WHEN TOO_MANY_ROWS THEN
				DBMS_OUTPUT.PUT_LINE('This city has MORE THAN ONE Department: ' || v_city_name);
			WHEN NO_DATA_FOUND THEN
				INSERT INTO Departments(department_id, department_name, manager_id, location_id)
				VALUES(v_new_dept_id, 'Testing', 100, v_location_id);


				DBMS_OUTPUT.PUT_LINE(LPAD('DEPARTMENT_ID',20) || LPAD('DEPARTMENT_NAME',20) || LPAD('MANAGER_ID',20) || LPAD('LOCATION_ID',20));
				DBMS_OUTPUT.PUT_LINE(LPAD(v_new_dept_id,20) || LPAD(v_new_dept_name,20) || LPAD(v_manager_id,20) || LPAD(v_location_id,20));
		END;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('This city is NOT listed: ' || v_city_name);
	END;
	ROLLBACK;
END;
/
--OUTPUT:
/*SQL> @Q1
Please provide the valid city without department: Venice
DEPARTMENT_ID     DEPARTMENT_NAME          MANAGER_ID         LOCATION_ID                                               
320             Testing                 100                1100                                                         

PL/SQL procedure successfully completed.

SQL> @Q1
Please provide the valid city without department: Toronto
This city already contains department: Toronto                                                                          

PL/SQL procedure successfully completed.

SQL> @Q1
Please provide the valid city without department: Seattle
This city has MORE THAN ONE Department: Seattle                                                                         

PL/SQL procedure successfully completed.

SQL> @Q1
Please provide the valid city without department: Belgrade
This city is NOT listed: Belgrade                                                                                       

PL/SQL procedure successfully completed.*/

--2.
--INPUT:
SET SERVEROUTPUT ON
SET VERIFY OFF

ACCEPT course_desc_input PROMPT 'Enter the beginning of the Course Description in UPPER case: '

DECLARE
	CURSOR c_course IS
	SELECT c.course_no
	FROM Course c, Course p
	WHERE p.course_no = c.prerequisite 
	AND LOWER(p.description) LIKE LOWER('&&course_desc_input') || '%'
	ORDER BY 1;



	CURSOR c_section(co_num NUMBER) IS
	SELECT COUNT(Enrollment.student_id) as cnt, Section.section_id
	FROM Section
	LEFT OUTER JOIN Enrollment ON Section.section_id = Enrollment.section_id
	WHERE Section.course_no = co_num
	GROUP BY Section.section_id
	ORDER by 2;

	v_course_id Course.course_no%TYPE;
	v_section_id Section.section_id%TYPE;
	v_num_students NUMBER;

	v_course_count NUMBER := 0;
	v_flag NUMBER;

	e_many_students EXCEPTION;

BEGIN
	DECLARE
	BEGIN
		SELECT 1 INTO v_flag
		FROM COURSE
		WHERE LOWER(description) LIKE LOWER('&&course_desc_input') || '%';
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('There is NO VALID course that starts on: ' || '&course_desc_input');
			v_course_count := -1;
		WHEN TOO_MANY_ROWS THEN
			NULL;
	END;


	FOR course_row in c_course LOOP
		v_course_id := course_row.course_no;

		FOR section_row in c_section(v_course_id) LOOP
			DECLARE
			BEGIN
				v_section_id := section_row.section_id;
				v_num_students := section_row.cnt;
				IF v_num_students >= 7
					THEN RAISE e_many_students;
				ELSE
					DBMS_OUTPUT.PUT_LINE('There are ' || v_num_students || ' students for section ID ' || v_section_id);
				END IF;

			EXCEPTION
				WHEN E_MANY_STUDENTS THEN
				DBMS_OUTPUT.PUT_LINE('There are too many students for section ID ' || v_section_id);
				DBMS_OUTPUT.PUT_LINE('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
			END;
		END LOOP;
		
		v_course_count := c_course%ROWCOUNT;
	END LOOP;

	IF v_course_count = 0 THEN
		DBMS_OUTPUT.PUT_LINE('There is NO PREREQUISITE course that starts on: ' || '&course_desc_input');
	END IF;
END;
/

--OUTPUT:
/*SQL> @Q2
Enter the beginning of the Course Description in UPPER case: STRUCTURED
There are 5 students for section ID 85                                                                                  
There are 6 students for section ID 86                                                                                  
There are too many students for section ID 87                                                                           
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                                                                      
There are 5 students for section ID 88                                                                                  
There are too many students for section ID 89                                                                           
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                                                                      
There are 4 students for section ID 90                                                                                  
There are 2 students for section ID 91                                                                                  
There are 4 students for section ID 92                                                                                  
There are 0 students for section ID 93                                                                                  
There are 4 students for section ID 146                                                                                 
There are too many students for section ID 147                                                                          
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                                                                      
There are 5 students for section ID 148                                                                                 
There are 1 students for section ID 149                                                                                 
There are 3 students for section ID 150                                                                                 
There are 2 students for section ID 151                                                                                 
There are 0 students for section ID 98                                                                                  

PL/SQL procedure successfully completed.

SQL> @Q2
Enter the beginning of the Course Description in UPPER case: UNIX
There is NO PREREQUISITE course that starts on: UNIX                                                                    

PL/SQL procedure successfully completed.

SQL> @Q2
Enter the beginning of the Course Description in UPPER case: SPORT
There is NO VALID course that starts on: SPORT                                                                          

PL/SQL procedure successfully completed.*/


--3.
--INPUT:
	SET SERVEROUTPUT ON
	SET VERIFY OFF

	ACCEPT course_desc_input PROMPT 'Enter the beginning of the Course Description in UPPER case: '

	DECLARE
	
		CURSOR c_course IS
		SELECT c.course_no, c.prerequisite
		FROM Course c
		WHERE LOWER(c.description) LIKE LOWER('&&course_desc_input') || '%'
		ORDER BY 1;

		TYPE p_course_rec IS RECORD
		  (p_course_no   Course.course_no%TYPE, 
		   p_course_desc    Course.description%TYPE, 
		   p_course_cost    Course.cost%TYPE
		);

		TYPE c_course_rec IS RECORD
		  (c_course_no   Course.course_no%TYPE, 
		   c_course_desc    Course.description%TYPE, 
		   c_course_cost    Course.cost%TYPE, 
		   c_course_prereq  p_course_rec
		  );

		v_c_course_rec c_course_rec;
		v_course_count NUMBER := 0;
		v_flag NUMBER;


	BEGIN
		DECLARE
		BEGIN
			SELECT 1 INTO v_flag
			FROM COURSE
			WHERE LOWER(description) LIKE LOWER('&&course_desc_input') || '%';

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				DBMS_OUTPUT.PUT_LINE('There is NO VALID course that starts on: ' || '&course_desc_input' || '. Try Again.');
				v_course_count := -1;
			WHEN TOO_MANY_ROWS THEN
				NULL;
		END;

		FOR course_row in c_course LOOP
			IF course_row.prerequisite IS NOT NULL then	

				SELECT c.course_no, c.description, c.cost, p.course_no, p.description, p.cost
				INTO v_c_course_rec.c_course_no, v_c_course_rec.c_course_desc, v_c_course_rec.c_course_cost,
				     v_c_course_rec.c_course_prereq.p_course_no, v_c_course_rec.c_course_prereq.p_course_desc,
			             v_c_course_rec.c_course_prereq.p_course_cost
				FROM Course c
				JOIN Course p
				ON c.prerequisite = p.course_no
				WHERE c.course_no = course_row.course_no;
	
				DBMS_OUTPUT.PUT_LINE('Course: ' || v_c_course_rec.c_course_no || ' - ' || v_c_course_rec.c_course_desc);
				DBMS_OUTPUT.PUT_LINE('Cost: ' || v_c_course_rec.c_course_cost);
				DBMS_OUTPUT.PUT_LINE('Prerequisite: ' || v_c_course_rec.c_course_prereq.p_course_no || ' - ' || v_c_course_rec.c_course_prereq.p_course_desc); 
				DBMS_OUTPUT.PUT_LINE('Cost: ' || v_c_course_rec.c_course_prereq.p_course_cost);
				DBMS_OUTPUT.PUT_LINE('==========================================');
				v_course_count := v_course_count+1;
			END IF;
		END LOOP;
		IF v_course_count = 0 THEN
			DBMS_OUTPUT.PUT_LINE('There is NO prerequisite course for any course that starts on  ' || '&course_desc_input' || '. Try Again.');
			
		END IF;
	END;
	/

--OUTPUT:
/*SQL> @Q3
Enter the beginning of the Course Description in UPPER case: DATABASE
Course: 144 - Database Design                                                                                           
Cost: 1195                                                                                                              
Prerequisite: 420 - Database System Principles                                                                          
Cost: 1195                                                                                                              
==========================================                                                                              
Course: 420 - Database System Principles                                                                                
Cost: 1195                                                                                                              
Prerequisite: 25 - Intro to Programming                                                                                 
Cost: 1195                                                                                                              
==========================================                                                                              

PL/SQL procedure successfully completed.

SQL> @Q3
Enter the beginning of the Course Description in UPPER case: OPERATING
There is NO prerequisite course for any course that starts on  OPERATING. Try Again.                                    

PL/SQL procedure successfully completed.

SQL> @Q3
Enter the beginning of the Course Description in UPPER case: SPORT
There is NO VALID course that starts on: SPORT. Try Again.                                                              

PL/SQL procedure successfully completed.*/

--4.
--INPUT:
ACCEPT v_name_one CHAR PROMPT 'Enter first word in upper case'
ACCEPT v_name_two CHAR PROMPT 'Enter second word in upper case'
DECLARE
  CURSOR c_course IS
    SELECT c.course_no, c.description
    FROM course c
    WHERE UPPER(c.description) LIKE '%' || '&v_name_one' || '%' 
      AND UPPER(c.description) LIKE '%' || '&v_name_two' || '%';

  CURSOR c_enrollment (cn NUMBER) IS
    SELECT COUNT(e.student_id), s.section_id, s.section_no
    FROM section s
    JOIN enrollment e
      ON e.section_id = s.section_id
    WHERE s.course_no = cn
    GROUP BY s.section_id, section_no
    ORDER by 2;
  v_secCount      NUMBER(3) := 0;
  v_course_no     course.course_no%TYPE;
  v_desc          course.description%TYPE;
  v_secid         section.section_id%TYPE;
  v_secno         section.section_no%TYPE;
  v_stuCount      NUMBER(3);
BEGIN
  OPEN c_course;
  LOOP
    FETCH c_course INTO v_course_no, v_desc;
    EXIT WHEN c_course%NOTFOUND;
     v_secCount := 1;
     DBMS_OUTPUT.PUT_LINE(v_course_no || ' ' || v_desc);
     DBMS_OUTPUT.PUT_LINE('*********************************************************************');
     
    IF c_enrollment%ISOPEN THEN
      CLOSE c_enrollment;
    END IF;
    OPEN c_enrollment(v_course_no);
    LOOP
      FETCH c_enrollment INTO v_stuCount, v_secid, v_secno;
      EXIT WHEN c_enrollment%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('Section: ' || v_secno || ' has enrollment of: ' || v_stuCount);
    END LOOP;
  END LOOP;
  CLOSE c_course;
  IF v_secCount = 0 THEN
    DBMS_OUTPUT.PUT_LINE('There is NO course containing these 2 words. Try again.');
  END IF;
END;
/
--OUTPUT:
/*SQL> @Q4
Enter first word in upper caseJAVA
Enter second word in upper casePROGRAM
120 Intro to Java Programming                                                                                           
*********************************************************************                                                   
Section: 1 has enrollment of: 4                                                                                         
Section: 2 has enrollment of: 8                                                                                         
Section: 3 has enrollment of: 5                                                                                         
Section: 4 has enrollment of: 1                                                                                         
Section: 5 has enrollment of: 3                                                                                         
Section: 7 has enrollment of: 2                                                                                         
122 Intermediate Java Programming                                                                                       
*********************************************************************                                                   
Section: 1 has enrollment of: 4                                                                                         
Section: 2 has enrollment of: 3                                                                                         
Section: 3 has enrollment of: 4                                                                                         
Section: 4 has enrollment of: 5                                                                                         
Section: 5 has enrollment of: 8                                                                                         
124 Advanced Java Programming                                                                                           
*********************************************************************                                                   
Section: 1 has enrollment of: 5                                                                                         
Section: 2 has enrollment of: 1                                                                                         
Section: 3 has enrollment of: 2                                                                                         
146 Java for C/C++ Programmers                                                                                          
*********************************************************************                                                   
Section: 2 has enrollment of: 2                                                                                         
Section: 1 has enrollment of: 1                                                                                         
450 DB Programming in Java                                                                                              
*********************************************************************                                                   
Section: 1 has enrollment of: 1                                                                                         

PL/SQL procedure successfully completed.

SQL> @Q4
Enter first word in upper caseINTRO
Enter second word in upper caseC
20 Intro to Computers                                                                                                   
*********************************************************************                                                   
Section: 2 has enrollment of: 3                                                                                         
Section: 4 has enrollment of: 2                                                                                         
Section: 7 has enrollment of: 2                                                                                         
Section: 8 has enrollment of: 2                                                                                         
240 Intro to the Basic Language                                                                                         
*********************************************************************                                                   
Section: 1 has enrollment of: 12                                                                                        
Section: 2 has enrollment of: 1                                                                                         

PL/SQL procedure successfully completed.

SQL> @Q4
Enter first word in upper caseINTRO
Enter second word in upper caseSOCCER
There is NO course containing these 2 words. Try again.*/
