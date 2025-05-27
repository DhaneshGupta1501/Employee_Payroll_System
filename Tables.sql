CREATE TABLE employee (
    emp_id       NUMBER(10) PRIMARY KEY,
    emp_name     VARCHAR2(100),
    department   VARCHAR2(100),
    designation  VARCHAR2(100),
    join_date    DATE,
    basic_salary FLOAT
);

CREATE TABLE attendance (
    attendance_id NUMBER PRIMARY KEY,
    emp_id        NUMBER(10),
    attend_date   DATE,
    status        CHAR(1),
    CONSTRAINT fk_emp_att FOREIGN KEY ( emp_id )
        REFERENCES employee ( emp_id )
);

CREATE TABLE m_attendance_status (
    status_id NUMBER(5),
    status    VARCHAR2(50)
);

CREATE TABLE salary_component (
    comp_id      NUMBER(10) PRIMARY KEY,
    emp_id       NUMBER(10),
    month        DATE,
    year         DATE,
    basic        FLOAT,
    hra          FLOAT,
    da           FLOAT,
    tax          FLOAT,
    bonus        FLOAT,
    toatl_salary FLOAT,
    CONSTRAINT fk_emp_sal FOREIGN KEY ( emp_id )
        REFERENCES employee ( emp_id )
);

CREATE TABLE deductions (
    deduct_id        NUMBER(10) PRIMARY KEY,
    emp_id           NUMBER(10),
    month            DATE,
    year             DATE,
    deduction_reason VARCHAR2(100),
    amount           FLOAT,
    CONSTRAINT fk_emp_dedu FOREIGN KEY ( emp_id )
        REFERENCES employee ( emp_id )
);