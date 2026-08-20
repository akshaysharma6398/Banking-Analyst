use sqlproject;
select * from loan_data;
desc loan_data;

## 1.What is the distribution of loans by age group?

SELECT Age , COUNT(*) AS total_loans
FROM loan_data
GROUP BY 1
ORDER BY 1;



## 2.What is the total recovery amount for the states UP, WB, RJ, PB?

SELECT State_Abbr, SUM(Recoveries) AS total_recovery
FROM loan_data 
where State_Abbr in ("UP","WB","RJ","PB")
GROUP BY 1
ORDER BY total_recovery DESC;



## 3. Using CASE Statement Categorize loan terms

SELECT Account_ID, Term,
CASE WHEN Term LIKE '%36%' THEN 'Short Term Loan' 
WHEN Term LIKE '%60%' THEN 'Medium Term Loan ' ELSE 'High Term Loan'
END AS Term_Category
FROM Loan_Data;



## 4. What are the top 5 branches by Loan amount disbursed?

SELECT Branch_Name, SUM(Loan_Amount) AS total_funded
FROM loan_data
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;



## 5. show Region wise total recoverry principle and  average recoveries which is above 75  

SELECT Region_Name, 
SUM(Total_Rec_Prncp) AS total_rec_prncp, 
avg(Recoveries) AS Avg_recoveries
FROM loan_data
GROUP BY Region_Name
HAVING avg_recoveries > 75;




## 6. Rank Branches by Total Disbursement ?

SELECT Branch_Name,
SUM(Loan_Amount) AS total_disbursed,
dense_rank() OVER ( ORDER BY SUM(Loan_Amount) DESC) AS branch_rank
FROM loan_data
GROUP BY Branch_Name;



## 7. Identifying Top 3 Customers by Total recovery principle amount per Region

SELECT *FROM (
SELECT Region_Name,Client_Name, SUM(Total_Rec_Prncp) AS total_rec_Prncp,
DENSE_RANK() OVER (PARTITION BY Region_Name ORDER BY SUM(Total_Rec_Prncp) DESC) AS customer_rank
FROM loan_data
GROUP BY 1,2 ) a
WHERE customer_rank <= 3;



## 8. Subquery to get top 3 cities with highest total loan amount

SELECT city, total_loan FROM (
SELECT city, SUM(loan_amount) AS total_loan
FROM loan_data
GROUP BY 1 ORDER BY 2 DESC
LIMIT 3 ) AS top_cities;



 ## 9. YoY % growth in total loan disbursed (Year over Year)
 
select *, CYL-PYL as Difference, concat (round((CYL-PYL)/PYL *100,2),"%") as YOY_P
from (
SELECT YEAR(Disbursement_Date) AS year, SUM(loan_amount) AS CYL,
LAG(SUM(loan_amount)) OVER (ORDER BY YEAR(Disbursement_Date) asc ) PYL 
FROM Loan_data
GROUP BY 1) a;



## 10. Stored Procedure: Get Loan Summary by State 

call sqlproject.Get_Loan_Summary_State('pb');


## 11. Create View: Caste-wise interest and total recoveries

CREATE VIEW Caste_Recovery_Stats AS
SELECT Caste,
AVG(Int_Rate) AS Avg_Int_Rate,
SUM(Recoveries) AS Total_Recoveries
FROM Loan_Data
GROUP BY Caste ;

select * from Caste_Recovery_stats;



## 12. Find the first name , mid name and last name from credif_officer_name

select distinct credif_officer_name  ,
left(Credif_officer_name, locate(" ",Credif_officer_name)-1) AS First_Name ,
mid(credif_officer_name, locate(" ",credif_Officer_name), locate(" ",credif_officer_name,locate(" ", credif_officer_name)+1) - locate(" ",credif_officer_name)) as Mid_name,
right(credif_officer_name, length(credif_officer_name) - locate(" ",credif_officer_name,locate(" ",credif_officer_name)+1)) as Last_name
from loan_data where length(credif_officer_name)>21;



## 13. Trigger to prevent inserting a record with loan_amount > 100000

create table Loan_analysis (Client_name varchar(40), Loan_amount int);
insert into Loan_analysis values ("Priyanka", 75000),("Imran", 85000),("Neha", 45000);
select * from Loan_analysis;
insert into Loan_analysis values ("Dileep", 200000);



## 14. Using joins , show account id , loan amountand and locker facility for the people who is having deposits more than 20000.  

create table Account_details (Account_id varchar(15) , Type_Of_card varchar(10), Locker_facility varchar(20), Deposit_amount int);
insert into Account_details values ("0010XLG01","credit", "yes", 50000),("0010XLG02","credit", "No", 10000),("0010XLG03","debit", "no", 35000),
("0010XLG04","credit", "no", 45000),("0010XLG05","debit", "yes", 100000),("0010XLG06","credit", "no", 27000),("0010XLG07","Debit", "yes", 15000),
("0010XLG08","debit", "yes", 18000),("0010XLG09","credit", "no", 35000),("0010XLG10","credit", "yes", 75000);
select * from account_details;

select a.account_Id, a.loan_amount, b.Locker_facility
from loan_data as a inner join account_details as b on a.account_id = b.account_id
 where b.deposit_amount >20000;














