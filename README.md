# Credit Card Default: SQL Exploration

An exploratory analysis of credit card default in SQL (SQLite), with a Python prediction model to follow. The aim is to find out which customer characteristics are associated with missing a payment, and how well a simple rule based on late payment would work.

**Status:** Part 1 (SQL exploration) is complete. Part 2 (Python default-prediction model) is in progress.

## Data

UCI *Default of Credit Card Clients* dataset: 30,000 credit card customers in Taiwan, April to September 2005, with the outcome `default_next_month` (1 = missed the required payment the following month, 0 = paid).

- Source: https://archive.ics.uci.edu/dataset/350/default+of+credit+card+clients (CC BY 4.0)
- Reference: Yeh, I. C. and Lien, C. H. (2009), *The comparisons of data mining techniques for the predictive accuracy of probability of default of credit card clients*, Expert Systems with Applications, 36(2), 2473-2480.
- `credit_default.csv` is the original file converted to CSV, with column names lower-cased. `pay_1` is the repayment status for September 2005 (`PAY_0` in the original).

## Method

Seven queries in `queries.sql`, each with its result in `results.md`:

- Q1. Number of customers
- Q2. Overall default rate
- Q3. Default rate by repayment status last month
- Q4. Default rate by credit limit band
- Q5. Default rate by credit utilisation (latest bill / credit limit)
- Q6. Lateness and utilisation combined
- Q7. How much of the default total sits in each lateness group
  
To reproduce: import `credit_default.csv` into SQLite (for example with DB Browser for SQLite) as a table named `clients`, then run `queries.sql`.

## Findings

Overall, 22.1% of customers (6,636 of 30,000) missed the next payment.

| Signal | Lowest-risk group | Highest-risk group |
|---|---|---|
| Repayment status last month | On time or minimum: 13-17% | 2 months late: 69.1% |
| Credit limit | 200k and above: 15.1% | Under 50k: 36.1% |
| Credit used (latest bill / limit) | Under 25%: 18.3% | Over 100%: 30.1% |

- Late payment is the strongest signal. The default rate rises from about 13% for on-time customers to 34% at one month late and 69% at two months late.
- Credit utilisation adds information mainly for customers one month late (29.9% below 50% utilisation, 42.5% above). For on-time customers and those two or more months late it makes little difference.
- Customers two or more months late are 10.4% of the data but account for 32.8% of defaults. However, 48.3% of defaults come from customers who paid on time or paid the minimum, so late payment alone does not identify most defaulters. This motivates the model in Part 2.

## Limitations

- The data is from Taiwan in 2005 and is not representative of UK lending today.
- "Default" is the label in the source data (a missed payment the following month). It is not the regulatory definition of default.
- The values `0` and `-2` in the repayment status are not documented in the source. They are commonly read as "paid the minimum" and "no consumption".
- Groups above four months late contain fewer than 100 customers each, so their rates are unstable.
- The results describe patterns in the data and do not show cause.

## Files

- `queries.sql`: the queries, with a short finding under each
- `results.md`: result tables
- `credit_default.csv`: the data
