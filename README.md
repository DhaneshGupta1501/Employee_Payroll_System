# 💼 Employee Payroll System (Oracle SQL & PL/SQL)

This project is a comprehensive **Employee Payroll System** built using **Oracle SQL** and **PL/SQL**. It simulates a basic HRMS system that handles employee data, attendance, salary computation, taxation, and payslip generation.

---

## 📌 Features

- Employee and Department Management  
- Attendance Tracking  
- Automatic Salary Component Generation (HRA, DA, Bonus, Tax)  
- Monthly Salary Processing  
- Payslip Display for Any Month/Year  
- Tax Calculation Logic  
- View for Final Salary (Before and After Deductions)  
- Encapsulated in a Clean PL/SQL Package

---

## 🧱 Technologies Used

| Component          | Technology       |
|-------------------|------------------|
| Database           | Oracle 19c (or compatible) |
| Programming        | SQL & PL/SQL     |
| IDE/Tool           | Oracle SQL Developer |
| Architecture       | Monolithic, Package-based Design |

---

## 🗂️ Project Structure

```bash
employee-payroll-system/
│
├── tables.sql                   # Table and sequence creation
├── sample_data.sql              # Sample employee, attendance, etc.
├── vw_employee_salary.sql       # Final salary view creation
├── pkg_emp_payroll_system.sql   # Package spec and body
├── test_cases.sql               # Sample procedure calls for testing
└── README.md                    # Project documentation
```

---

## 📋 Tables Used

1. **`employee`** – Stores employee master data  
2. **`attendance`** – Daily attendance records  
3. **`m_attendance_status`** – Master table for attendance statuses  
4. **`salary_component`** – Computed salary data per month  
5. **`deductions`** – Optional deductions  
6. **Sequences** – For generating primary keys (`sal_comp_id_seq`, `attendance_id_seq`)

---

## 🧠 Logic Flow

### ✅ Attendance Insertion

```sql
pkg_emp_payroll_system.p_insert_attendance(p_emp_id, p_attend_date, p_status);
```

- Validates employee and attendance status
- Prevents duplicate entry for same date

### 💰 Monthly Salary Generation

```sql
pkg_emp_payroll_system.p_generate_monthly_salary(p_month, p_year);
```

- Iterates over all employees
- Calculates:
  - HRA = 20% of basic
  - DA = 10% of basic
  - Bonus = 50% of basic if present days > 25
  - Tax = 10% of total
  - Final salary = Basic + HRA + DA + Bonus - Tax
- Inserts record in `salary_component`

### 📄 Payslip Display

```sql
pkg_emp_payroll_system.p_display_payslip(p_emp_id, p_month, p_year);
```

- Validates employee and salary data
- Displays full payslip using `DBMS_OUTPUT`

### 🧮 Tax Calculation

```sql
pkg_emp_payroll_system.fn_calculate_tax(p_total_salary);
```

- Based on salary slabs:
  - 0–10k → 10%
  - 10k–20k → 20%
  - 20k–30k → 30%
  - >30k → 50%

### 📆 Get Working Days

```sql
pkg_emp_payroll_system.f_get_working_days(p_emp_id, p_month, p_year);
```

- Returns count of present days in that month

---

## 📊 View: `vw_employee_salary`

This view joins all components to show a final salary after deduction:

| Column Name        | Description                  |
|--------------------|------------------------------|
| emp_id             | Employee ID                  |
| emp_name           | Employee Name                |
| month, year        | Period of salary             |
| basic_salary       | Base salary from master      |
| hra, da, bonus     | Components calculated        |
| tax                | Tax deducted                 |
| sal_before_deduction | Gross salary               |
| total_deduction_amount | From `deductions` table |
| final_salary       | Net salary                   |

---

## ✅ How to Run the Project

1. Create all tables and sequences from `tables.sql`
2. Insert sample data using `sample_data.sql`
3. Compile the package from `pkg_emp_payroll_system.sql`
4. Create the view using `vw_employee_salary.sql`
5. Test using procedure calls in `test_cases.sql` or via SQL Developer

---

## 🚀 Future Enhancements

- GUI interface using APEX or Java Swing  
- Employee leave module  
- PDF Payslip generation  
- Role-based authentication  
- Attendance auto-fill from biometric system

---

## 🧑‍💻 Author

**Dhanesh**  
[GitHub Profile](https://github.com/yourusername)  
Feel free to fork, improve or suggest enhancements!

---

## 📝 License

This project is for educational purposes and is released under the MIT License.