--Assignment 2 DBS501
--Muchtar Salimov, Cindy Le, Derrick Leung, Kevin Nguyen

--1.
CREATE OR REPLACE PROCEDURE find_stud (
  stud_num      IN    NUMBER,
  stud_lname    OUT   VARCHAR2,
  stud_phone    OUT   VARCHAR2,
  stud_zip      OUT   VARCHAR2) IS
BEGIN
  SELECT last_name, phone, zip
  INTO stud_lname, stud_phone, stud_zip
  FROM student
  WHERE student_id = stud_num;
  DBMS_OUTPUT.PUT_LINE('Student with the Id of : ' || stud_num || ' is ' || stud_lname || ' with the phone# ' || stud_phone || ' and who belongs to zip code ' || stud_zip);
  EXCEPTION
  	WHEN NO_DATA_FOUND THEN
    		DBMS_OUTPUT.PUT_LINE('There is NO Student with the Id of : ' || stud_num);
END;
/
VAR lname VARCHAR2(25);
VAR phone VARCHAR2(15);
VAR zip VARCHAR2(5);
EXECUTE find_stud(110, :lname, :phone, :zip);
PRINT lname;
PRINT phone;
PRINT zip;
EXECUTE find_stud(99, :lname, :phone, :zip);
PRINT lname;
PRINT phone;
PRINT zip;

/*SQL> @a2q1
Procedure created.
Student with the Id of : 110 is Martin with the phone# 718-555-5555 and who belongs to zip code 11385                   
PL/SQL procedure successfully completed.

LNAME                                                                                                                   
--------------------------------                                                                                        
Martin                                                                                                                  

PHONE                                                                                                                   
--------------------------------                                                                                        
718-555-5555                                                                                                            

ZIP                                                                                                                     
--------------------------------                                                                                        
11385                                                                                                                   

There is NO Student with the Id of : 99                                                                                 

PL/SQL procedure successfully completed.

LNAME                                                                                                                   
--------------------------------                                                                                                                                                                                                               

PHONE                                                                                                                   
--------------------------------                                                                                        
                                                                                                                        
ZIP                                                                                                                     
--------------------------------*/
                                                                                       
--2.
create or replace
procedure  drop_stud (sid number, flag varchar2 default 'R') is 
rows1 number;
rows2 number := 1;
begin
select student_id into rows1 from student where student_id = sid;
select count(student_id) into rows1 from enrollment where student_id = sid; 
rows2 := rows2 + rows1;
if upper(flag) = 'R' then
  if rows1 > 0 then 
    dbms_output.put_line('Student with the Id of : ' || sid || ' is enrolled in or more courses and his/her removal is denied.');
  else 
    delete from student where student_id = sid;
    rollback;
    dbms_output.put_line('Student with the Id of : ' || sid || ' is removed. He/she was NOT enrolled in any courses.');
  end if;
elsif upper(flag) = 'C' then
  select count(student_id) into rows1 from grade where student_id = sid;
  rows2 :=  rows2 + rows1;
  savepoint safe;
  delete from grade where student_id = sid;
  delete from enrollment where student_id = sid;
  delete from student where student_id = sid;
  rollback to safe;
  dbms_output.put_line('Student with the Id of : ' || sid || ' is removed. Total # of rows deleted is: ' || rows2);
end if;
exception
when no_data_found then
dbms_output.put_line('Student with the Id of : ' || sid || ' does NOT exist. Try again.');
end drop_stud;
/
set serveroutput on;
set verify off;
accept sid prompt 'enter student id';
accept flag prompt 'enter flag';
begin
 drop_stud(&sid, '&flag');
end;
/
select section_id,final_grade from enrollment  where student_id = &sid;
select first_name,last_name from student where student_id = &sid;

/*SQL> @a2_q2

Procedure created.

enter student id210
enter flagR
Student with the Id of : 210 is enrolled in or more courses and his/her removal is denied.                              

PL/SQL procedure successfully completed.


SECTION_ID FINAL_GRADE                                                                                                  
---------- -----------                                                                                                  
       147                                                                                                              


FIRST_NAME                LAST_NAME                                                                                     
------------------------- -------------------------                                                                     
David                     Thares                                                                                        

SQL> @a2_q2

Procedure created.

enter student id410
enter flagR
Student with the Id of : 410 does NOT exist. Try again.                                                                 

PL/SQL procedure successfully completed.
no rows selected
no rows selected

SQL> @a2_q2

Procedure created.

enter student id310
enter flagR
Student with the Id of : 310 is removed. He/she was NOT enrolled in any courses.                                        

PL/SQL procedure successfully completed.
no rows selected

FIRST_NAME                LAST_NAME                                                                                     
------------------------- -------------------------                                                                     
Joseph                    Jimenes                                                                                       

SQL> @a2_q2

Procedure created.

enter student id110
enter flagC
Student with the Id of : 110 is removed. Total # of rows deleted is: 24                                                 

PL/SQL procedure successfully completed.

SECTION_ID FINAL_GRADE                                                                                                  
---------- -----------                                                                                                  
        95                                                                                                              
       154                                                                                                              

FIRST_NAME                LAST_NAME                                                                                     
------------------------- -------------------------                                                                     
Maria                     Martin*/


--3.
/* Package spec */
CREATE OR REPLACE PACKAGE  manage_stud IS
    PROCEDURE  find_stud(
	stud_num      IN    NUMBER,
	stud_lname    OUT   VARCHAR2,
	stud_phone    OUT   VARCHAR2,
	stud_zip      OUT   VARCHAR2);
	procedure  drop_stud (
	sid number, 
	flag varchar2 default 'R');
END manage_stud;
/
/* Package body */
CREATE OR REPLACE PACKAGE BODY manage_stud IS
    PROCEDURE find_stud ( 
    stud_num      IN    NUMBER,
	stud_lname    OUT   VARCHAR2,
	stud_phone    OUT   VARCHAR2,
	stud_zip      OUT   VARCHAR2) IS
	BEGIN
	  SELECT last_name, phone, zip
	  INTO stud_lname, stud_phone, stud_zip
	  FROM student
	  WHERE student_id = stud_num;
	END find_stud;

	PROCEDURE  drop_stud (
	sid number, 
	flag varchar2 default 'R') is 
		rows1 number;
		rows2 number := 1;
		begin
		select student_id into rows1 from student where student_id = sid;
		select count(student_id) into rows1 from enrollment where student_id = sid; 
		rows2 := rows2 + rows1;
		if upper(flag) = 'R' then
		  if rows1 > 0 then 
			dbms_output.put_line('Student with the Id of : ' || sid || ' is enrolled in or more courses and his/her removal is denied.');
		  else 
			delete from student where student_id = sid;
			rollback;
			dbms_output.put_line('Student with the Id of : ' || sid || ' is removed. He/she was NOT enrolled in any courses.');
		  end if;
		elsif upper(flag) = 'C' then
		  select count(student_id) into rows1 from grade where student_id = sid;
		  rows2 :=  rows2 + rows1;
		  savepoint safe;
		  delete from grade where student_id = sid;
		  delete from enrollment where student_id = sid;
		  delete from student where student_id = sid;
		  rollback to safe;
		  dbms_output.put_line('Student with the Id of : ' || sid || ' is removed. Total # of rows deleted is: ' || rows2);
		end if;
		exception
		when no_data_found then
		dbms_output.put_line('Student with the Id of : ' || sid || ' does NOT exist. Try again.');
	end drop_stud;
END manage_stud;
/
/* testing find_stud using Case 1 */
ACCEPT stud_id PROMPT 'Enter a valid Student ID: '
/* 110 */
DECLARE
  v_lname   student.last_name%TYPE;
  v_phone   student.phone%TYPE;
  v_zip     student.zip%TYPE;
BEGIN
  manage_stud.find_stud(&&stud_id, v_lname, v_phone, v_zip);
  DBMS_OUTPUT.PUT_LINE('Student with the Id of : ' || &stud_id || ' is ' ||
    v_lname || ' with the phone# ' || v_phone || ' and who belongs to zip code '
    || v_zip);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('There is NO Student with the Id of : ' || &stud_id);
END;
/

/* testing drop_stud using Case 3 */
accept sid prompt 'enter student id'
/* 310 */
accept flag prompt 'enter flag';
begin
 manage_stud.drop_stud(&sid, '&flag');
end;
/
select section_id,final_grade from enrollment  where student_id = &sid;
select first_name,last_name from student where student_id = &sid;

/* testing drop_stud using Case 4 */
accept sid prompt 'enter student id'
/* 110 */
accept flag prompt 'enter flag'
/* C */
begin
 manage_stud.drop_stud(&sid, '&flag');
end;
/
select section_id,final_grade from enrollment  where student_id = &sid;
select first_name,last_name from student where student_id = &sid;

/*SQL> @a2q3

Package created.


Package body created.

Enter a valid Student ID: 110
Student with the Id of : 110 is Martin with the phone# 718-555-5555 and who belongs to zip code 11385                   

PL/SQL procedure successfully completed.

enter student id310
enter flagR
Student with the Id of : 310 is removed. He/she was NOT enrolled in any courses.                                        

PL/SQL procedure successfully completed.


no rows selected
FIRST_NAME                LAST_NAME                                                                                     
------------------------- -------------------------                                                                     
Joseph                    Jimenes                                                                                       

enter student id110
enter flagC
Student with the Id of : 110 is removed. Total # of rows deleted is: 24                                                 

PL/SQL procedure successfully completed.

SECTION_ID FINAL_GRADE                                                                                                  
---------- -----------                                                                                                  
        95                                                                                                              
       154                                                                                                              

FIRST_NAME                LAST_NAME                                                                                     
------------------------- -------------------------                                                                     
Maria                     Martin*/

--4.

CREATE OR REPLACE FUNCTION valid_stud(
	p_stud_id NUMBER)
RETURN BOOLEAN IS
	v_flag CHAR(1) := 'n';
BEGIN
	SELECT 'Y'
	INTO v_flag
	FROM Student
	WHERE student_id = p_stud_id;

	RETURN v_flag = 'Y';
END;
/	
/* Package spec */
CREATE OR REPLACE PACKAGE  manage_stud IS

    PROCEDURE  find_stud(
	stud_num      IN    NUMBER,
	stud_lname    OUT   VARCHAR2,
	stud_phone    OUT   VARCHAR2,
	stud_zip      OUT   VARCHAR2);

	procedure  drop_stud (
	sid number, 
	flag varchar2 default 'R');

	procedure find_stud(
		p_stud_num IN NUMBER,
		p_first_name OUT VARCHAR2,
		p_last_name OUT VARCHAR2);

END manage_stud;
/
/* Package body */
CREATE OR REPLACE PACKAGE BODY manage_stud IS

    PROCEDURE find_stud ( 
    stud_num      IN    NUMBER,
	stud_lname    OUT   VARCHAR2,
	stud_phone    OUT   VARCHAR2,
	stud_zip      OUT   VARCHAR2) IS
	BEGIN
	  SELECT last_name, phone, zip
	  INTO stud_lname, stud_phone, stud_zip
	  FROM student
	  WHERE student_id = stud_num;
	END find_stud;

	procedure find_stud(
		p_stud_num IN NUMBER,
		p_first_name OUT VARCHAR2,
		p_last_name OUT VARCHAR2) IS
		BEGIN	
		IF valid_stud(p_stud_num) THEN
			SELECT first_name, last_name
			INTO p_first_name, p_last_name
			FROM Student
			WHERE student_id = p_stud_num;
		END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN 
				NULL;
		END find_stud;
	PROCEDURE  drop_stud (
	sid number, 
	flag varchar2 default 'R') is 
		rows1 number;
		rows2 number := 1;
		begin
		select student_id into rows1 from student where student_id = sid;
		select count(student_id) into rows1 from enrollment where student_id = sid; 
		rows2 := rows2 + rows1;
		if upper(flag) = 'R' then
		  if rows1 > 0 then 
			dbms_output.put_line('Student with the Id of : ' || sid || ' is enrolled in or more courses and his/her removal is denied.');
		  else 
			delete from student where student_id = sid;
			rollback;
			dbms_output.put_line('Student with the Id of : ' || sid || ' is removed. He/she was NOT enrolled in any courses.');
		  end if;
		elsif upper(flag) = 'C' then
		  select count(student_id) into rows1 from grade where student_id = sid;
		  rows2 :=  rows2 + rows1;
		  savepoint safe;
		  delete from grade where student_id = sid;
		  delete from enrollment where student_id = sid;
		  delete from student where student_id = sid;
		  rollback to safe;
		  dbms_output.put_line('Student with the Id of : ' || sid || ' is removed. Total # of rows deleted is: ' || rows2);
		end if;
		exception
		when no_data_found then
		dbms_output.put_line('Student with the Id of : ' || sid || ' does NOT exist. Try again.');
	end drop_stud;
END manage_stud;
/
VAR fname VARCHAR2(25);
VAR lname VARCHAR2(25);
EXECUTE manage_stud.find_stud(399, :fname, :lname);
PRINT fname;
PRINT lname;
EXECUTE manage_stud.find_stud(566, :fname, :lname);
PRINT fname;
PRINT lname;

/*SQL> @a2q4

Function created.

Package created.

Package body created.

PL/SQL procedure successfully completed.

FNAME                                                                                                                   
--------------------------------                                                                                        
Jerry                                                                                                                   

LNAME                                                                                                                   
--------------------------------                                                                                        
Abdou                                                                                                                   

PL/SQL procedure successfully completed.

FNAME                                                                                                                   
--------------------------------                                                                                        
                                                                                                                        

LNAME                                                                                                                   
--------------------------------*/

--5.
ACCEPT inp_region_id PROMPT 'Enter value for region: '
DECLARE 
    v_country Countries.country_name%TYPE;
    v_region_id NUMBER := '&inp_region_id';
	v_counter INTEGER;
    v_num_regions INTEGER := 0;
    v_tot_in_all_regions INTEGER := 0;
    v_tot_in_this_region INTEGER := 0;
    v_key INTEGER := 1;
    v_second_c Countries.country_name%TYPE;
    v_second_last_c Countries.country_name%TYPE;
    
	CURSOR cur_emptyLoc IS
    SELECT c.country_id, c. country_name
    FROM Countries c
    WHERE c.region_id = v_region_id
    AND c.country_id NOT IN (SELECT country_id
							 FROM LOCATIONS)
    ORDER BY 2 ASC;
	CURSOR cur_emptyLoc2 IS
    SELECT c.country_name, c.country_id, c.region_id, c.flag
    FROM Countries c
    WHERE c.country_id NOT IN (SELECT country_id
							 FROM LOCATIONS)
    ORDER BY 1 ASC;
BEGIN
	SELECT MAX(Regions.region_id)
    INTO v_num_regions
    FROM Regions;
	IF (v_region_id > 0 AND v_region_id <= v_num_regions) THEN
		v_counter := 0;
		SELECT r.region_id
		INTO v_region_id
		FROM Regions r
		WHERE r.region_id = v_region_id;	
        
		FOR rec IN cur_emptyLoc2 LOOP
			UPDATE Countries c
			SET c.flag = 'EMPTY_' || TO_CHAR(rec.region_id)
			WHERE c.country_id = rec.country_id;
			v_tot_in_all_regions := v_tot_in_all_regions + 1;
		END LOOP;
        
		FOR rec IN cur_emptyLoc2 LOOP
			v_counter := v_counter + 1;
			DBMS_OUTPUT.PUT_LINE('Index Table Key: ' || v_key || ' has a value of ' || rec.country_name);
			IF v_counter = 2 THEN
				v_second_c := rec.country_name;
            ELSIF (v_counter = (v_tot_in_all_regions - 1)) THEN
				v_second_last_c := rec.country_name;
            END IF;
			v_key := v_key + 5;
		END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('======================================================================');
		DBMS_OUTPUT.PUT_LINE('Total number of elements in the Index able or Number of countries with No cities is: ' || v_tot_in_all_regions);
		DBMS_OUTPUT.PUT_LINE('Second element (Country) in the Index Table is: ' || v_second_c);
		DBMS_OUTPUT.PUT_LINE('Before the last element (Country) in the Index Table is: ' || v_second_last_c);
		DBMS_OUTPUT.PUT_LINE('======================================================================');
		FOR rec IN cur_emptyLoc LOOP
			DBMS_OUTPUT.PUT_LINE('In the region ' || v_region_id || ' there is country ' || rec.country_name || ' with NO city.'); 
			v_tot_in_this_region := v_tot_in_this_region + 1;
		END LOOP;
		DBMS_OUTPUT.PUT_LINE('======================================================================');
		DBMS_OUTPUT.PUT_LINE('Total number of countries with NO cities listed in the Region ' || v_region_id || ' is: ' || v_tot_in_this_region);
	ELSE
		DBMS_OUTPUT.PUT_LINE('This region ID does NOT exist: ' || v_region_id);
    END IF;
END;
/
SELECT * FROM COUNTRIES WHERE COUNTRIES.country_id NOT IN (SELECT country_id FROM LOCATIONS) ORDER BY 3, 2;
ROLLBACK;

/*SQL> @a2q5
Enter value for region: 5
This region ID does NOT exist: 5                                                                                        

PL/SQL procedure successfully completed.


CO COUNTRY_NAME                              REGION_ID FLAG                                                             
-- ---------------------------------------- ---------- -------                                                          
BE Belgium                                           1                                                                  
DK Denmark                                           1                                                                  
FR France                                            1                                                                  
AR Argentina                                         2                                                                  
HK HongKong                                          3                                                                  
EG Egypt                                             4                                                                  
IL Israel                                            4                                                                  
KW Kuwait                                            4                                                                  
NG Nigeria                                           4                                                                  
ZM Zambia                                            4                                                                  
ZW Zimbabwe                                          4                                                                  

11 rows selected.


Rollback complete.

SQL> @a2q5
Enter value for region: 1
Index Table Key: 1 has a value of Argentina                                                                             
Index Table Key: 6 has a value of Belgium                                                                               
Index Table Key: 11 has a value of Denmark                                                                              
Index Table Key: 16 has a value of Egypt                                                                                
Index Table Key: 21 has a value of France                                                                               
Index Table Key: 26 has a value of HongKong                                                                             
Index Table Key: 31 has a value of Israel                                                                               
Index Table Key: 36 has a value of Kuwait                                                                               
Index Table Key: 41 has a value of Nigeria                                                                              
Index Table Key: 46 has a value of Zambia                                                                               
Index Table Key: 51 has a value of Zimbabwe                                                                             
======================================================================                                                  
Total number of elements in the Index able or Number of countries with No cities is: 11                                 
Second element (Country) in the Index Table is: Belgium                                                                 
Before the last element (Country) in the Index Table is: Zambia                                                         
======================================================================                                                  
In the region 1 there is country Belgium with NO city.                                                                  
In the region 1 there is country Denmark with NO city.                                                                  
In the region 1 there is country France with NO city.                                                                   
======================================================================                                                  
Total number of countries with NO cities listed in the Region 1 is: 3                                                   

PL/SQL procedure successfully completed.


CO COUNTRY_NAME                              REGION_ID FLAG                                                             
-- ---------------------------------------- ---------- -------                                                          
BE Belgium                                           1 EMPTY_1                                                          
DK Denmark                                           1 EMPTY_1                                                          
FR France                                            1 EMPTY_1                                                          
AR Argentina                                         2 EMPTY_2                                                          
HK HongKong                                          3 EMPTY_3                                                          
EG Egypt                                             4 EMPTY_4                                                          
IL Israel                                            4 EMPTY_4                                                          
KW Kuwait                                            4 EMPTY_4                                                          
NG Nigeria                                           4 EMPTY_4                                                          
ZM Zambia                                            4 EMPTY_4                                                          
ZW Zimbabwe                                          4 EMPTY_4                                                          

11 rows selected.


Rollback complete.

SQL> @a2q5
Enter value for region: 2
Index Table Key: 1 has a value of Argentina                                                                             
Index Table Key: 6 has a value of Belgium                                                                               
Index Table Key: 11 has a value of Denmark                                                                              
Index Table Key: 16 has a value of Egypt                                                                                
Index Table Key: 21 has a value of France                                                                               
Index Table Key: 26 has a value of HongKong                                                                             
Index Table Key: 31 has a value of Israel                                                                               
Index Table Key: 36 has a value of Kuwait                                                                               
Index Table Key: 41 has a value of Nigeria                                                                              
Index Table Key: 46 has a value of Zambia                                                                               
Index Table Key: 51 has a value of Zimbabwe                                                                             
======================================================================                                                  
Total number of elements in the Index able or Number of countries with No cities is: 11                                 
Second element (Country) in the Index Table is: Belgium                                                                 
Before the last element (Country) in the Index Table is: Zambia                                                         
======================================================================                                                  
In the region 2 there is country Argentina with NO city.                                                                
======================================================================                                                  
Total number of countries with NO cities listed in the Region 2 is: 1                                                   

PL/SQL procedure successfully completed.


CO COUNTRY_NAME                              REGION_ID FLAG                                                             
-- ---------------------------------------- ---------- -------                                                          
BE Belgium                                           1 EMPTY_1                                                          
DK Denmark                                           1 EMPTY_1                                                          
FR France                                            1 EMPTY_1                                                          
AR Argentina                                         2 EMPTY_2                                                          
HK HongKong                                          3 EMPTY_3                                                          
EG Egypt                                             4 EMPTY_4                                                          
IL Israel                                            4 EMPTY_4                                                          
KW Kuwait                                            4 EMPTY_4                                                          
NG Nigeria                                           4 EMPTY_4                                                          
ZM Zambia                                            4 EMPTY_4                                                          
ZW Zimbabwe                                          4 EMPTY_4                                                          

11 rows selected.

Rollback complete.*/
