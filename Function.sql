create or replace FUNCTION f_get_working_days (
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

create or replace FUNCTION fn_calculate_tax (
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
