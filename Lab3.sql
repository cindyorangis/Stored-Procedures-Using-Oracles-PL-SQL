--1.	Write the PL/SQL block that will use PL/SQL (INDEX BY) table to store Descriptions (Full Names) of all Courses that do NOT need a Prerequisite in alphabetical order.
--Solution
DECLARE
  CURSOR c_course IS
    SELECT description
    FROM course
    WHERE prerequisite IS NULL;
  TYPE course_table_type IS TABLE OF course.description%TYPE
    INDEX BY PLS_INTEGER;
  course_table    course_table_type;
  v_count       NUMBER(2) := 1;
  v_sum         NUMBER(2) := 0;
BEGIN
  OPEN c_course;
  LOOP
    FETCH c_course INTO course_table(v_count);
    EXIT WHEN c_course%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Course Description : ' || v_count || ': ' ||
      course_table(v_count));
    v_count := v_count + 1;
    v_sum := v_count - 1;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('************************************');
  DBMS_OUTPUT.PUT_LINE('Total # of Courses without the Prerequisite is: '
    || v_sum);
END;
/
--Outputs
/*PL/SQL procedure successfully completed.
Course Description : 1: DP Overview 
Course Description : 2: Intro to Computers 
Course Description : 3: Java for C/C++ Programmers 
Course Description : 4: Operating Systems 
************************************
Total # of Courses without the Prerequisite is: 4*/

--2.	Rewrite problem 1) by using an automated Cursor For Loop and NESTED Table instead of INDEX BY Table
--Solution
DECLARE
  CURSOR c_course IS
    SELECT description
    FROM course
    WHERE prerequisite IS NULL;
  TYPE course_table_type IS TABLE OF course.description%TYPE;
  course_table    course_table_type := course_table_type();
  v_count       NUMBER(2) := 0;
BEGIN
  FOR ind IN c_course LOOP
    v_count := v_count + 1;
    course_table.EXTEND;
    course_table(v_count) := ind.description;
    DBMS_OUTPUT.PUT_LINE('Course Description : ' || v_count || ': ' ||
      course_table(v_count));
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('************************************');
  DBMS_OUTPUT.PUT_LINE('Total # of Courses without the Prerequisite is: '
    || v_count);
END;
/
--Outputs
/*PL/SQL procedure successfully completed.
Course Description : 1: DP Overview 
Course Description : 2: Intro to Computers 
Course Description : 3: Java for C/C++ Programmers 
Course Description : 4: Operating Systems 
************************************
Total # of Courses without the Prerequisite is: 4*/

--3.	Write a PL/SQL block that will ask for an input of first 3 digits for a Zip Code and then will display number of students for each zip code.
--Solution
ACCEPT v_zip PROMPT 'Input first 3 digits of a Zip Code: ';
DECLARE
  v_count         NUMBER(2) := 0;
  v_total         NUMBER(2);
  
  TYPE t_rec IS RECORD
  (t_zip          student.zip%TYPE,
  t_enrollCount   NUMBER(2));
  zip_rec   t_rec;
  
  CURSOR c_student IS
    SELECT ZIP, COUNT(STUDENT_ID)
      FROM STUDENT
      WHERE ZIP LIKE '&v_zip' || '%'
      GROUP BY ZIP
      ORDER BY ZIP;
BEGIN
  SELECT COUNT(*) INTO v_total
    FROM student
    WHERE zip LIKE '&v_zip' || '%';
  IF v_total > 0 THEN
    OPEN c_student;
    LOOP
      FETCH c_student INTO zip_rec;
      EXIT WHEN c_student%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('Zip code : ' || zip_rec.t_zip || ' has exactly ' 
        || zip_rec.t_enrollCount || ' students enrolled');
      v_count := v_count + 1;
    END LOOP;
      DBMS_OUTPUT.PUT_LINE('************************************');
      DBMS_OUTPUT.PUT_LINE('Total # of zip codes under ' || '&v_zip' || 
        ' is ' || v_count);
      DBMS_OUTPUT.PUT_LINE('Total # of Students under zip code ' || 
        '&v_zip' || ' is ' || v_total);
    ELSE
      DBMS_OUTPUT.PUT_LINE('This zip area is student empty. Please, try again.');
    END IF;
END;
/

--Outputs
/*PL/SQL procedure successfully completed.
Zip code : 07302 has exactly 1 students enrolled
Zip code : 07304 has exactly 2 students enrolled
Zip code : 07306 has exactly 4 students enrolled
Zip code : 07307 has exactly 3 students enrolled
************************************
Total # of zip codes under 073 is 4
Total # of Students under zip code 073 is 10

PL/SQL procedure successfully completed.
This zip area is student empty. Please, try again.*/

--4.	Rewrite problem 3) by using an automated Cursor For Loop and INDEX BY Table instead of RECORD type.
--Solution
ACCEPT v_zip PROMPT 'Input first 3 digits of a Zip Code: ';
DECLARE
  v_count         NUMBER(2) := 0;
  v_total         NUMBER(2);
  
  TYPE student_table_type IS TABLE OF student.zip%TYPE
    INDEX BY PLS_INTEGER;
  student_table   student_table_type;
  
  CURSOR c_student IS
    SELECT ZIP, COUNT(STUDENT_ID) AS cnt
      FROM STUDENT
      WHERE ZIP LIKE '&v_zip' || '%'
      GROUP BY ZIP
      ORDER BY ZIP;
BEGIN
  SELECT COUNT(*) INTO v_total
    FROM student
    WHERE zip LIKE '&v_zip' || '%';
  IF v_total > 0 THEN
    FOR ind IN c_student
    LOOP
      student_table(v_count) := ind.zip;
      v_total := v_total + ind.cnt;
      DBMS_OUTPUT.PUT_LINE('Zip code : ' || student_table(v_count) || 
      ' has exactly ' || v_total || ' students enrolled');
      v_count := v_count + 1;
    END LOOP;
      DBMS_OUTPUT.PUT_LINE('************************************');
      DBMS_OUTPUT.PUT_LINE('Total # of zip codes under ' || '&v_zip' || 
        ' is ' || v_count);
      DBMS_OUTPUT.PUT_LINE('Total # of Students under zip code ' || 
        '&v_zip' || ' is ' || v_total);
    ELSE
      DBMS_OUTPUT.PUT_LINE('This zip area is student empty. Please, try again.');
    END IF;
END;
/

--Output
/*PL/SQL procedure successfully completed.
Zip code : 07302 has exactly 1 students enrolled
Zip code : 07304 has exactly 2 students enrolled
Zip code : 07306 has exactly 4 students enrolled
Zip code : 07307 has exactly 3 students enrolled
************************************
Total # of zip codes under 073 is 4
Total # of Students under zip code 073 is 10

PL/SQL procedure successfully completed.
This zip area is student empty. Please, try again.*/
