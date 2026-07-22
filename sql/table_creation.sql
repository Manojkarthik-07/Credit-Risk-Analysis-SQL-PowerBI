CREATE TABLE fraud_transactions (
  transaction_id VARCHAR(20),
  customer_id VARCHAR(20),
  transaction_datetime TIMESTAMP,
  amount NUMERIC(10,2),
  merchant_category VARCHAR(30),
  merchant_type VARCHAR(10),
  region VARCHAR(20),
  country VARCHAR(10),
  customer_avg_spend NUMERIC(10,2),
  customer_age INTEGER,
  customer_occupation VARCHAR(30),
  customer_income_group VARCHAR(20),
  customer_account_tenure_months INTEGER,
  customer_credit_limit NUMERIC(10,2),
  is_fraud INTEGER
);