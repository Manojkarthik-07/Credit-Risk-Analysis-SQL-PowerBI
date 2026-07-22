CREATE VIEW transactions_risk AS
SELECT *,
  (
    CASE
      WHEN amount > customer_avg_spend * 3 THEN 2
      WHEN amount > customer_avg_spend * 1.8 THEN 1
      ELSE 0
    END
    + CASE WHEN merchant_type = 'New' THEN 1 ELSE 0 END
    + CASE WHEN country <> 'US' THEN 2 ELSE 0 END
    + CASE WHEN customer_account_tenure_months < 4 THEN 1 ELSE 0 END
  ) AS risk_score
FROM fraud_transactions;

SELECT
  CASE WHEN risk_score >= 4 THEN 'High'
       WHEN risk_score >= 2 THEN 'Medium'
       ELSE 'Low' END AS risk_bucket,
  COUNT(*) total, SUM(is_fraud) actual_fraud, ROUND(AVG(is_fraud)*100,2) fraud_rate_pct
FROM transactions_risk
GROUP BY risk_bucket ORDER BY fraud_rate_pct DESC;