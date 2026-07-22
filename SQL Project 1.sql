--create TABLE
DROP TABLE IF EXISTS retail_sales_1;
CREATE TABLE retail_sales_1
			(--定義資料類型 --設定Primary Key
				transactions_id INT PRIMARY KEY,
				sale_date DATE,--形式必須為years/months/days(ex:2022-11-05) 
				sale_time TIME,
				customer_id INT,
				gender VARCHAR(15),--VARCHAR：代表「可變長度字串」（Variable Characte，(15)：代表這個欄位最多可以存放 15 個字元
				age INT,
				category VARCHAR(15),
				quantity INT,
				price_per_unit FLOAT,
				cogs FLOAT,
				total_sale FLOAT
			);

SELECT * FROM retail_sales_1--確認創建的table中有沒有資料

SELECT--看全部data
	COUNT(*)
FROM retail_sales_1

DELETE FROM retail_sales_1 --檢查空值並刪除(每一欄都要檢查)
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL
	
-- Data exploration
-- How many sales we have
SELECT COUNT(*) as total_sale FROM retail_sales_1

-- How many unique customers we have?
SELECT COUNT(DISTINCT customer_id) as total_customer FROM retail_sales_1

-- What category of products do we have?
SELECT DISTINCT category as category_name FROM retail_sales_1

--Data Analysis and Business key problems Answers
--Q1:Write a SQL query to retrive all columns for sales made on'2022-11-05'
SELECT *
FROM retail_sales_1
WHERE sale_date='2022-11-05'

--Q2:Write a SQL query to retrive all transactions where the category is 'clothing'and the quantity sold is more than 4 in the month of Nov-2022
SELECT 
	*
FROM retail_sales_1
WHERE 
	category='Clothing'
	AND
	TO_CHAR(sale_date,'YYYY-MM')= '2022-11'--用來處理日期格式轉換，這邊將日期轉為只剩月份
	AND
	quantity>=4

	
--Q3:Write a SQL query to calculate the totle sales(total_sale)for each category.
SELECT 
	category,--會以category類別為依據呈現(此時同一類別的category尚未合併)
	SUM(total_sale) as sale_number,--把同一類別的category total_sale 加起來
	COUNT(*) as total_orders--計算這個category類別有幾筆交易
FROM retail_sales_1
GROUP BY 1 --按照SELECT 裡面的第 1 個欄位分組，也就是category，也可以寫GROUP BY category


--Q4:Write a SQL query to find the average age of customers who purchased items from the 'Beaty' category.
SELECT
	ROUND(AVG(age),2) as avg_age --將結果四捨五入到小數點後 2 位
FROM retail_sales_1
WHERE category='Beauty'

--Q5:Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * FROM retail_sales_1
WHERE total_sale>1000

--Q6:Write a SQL query to find the total number of transactions(transaction_id) made by each gender in each category.

SELECT --順序是每一個category(最外層)中每一個性別(中間層)的transaction_id(最內層)
	category, --分組依據
	gender, --分組依據
	COUNT(*) as total_trans --我要看的 計算有幾筆資料(transaction_id)
FROM retail_sales_1
GROUP 
	BY 
	category, 
	gender

--Q7:Write a SQL query to find the average sales for each month.Find out best selling month in each year.
SELECT 
	year,--最後表格會出現的欄位
	month,--最後表格會出現的欄位
	avg_sale--最後表格會出現的欄位
FROM
(
SELECT --順序是每一年(最外層)每一月份(內層)
	EXTRACT(YEAR FROM sale_date) as year, --分組依據 --EXTRACT(要取出的部分 FROM 日期欄位)
	EXTRACT(MONTH FROM sale_date) as month, --分組依據
	AVG(total_sale) as avg_sale, --我要看的
	RANK () OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) 
	--寫法1:RANK() OVER(排名範圍 排序方式) --排名範圍設定PARTITION BY EXTRACT(YEAR FROM sale_date)表示先按照年份分組後再排名
	--PARTITION表示先把資料按照某個欄位分成幾組，然後每一組獨立處理
FROM retail_sales_1
GROUP BY 1,2
) as t1
WHERE rank=1 --留下每一年份rank=1的資料
--ORDER BY 1,3 DESC --寫法2:先針對1(年份)排序，再針對排序每個月份的AVG做降冪排列(為了看銷售量最好的月份是哪個)
	

--Q8:Write a SQL query to find the top 5 customers based on the highest total sales.
SELECT 
	customer_id,
	SUM(total_sale) as total_sale
FROM retail_sales_1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--Q9:Write a SQL query to find the number of unique customers who purchased items from each category.
WITH hourly_sale
AS
(
SELECT 
	category
	customer_id,
	COUNT(DISTINCT customer_id) AS customers_number --避免重覆計算同一位顧客重複購買的情況
	FROM retail_sales_1
GROUP BY 1

--Q10:Write a SQL query to create each shift and number of orders(Ex:Morning<=12,Afternoon between 12~17,Evening>17)
WITH hourly_sale AS --建立一個暫時的資料表（CTE)
(
	SELECT *,
		CASE --類似if...else語法
			WHEN EXTRACT(HOUR FROM sale_time)<12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
			END as shift --CASE 和 END 是一組(條件判斷到這裡結束)
	FROM retail_sales_1
)

SELECT
	shift,
	COUNT(*) as total_order_number
FROM hourly_sale
GROUP BY shift;
