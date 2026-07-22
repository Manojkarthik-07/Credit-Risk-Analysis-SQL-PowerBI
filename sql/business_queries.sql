SELECT *
FROM fraud_transactions;

SELECT count(*)
FROM fraud_transactions;

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT transaction_id) AS distinct_transaction_ids
FROM fraud_transactions;

SELECT 
	COUNT(*) AS total_rows,
	COUNT(*) FILTER (WHERE transaction_id IS NULL) AS null_transations_id,
	COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customers_id,
	COUNT(*) FILTER (WHERE transaction_datetime IS NULL) AS null_transation_datetime,
	COUNT(*) FILTER (WHERE amount IS NULL) AS null_amount,
	COUNT(*) FILTER (WHERE merchant_category IS NULL) AS null_merchant_category,
	COUNT(*) FILTER (WHERE merchant_type IS NULL) AS null_merchant_type,
	COUNT(*) FILTER (WHERE region IS NULL) AS null_region,
	COUNT(*) FILTER (WHERE country IS NULL) AS null_country,
	COUNT(*) FILTER (WHERE customer_avg_spend IS NULL) AS null_customer_avg_spend,
	COUNT(*) FILTER (WHERE customer_age IS NULL) AS null_customer_age,
	COUNT(*) FILTER (WHERE customer_occupation IS NULL) AS null_customer_occupation,
	COUNT(*) FILTER (WHERE customer_income_group IS NULL) AS null_customer_income_group,
	COUNT(*) FILTER (WHERE customer_account_tenure_months IS NULL) AS null_customer_account_tenure_months,
	COUNT(*) FILTER (WHERE customer_credit_limit IS NULL) AS null_customer_credit_limit,
	COUNT(*) FILTER (WHERE is_fraud IS NULL) AS null_is_fraud
FROM fraud_transactions;

SELECT DISTINCT(merchant_category)
FROM fraud_transactions;


SELECT transaction_id,customer_id
FROM fraud_transactions 								
WHERE transaction_id IS NULL OR customer_id IS NULL

SELECT Min(amount)  		/* gave min amount as 500 and max as 5380.03*/
FROM fraud_transactions

SELECT merchant_category     /* gave no other category */
FROM fraud_transactions
WHERE merchant_category NOT IN ('Grocery','Electronics','Gift Cards','Fuel','Online Retail','Jewelry','Dining','Utilities','ATM Withdrawal','Travel')


SELECT max(customer_age), 			/*min age is 18 and max is 75,nothing unusual*/
	min(customer_age)
FROM fraud_transactions


SELECT MIN(customer_account_tenure_months),
	MAX(customer_account_tenure_months)			/*min months of tenure is 1 and max is 179*/
FROM fraud_transactions

SELECT MIN(customer_credit_limit),   /*found 50000 as the minimum credit limit and 8000000 as the maximum credit limit */ 
	MAX(customer_credit_limit)
FROM fraud_transactions

SELECT DISTINCT(is_fraud)    /*found only 1 and 0 meaning not suspicious*/
FROM fraud_transactions

SELECT DISTINCT
	country,region
FROM fraud_transactions  /*found 6 difffernt and usual countries*/
SELECT DISTINCT	
	customer_occupation
FROM fraud_transactions    /*found 10 unique and usual occupations*/

SELECT DISTINCT
	customer_income_group   /*found nothing unusual but 5 different income groups*/
FROM fraud_transactions

SELECT amount,customer_income_group
FROM fraud_transactions
WHERE amount BETWEEN 3000 AND 5380.03 		/*found 20 low income group customers having transactions between 3000 and 5380.03 which seemd unusual,further checking is done below*/


SELECT amount,customer_income_group,transaction_datetime,merchant_type,customer_avg_spend,is_fraud,country,region
FROM fraud_transactions
WHERE amount BETWEEN 3000 AND 5380.03 AND customer_income_group = 'Low' and is_fraud = 1     /* found 4 low income group customers and out of them 3 are having fraud transactions.the pattern observed is the three fauds are occured in north region of US having 2 newly formed merchant accounts.INSIGHT AND RECOMMENDATION- NEED TO CHECK THE US NORTH REGION ONCE*/

SELECT 
	SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS total_fraud_count /*DISPLAYS 2060 TRANSACTONS ARE FRAUDULENT MEANING 4.12% out of the 50k records is fraud*/
FROM fraud_transactions;

SELECT merchant_category,
	SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END)  AS fraud_count_by_merchant_category
FROM fraud_transactions
GROUP BY merchant_category
ORDER BY fraud_count_by_merchant_category DESC  /* OUT OF 2060 FRAUD TRANSACTIONS 395 ARE FROM GIFT CARDS,363 FROM JEWELERY  AND ELECTRONICS HAS 294,meaning 19% out of the total are through frauds gift cards,17.6% through jewelry and 14.27 through electronics.Immediate action is to check the riskiest fraud occuring merchant types .*/

SELECT
  ROUND(SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM fraud_transactions;

SELECT merchant_category,
  ROUND(SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY merchant_category			/*Gift Cards show the highest fraud rate at 7.92%, followed by Jewelry at 7.31% and Electronics at 5.88%.*/
ORDER BY fraud_rate_pct DESC;

--sql query analysis--

SELECT region,
  COUNT(transaction_id) AS total_transactions,
  SUM(CASE WHEN is_fraud =  1 THEN 1 ELSE 0 END) AS fraud_count_per_region,
  ROUND(SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY region						/*East shows the highest fraud rate, though the difference from other regions should be reviewed further.*/
ORDER BY fraud_rate_pct DESC;


SELECT customer_occupation,
  COUNT(transaction_id) AS total_transactions,
  SUM(CASE WHEN is_fraud =  1 THEN 1 ELSE 0 END) AS fraud_count_per_occupation,
  ROUND(SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY customer_occupation					
ORDER BY fraud_rate_pct DESC; /*Sales Executive has the highest observed fraud rate in this dataset, so it may warrant closer review.*/

SELECT customer_occupation,
  COUNT(transaction_id) AS total_transactions,
  SUM(CASE WHEN is_fraud =  1 THEN 1 ELSE 0 END) AS fraud_count_per_occupation,
  ROUND(SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY customer_occupation					
ORDER BY fraud_rate_pct DESC;


SELECT customer_income_group,
  COUNT(transaction_id) AS total_transactions,
  SUM(CASE WHEN is_fraud =  1 THEN 1 ELSE 0 END) AS fraud_count_per_income_group,
  ROUND(SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY customer_income_group					
ORDER BY fraud_rate_pct DESC; /*The Low income group has the highest observed fraud rate, though the difference versus other groups should be reviewed further*/


SELECT 
	CASE WHEN customer_account_tenure_months < 4 THEN 'New (< 4mons)'
	WHEN customer_account_tenure_months BETWEEN 4 AND 24 THEN 'Established (4-24 mons)'
	ELSE 'Long-standing (24+ mons)' END AS tenure_bucket,
	COUNT(*) AS total_transactions,
	ROUND(AVG(is_fraud ) * 100.0 ,2) AS fraud_pct
FROM fraud_transactions
GROUP BY tenure_bucket
ORDER BY fraud_pct DESC;

SELECT
  CASE
    WHEN amount > customer_avg_spend * 3 THEN 'Very High above baseline'
    WHEN amount > customer_avg_spend * 1.8 THEN 'Moderately above baseline'
    ELSE 'Near baseline'
  END AS spend_bucket,
  COUNT(*) AS total_transactions,
  SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_count,
  ROUND(100.0 * SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY spend_bucket
ORDER BY fraud_rate_pct DESC;

SELECT
  customer_id,
  COUNT(*) AS total_transactions,
  SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_count,
  ROUND(100.0 * SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY customer_id				/*suggests the top 3 customers are the riskiest having 33.33 % of fraud rate each*/
HAVING COUNT(*) >= 3
ORDER BY fraud_rate_pct DESC, fraud_count DESC
LIMIT 10;


SELECT
  DATE_TRUNC('month', transaction_datetime) AS month,
  COUNT(*) AS total_transactions,
  SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_count,
  ROUND(100.0 * SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS fraud_rate_pct
FROM fraud_transactions
GROUP BY DATE_TRUNC('month', transaction_datetime)
ORDER BY month;

SELECT EXTRACT(HOUR FROM transaction_datetime) as hour, 
  COUNT(*) as total, ROUND(SUM(is_fraud)::numeric/COUNT(*)*100,2) as fraud_rate_pct
FROM fraud_transactions GROUP BY hour ORDER BY fraud_rate_pct DESC; /*suggest the most number of frauds are occured during the late night hours specially between 11pm - 4am*/
