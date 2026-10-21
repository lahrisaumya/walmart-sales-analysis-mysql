select*from walmart_sales;
/*Task 1: Identifying the Top Branch by Sales Growth Rate:*/
select `Product line`, 
sum(`Total`) as `Total_Sales`
from walmart_sales
group by `Product line`
order by `Total_Sales` desc
limit 1;
/*Identifying the Sales Branch-wise:*/
select Branch, SUM(`Total`) as `Total_Sales`
from walmart_sales
group by Branch
order by  `Total_Sales` desc;
/*Calculating Branch wise Average growth rate:*/
with MonthlySales as (select Branch,
case
when Month = 'January' then 1
when Month = 'February' then 2
when Month = 'March' then 3
when Month = 'April' then 4
when Month = 'May' then 5
when Month = 'June' then 6
when Month = 'July' then 7
when Month = 'August' then 8
when Month = 'September' then 9
when Month = 'October' then 10
when Month = 'November' then 11
when Month = 'December' then 12
end as MonthNumber,sum(Total) as Total_Sales from walmart_sales
group by Branch, Month),
GrowthSales as (select a.Branch, a.MonthNumber, a.Total_Sales,
case
when b.Total_Sales is null then null
when b.Total_Sales = 0 then null
else round((a.Total_Sales - b.Total_Sales) / b.Total_Sales * 100,3)
end as Growth_Rate
from MonthlySales a
left join MonthlySales b
on a.Branch = b.Branch
and a.MonthNumber = b.MonthNumber + 1)
select Branch, round(avg(Growth_Rate),3) as avg_growth_rate from GrowthSales
where Growth_Rate is not null
group by Branch
order by avg_growth_rate desc;
/*Task 2: Finding the Most Profitable Product Line for Each Branch:*/
with profitmargins as ( select (`cogs` - `gross income`) as profit_margin, Branch, `Product line`,
rank() over(partition by Branch order by (`cogs` - `gross income`)desc) as rnk
from walmart_sales)
select Branch, `Product line`,profit_margin
from profitmargins
where rnk=1
order by round(profit_margin,3) desc;
/*Task 3: Analyzing Customer Segmentation Based on Spending:*/
select Branch, `Customer ID` ,`Customer type`, `City`, `Gender`, `Customer type`,`Product line`,`Total` ,
case
when `Total`<=500.00 then 'LOW'
when `Total`>500.00 AND `Total`<=850.00 then 'MEDIUM'
else 'HIGH'
end as spenders
from walmart_sales;
/*Task 4: Detecting Anomalies in Sales Transactions :*/
with salesanomalies as (select `Product line`, avg(`Total`) as Avg_Sales
from walmart_sales
group by `Product line`)
select ws.`Branch`, ws.`Customer ID`, ws.`Product line`, ws.`Total`, sa.Avg_Sales,
case
when ws.`Total` > 2 * sa.Avg_sales then 'High Anomaly'
when ws.`Total` < 0.5 * sa.Avg_sales then 'Low Anomaly'
else 'Normal'
end as Anomaly_flag
from walmart_sales ws
join salesanomalies sa on ws.`Product line` = sa.`Product line`
order by ws.`Product line`, Anomaly_flag desc, ws.`Total` desc;
/*Task 5: Most Popular Payment Method by City:*/
with paymenttype as (select Payment, City, count(Payment) as paymentmethod, 
rank()over(partition by City order by count(Payment)desc) as rnk from walmart_sales
group by City, Payment)
select City, Payment, paymentmethod from paymenttype
where rnk=1
order by City;
/*Task 6: Monthly Sales Distribution by Gender:*/
select Month, Gender, round(sum(`Total`),1) as Totalsales from walmart_sales
group by Month, Gender
order by Month desc, Gender, Totalsales desc;
/*Task 7: Best Product Line by Customer Type:*/
select `Customer type`, `Product line`, round(sum(`Total`),1) as Totalsales from walmart_sales
group by `Product line`, `Customer type`
order by`Product line`, Totalsales desc;
/*Task 8: Identifying Repeat Customers:*/
select `Customer ID`, 
count(distinct `Customer ID`) as Repeat_Purchases, 
min(`Date`) as First_Purchase, 
max(`Date`)as Last_Purchase,
round(sum(`Total`),2) as Total_Sales from walmart_sales
where (`Days Between Purchases`) <= 30
group by `Customer ID`
order by Total_Sales desc;
/*Task 9: Finding Top 5 Customers by Sales Volume:*/
select `Customer ID`, round(sum(`Total`),1) as Totalsales from walmart_sales
group by `Customer ID`
order by Totalsales desc
limit 5;
/*Task 10: Analyzing Sales Trends by Day of the Week:*/
select `Day`, round(sum(`Total`),1) as Totalsales from walmart_sales
group by `Day`
order by `Day`, Totalsales desc;