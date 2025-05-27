CREATE OR REPLACE TRIGGER tgr_recal_sal_aft_inst_deduction AFTER
    INSERT ON deductions
    FOR EACH ROW
BEGIN
    UPDATE salary_component
    SET
        total_salary = total_salary - :new.amount
    WHERE
        emp_id = :new.emp_id
        AND EXTRACT(MONTH FROM month) = EXTRACT(MONTH FROM :new.month)
        AND EXTRACT(YEAR FROM year) = EXTRACT(YEAR FROM :new.year);

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(sqlcode
                             || ' '
                             || sqlerrm);
END tgr_recal_sal_aft_inst_deduction;