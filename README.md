# Loan Management System (SQL Project)

## 📌 Project Overview  
This project is a **Loan Management System** built entirely in **MySQL**.  
It demonstrates how SQL can be used to manage, analyze, and process loan-related data with features like income classification, interest calculation, loan status verification, and customer data updates.  

The project is structured in multiple phases (Sheets) that replicate real-world financial workflows.

---

## ⚙️ Technologies Used  
- **MySQL** (Database & Queries)  
- **Triggers & Procedures** (Automation)  
- **Transactions** (Data integrity)  
- **Joins & Aggregations** (Relational analysis)  

---

## 📊 Project Workflow  

### **Sheet 1 – Customer Income Classification**  
- Classified customers into **Grade A, Grade B, Middle Class, Low Class** based on applicant income.  
- Created table `customer_income_status`.  
- Introduced interest percentage rules and calculated **monthly & annual interest** in `customer_interest_analysis`.  

### **Sheet 2 – Loan Status Processing (Triggers)**  
- Added **CIBIL Score-based loan classification** using triggers.  
- Automated status updates (High CIBIL, No Penalty, Penalty, Rejected).  
- Stored results in `loan_cibil_score_status_details`.  

### **Sheet 3 – Transactions & Data Updates**  
- Used **transactions** to safely update customer details (gender & age).  
- Created backup tables and audit logs (`customer_gender_update`, `customer_age_update`).  

### **Sheet 4 – Data Integration with Joins**  
- Joined multiple tables:  
  - `customer_det`, `loan_det`, `region_info`, `customer_income`, `country_state`.  
- Created `final_output` table with consolidated customer & loan details.  
- Identified mismatched/incomplete records in `mismatched` table.  

### **Sheet 5 – Stored Procedures**  
- Built stored procedures for automated reporting:  
  - `filter_high_cibil()` → High CIBIL Score loans.  
  - `filter_home_corp()` → Loans for "Home Office" & "Corporate" segments.  
  - `sheet5_output()` → Executes both procedures.  

---

## 🚀 How to Run the Project  
1. Clone this repository:  
   ```bash
   git clone https://github.com/your-username/loan-management-system-sql.git
