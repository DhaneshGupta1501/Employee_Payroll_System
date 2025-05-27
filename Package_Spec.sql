CREATE OR REPLACE PACKAGE pkg_emp_payroll_system AS
    PROCEDURE p_display_payslip (
        p_emp_id NUMBER,
        p_month  NUMBER,
        p_year   NUMBER
    );

    PROCEDURE p_generate_monthly_salary (
        p_month NUMBER,
        p_year  NUMBER
    );

    PROCEDURE p_insert_attendance (
        p_emp_id      NUMBER,
        p_attend_date DATE,
        p_status      CHAR
    );

    FUNCTION f_get_working_days (
        p_emp_id NUMBER,
        p_month  NUMBER,
        p_year   NUMBER
    ) RETURN NUMBER;

    FUNCTION fn_calculate_tax (
        p_total_salary NUMBER
    ) RETURN NUMBER;

END pkg_emp_payroll_system;