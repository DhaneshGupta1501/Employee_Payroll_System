create or replace PROCEDURE p_display_payslip (
    p_emp_id NUMBER,
    p_month  NUMBER,
    p_year   NUMBER
) AS

    CURSOR c_emps IS
    SELECT
        emp.emp_id,
        emp.emp_name,
        emp.department,
        emp.designation,
        emp.basic_salary,
        sc.hra,
        sc.da,
        sc.bonus,
        sc.tax,
        sc.total_salary
    FROM
        salary_component sc
        INNER JOIN employee emp ON emp.emp_id = sc.emp_id
    WHERE
        emp.emp_id = p_emp_id;

    v_month_date DATE;
    v_count      NUMBER;
    v_emps       c_emps%rowtype;
BEGIN
    v_month_date := to_date(
                           '01-'
                           || p_month
                           || '-'
                           || p_year,
                           'DD-MM-YYYY'
                    );
-- checking whether employee present or not --
    SELECT
        COUNT(1)
    INTO v_count
    FROM
        employee
    WHERE
        emp_id = p_emp_id;

    IF v_count = 0 THEN
        raise_application_error(
                               20001,
                               p_emp_id || ' is not present in the system !!'
        );
    END IF;
-- checking whether salary for that employee/month/year exists or not --
    SELECT
        COUNT(*)
    INTO v_count
    FROM
        salary_component
    WHERE
        emp_id = p_emp_id
        AND EXTRACT(MONTH FROM month) = p_month
        AND EXTRACT(YEAR FROM year) = p_year;

    IF v_count = 0 THEN
        raise_application_error(
                               20002,
                               'Data is not present in Salary Component !!'
        );
    END IF;
    -- fetching employee present day --

    SELECT
        COUNT(1)
    INTO v_count
    FROM
        attendance
    WHERE
        emp_id = p_emp_id
        AND EXTRACT(MONTH FROM attend_date) = p_month
        AND EXTRACT(YEAR FROM attend_date) = p_year;

    OPEN c_emps;
    FETCH c_emps INTO v_emps;
    dbms_output.put_line('---------- EMPLOYEE PAYSLIP ----------');
    dbms_output.put_line('EMPLOYEE ID :- ' || v_emps.emp_id);
    dbms_output.put_line('EMPLOYEE NAME :- ' || v_emps.emp_name);
    dbms_output.put_line('EMPLOYEE DEPARTMENT :- ' || v_emps.department);
    dbms_output.put_line('EMPLOYEE DESIGNATION :- ' || v_emps.designation);
    dbms_output.put_line('EMPLOYEE BASIC SALARY :- ' || v_emps.basic_salary);
    dbms_output.put_line('HRA :- ' || v_emps.hra);
    dbms_output.put_line('DA :- ' || v_emps.da);
    dbms_output.put_line('BONUS :- ' || v_emps.bonus);
    dbms_output.put_line('TAX :- ' || v_emps.tax);
    dbms_output.put_line('EMPLOYEE TOTAL SALARY :- ' || v_emps.total_salary);
    CLOSE c_emps;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(sqlcode
                             || ' '
                             || sqlerrm);
END p_display_payslip;

create or replace PROCEDURE p_insert_attendance (
    p_emp_id      NUMBER,
    p_attend_date DATE,
    p_status      CHAR
) AS
    v_count NUMBER;
BEGIN
-- checking whether employee is existing or not --
    SELECT
        COUNT(1)
    INTO v_count
    FROM
        employee
    WHERE
        emp_id = p_emp_id;

    IF v_count = 0 THEN
        raise_application_error(
                               -20001,
                               'Employee Does not Exist !!'
        );
    ELSE
        dbms_output.put_line('Employee Exist !!');
    END IF;
-- checking whether status is existing or not --
    SELECT
        COUNT(1)
    INTO v_count
    FROM
        m_attendance_status
    WHERE
        status = p_status;

    IF v_count = 0 THEN
        raise_application_error(
                               -20002,
                               'Status does not exist !!'
        );
    ELSE
        dbms_output.put_line('Status Exist !!');
    END IF;
-- checking if that employee already has attendance for that date --
    SELECT
        COUNT(1)
    INTO v_count
    FROM
        attendance
    WHERE
        attend_date = p_attend_date
        AND emp_id = p_emp_id;

    IF v_count > 0 THEN
        raise_application_error(
                               -20003,
                               'This employee is already present for this date '
        );
    END IF;
-- inserting data in the attendance table --
    INSERT INTO attendance VALUES (
        attendance_id_seq.NEXTVAL,
        p_emp_id,
        p_attend_date,
        p_status
    );

    COMMIT;
    dbms_output.put_line('Data Successfully Inserted !!');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(sqlcode
                             || ' '
                             || sqlerrm);
END p_insert_attendance;