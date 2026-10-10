-- credit-risk-default-analysis: SQL exploration
-- Data: UCI Default of Credit Card Clients (Taiwan, 2005), table "clients"
-- default_next_month = 1 means the customer missed their required payment the following month

-- Q1. How many customers are there?
SELECT COUNT(*) AS customers FROM clients;

-- Q2. What is the overall default rate?
SELECT
  COUNT(*) AS customers,
  SUM(default_next_month) AS defaults,
  ROUND(100.0 * SUM(default_next_month) / COUNT(*), 1) AS default_rate_pct
FROM clients;
-- Finding: 30,000 customers, 6,636 defaults, 22.1%

-- Q3. Default rate by last month's repayment status (pay_1)
SELECT
  pay_1,
  COUNT(*) AS customers,
  SUM(default_next_month) AS defaults,
  ROUND(100.0 * SUM(default_next_month) / COUNT(*), 1) AS default_rate_pct
FROM clients
GROUP BY pay_1
ORDER BY pay_1;
-- Finding: on-time or minimum payers (pay_1 = -1, 0) default at about 13-17%;
-- 1 month late 33.9%; 2 months late 69.1%. Piles above 4 months late are tiny.

-- Q4. Default rate by credit limit band
SELECT
  CASE
    WHEN limit_bal < 50000  THEN '1. Under 50k'
    WHEN limit_bal < 100000 THEN '2. 50k-100k'
    WHEN limit_bal < 200000 THEN '3. 100k-200k'
    ELSE '4. 200k+'
  END AS limit_band,
  COUNT(*) AS customers,
  SUM(default_next_month) AS defaults,
  ROUND(100.0 * SUM(default_next_month) / COUNT(*), 1) AS default_rate_pct
FROM clients
GROUP BY limit_band
ORDER BY limit_band;
-- Finding: lowest limits default at 36.1% vs 15.1% for the highest (about 2.4x).

-- Q5. Default rate by credit utilisation (latest bill / credit limit)
SELECT
  CASE
    WHEN 1.0 * bill_amt1 / limit_bal < 0.25 THEN 'Under 25%'
    WHEN 1.0 * bill_amt1 / limit_bal < 0.50 THEN '25-50%'
    WHEN 1.0 * bill_amt1 / limit_bal < 0.75 THEN '50-75%'
    WHEN 1.0 * bill_amt1 / limit_bal < 1.00 THEN '75-100%'
    ELSE 'Over 100%'
  END AS utilisation_band,
  COUNT(*) AS customers,
  SUM(default_next_month) AS defaults,
  ROUND(100.0 * SUM(default_next_month) / COUNT(*), 1) AS default_rate_pct
FROM clients
GROUP BY utilisation_band
ORDER BY utilisation_band;
-- Finding: default rate rises from 18.3% (under 25% of limit used) to 30.1% (over 100%), about 1.6x. The 50-75% and 75-100% bands are almost equal (26.0% vs 25.8%).
-- Q6. Default rate by lateness AND credit utilisation together
SELECT
  CASE
    WHEN pay_1 <= 0 THEN 'Paid on time or minimum'
    WHEN pay_1 = 1  THEN '1 month late'
    ELSE '2+ months late'
  END AS payment_status,
  CASE
    WHEN 1.0 * bill_amt1 / limit_bal < 0.5 THEN 'Under 50% used'
    ELSE '50%+ used'
  END AS utilisation_band,
  COUNT(*) AS customers,
  SUM(default_next_month) AS defaults,
  ROUND(100.0 * SUM(default_next_month) / COUNT(*), 1) AS default_rate_pct
FROM clients
GROUP BY payment_status, utilisation_band
ORDER BY payment_status, utilisation_band;
-- Finding: lateness dominates. On-time payers default at 13-15% whatever their utilisation; 2+ months late is about 70% either way. Utilisation matters mainly for 1-month-late customers (29.9% under 50% used vs 42.5% at 50%+).
-- Q7. How much of the default problem sits in each lateness group?
SELECT
  CASE
    WHEN pay_1 >= 2 THEN '2+ months late'
    WHEN pay_1 = 1  THEN '1 month late'
    ELSE 'On time / minimum / no balance'
  END AS payment_status,
  COUNT(*) AS customers,
  SUM(default_next_month) AS defaults,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM clients), 1) AS pct_of_all_customers,
  ROUND(100.0 * SUM(default_next_month) / (SELECT SUM(default_next_month) FROM clients), 1) AS pct_of_all_defaults
FROM clients
GROUP BY payment_status
ORDER BY payment_status;
-- Finding: customers 2+ months late are 10.4% of customers but 32.8% of defaults; 48.3% of defaults come from customers who paid on time or paid the minimum, so lateness alone misses almost half.
