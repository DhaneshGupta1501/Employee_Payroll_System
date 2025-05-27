CREATE OR REPLACE PACKAGE BODY pkg_emp_payroll_system AS

    PROCEDURE p_display_payslip (
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

    PROCEDURE p_generate_monthly_salary (
        p_month NUMBER,
        p_year  NUMBER
    ) AS

        CURSOR c_emps IS
        SELECT
            emp_id,
            basic_salary
        FROM
            employee;

        v_basic_salary employee.basic_salary%TYPE;
        v_emp_id       employee.emp_id%TYPE;
        v_month_date   DATE;
        v_present_day  NUMBER;
        v_hra          FLOAT;
        v_da           FLOAT;
        v_bonus        FLOAT;
        v_tax          FLOAT;
        v_total_sal    FLOAT;
    BEGIN
        v_month_date := to_date(
                               '01-'
                               || p_month
                               || '-'
                               || p_year,
                               'DD-MM-YYYY'
                        );

        FOR i IN c_emps LOOP
            v_emp_id := i.emp_id;
            v_basic_salary := i.basic_salary;
            SELECT
                COUNT(1)
            INTO v_present_day
            FROM
                attendance
            WHERE
                emp_id = v_emp_id
                AND status = 'P'
                AND EXTRACT(MONTH FROM attend_date) = p_month
                AND EXTRACT(YEAR FROM attend_date) = p_year;

            v_hra := v_basic_salary * 0.2;
            v_da := v_basic_salary * 0.1;
            IF v_present_day > 25 THEN
                v_bonus := v_basic_salary * 0.5;
            ELSE
                v_bonus := 0;
            END IF;

            v_tax := ( v_basic_salary + v_hra + v_da + v_bonus ) * 0.10;
            v_total_sal := ( v_basic_salary + v_hra + v_da + v_bonus ) - ( v_tax );
            INSERT INTO salary_component VALUES (
                sal_comp_id_seq.NEXTVAL,
                v_emp_id,
                v_month_date,
                v_month_date,
                v_basic_salary,
                v_hra,
                v_da,
                v_tax,
                v_bonus,
                v_total_sal
            );

        END LOOP;

        COMMIT;
        dbms_output.put_line('Data Inserted Successfully !!');
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line(sqlcode
                                 || ' '
                                 || sqlerrm);
    END p_generate_monthly_salary;

    PROCEDURE p_insert_attendance (
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

    FUNCTION f_get_working_days (
        p_emp_id NUMBER,
        p_month  NUMBER,
        p_year   NUMBER
    ) RETURN NUMBER AS
        v_count NUMBER;
    BEGIN
        SELECT
            COUNT(1)
        INTO v_count
        FROM
            attendance
        WHERE
            status = 'P'
            AND emp_id = p_emp_id
            AND EXTRACT(MONTH FROM attend_date) = p_month
            AND EXTRACT(YEAR FROM attend_date) = p_year;

        RETURN v_count;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line(sqlcode
                                 || ' '
                                 || sqlerrm);
            RETURN -1;
    END f_get_working_days;

    FUNCTION fn_calculate_tax (
        p_total_salary NUMBER
    ) RETURN NUMBER AS
        v_tax_rate NUMBER;
    BEGIN
        SELECT
            CASE
            WHEN p_total_salary BETWEEN 0 AND 10000     THEN
            0.10
            WHEN p_total_salary BETWEEN 10001 AND 20000 THEN
            0.20
            WHEN p_total_salary BETWEEN 20001 AND 30000 THEN
            0.30
            ELSE
            0.50
            END AS tax_rate
        INTO v_tax_rate
        FROM
            dual;

        RETURN p_total_salary * v_tax_rate;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line(sqlcode
                                 || ' '
                                 || sqlerrm);
            RETURN -1;
    END fn_calculate_tax;

END pkg_emp_payroll_system;