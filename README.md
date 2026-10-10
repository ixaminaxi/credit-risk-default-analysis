# Credit Card Default: SQL Exploration and a Simple Prediction Model

An analysis of which customer characteristics are associated with missing a credit card payment, followed by an explainable prediction model and a simple review-capacity recommendation. Part 1 uses SQL (SQLite); Part 2 uses Python (pandas, scikit-learn).

## Summary

- 22.1% of the 30,000 customers (6,636) missed the following month's payment.
- Recent late payment is by far the strongest signal: the default rate is 13-17% for customers who paid on time or paid the minimum, 33.9% at one month late and 69.1% at two months late.
- Credit limit and credit utilisation carry smaller signals (36.1% default for the lowest limits against 15.1% for the highest; 18.3% to 30.1% across utilisation bands).
- A logistic regression model reaches an AUC of 0.745 on 6,000 held-out customers. Flagging the riskiest 20% of customers catches 48.6% of defaulters, and 53.8% of those flagged did default.
- The model is not clearly better than a simple lateness rule at the top of the ranking. Its advantage is that it gives every customer a probability and ranks better further down the list.

## Data

UCI *Default of Credit Card Clients* dataset: 30,000 credit card customers in Taiwan, April to September 2005, with the outcome `default_next_month` (1 = missed the required payment the following month, 0 = paid).

- Source: https://archive.ics.uci.edu/dataset/350/default+of+credit+card+clients (CC BY 4.0)
- Reference: Yeh, I. C. and Lien, C. H. (2009), *The comparisons of data mining techniques for the predictive accuracy of probability of default of credit card clients*, Expert Systems with Applications, 36(2), 2473-2480.
- `credit_default.csv` is the original file converted to CSV, with column names lower-cased. `pay_1` is the repayment status for September 2005 (`PAY_0` in the original), and `pay_2` to `pay_6` run backwards to April.
- Repayment status codes: -1 = paid on time; 1, 2, 3... = months late. The codes 0 and -2 are not documented in the source and are commonly read as "paid the minimum" and "no consumption".

## Part 1: SQL exploration

Seven queries in `queries.sql`, each with a short finding; all result tables are in `results.md`.

| Query | Question |
|---|---|
| Q1-Q2 | Size of the data and overall default rate |
| Q3 | Default rate by repayment status last month |
| Q4 | Default rate by credit limit band |
| Q5 | Default rate by credit utilisation (latest bill / credit limit) |
| Q6 | Lateness and utilisation combined |
| Q7 | How much of the default total sits in each lateness group |

| Signal | Lowest-risk group | Highest-risk group |
|---|---|---|
| Repayment status last month | On time or minimum: 13-17% | 2 months late: 69.1% |
| Credit limit | 200k and above: 15.1% | Under 50k: 36.1% |
| Credit used (latest bill / limit) | Under 25%: 18.3% | Over 100%: 30.1% |

- Utilisation adds information mainly for customers one month late (29.9% below 50% utilisation, 42.5% above). For on-time customers and those two or more months late it makes little difference.
- Customers two or more months late are 10.4% of the data but account for 32.8% of defaults. However, 48.3% of defaults come from customers who paid on time or paid the minimum, so lateness alone does not identify most defaulters. This motivates the model.

## Part 2: Prediction model

Notebook: `credit-risk-default-analysis.ipynb`.

**Method.** The data was split 80/20 (stratified, `random_state=42`) into 24,000 training and 6,000 test customers; the test set contains 1,327 defaulters. The model is a logistic regression on standardised inputs, chosen because its weights can be read directly. Inputs are the six repayment statuses, credit limit, and credit utilisation. Sex, marital status, age and education were deliberately excluded: sex, marriage and age are protected characteristics under UK equality law, and education can act as a proxy for them.

**Results on the 6,000 held-out customers.**

| Model | AUC | Riskiest 10% flagged: share of defaulters caught | Riskiest 20% | Riskiest 30% |
|---|---|---|---|---|
| Lateness only (`pay_1` as a score) | 0.676 | n/a | n/a | n/a |
| Model 1: repayment codes as plain numbers | 0.698 | 31.1% | 47.6% | 56.2% |
| Model 2: repayment codes as categories | 0.745 | 30.5% | 48.6% | 60.0% |

The repayment codes are labels, not a numeric scale. Treating them as categories (one on/off switch per code, with codes of 4 and above grouped) raised AUC from 0.698 to 0.745. The gain came mainly further down the ranking; in the riskiest 10% the two models performed about the same. Model 2's average predicted risk (0.221) matched the actual default rate (0.221), which is a basic check rather than a full calibration test.

**Comparison with a simple rule.** In the SQL analysis, flagging customers two or more months late (10.4% of customers) caught 32.8% of defaults, against 30.5% for the model's riskiest 10%. The two use different samples, so the comparison is approximate.

**What drives the predictions.** Weights are on standardised inputs and show association, not cause; compare their sizes with each other, not as percentages.

| Direction | Clue | Weight |
|---|---|---|
| Raises predicted risk | 2 months late in the latest month | +0.47 |
| Lowers predicted risk | Paid the minimum in the latest month | -0.34 |
| Lowers predicted risk | Higher credit limit | -0.23 |
| Raises predicted risk | Higher credit utilisation | +0.11 |

This agrees with the SQL findings. Rare or overlapping codes (for example 3 months late) have unstable weights and should not be read individually.

**Trade-off for a review team.**

| Flag riskiest | Customers flagged | Defaulters caught | Share of all defaulters caught | Share of flagged who default | Risk cutoff |
|---|---|---|---|---|---|
| 10% | 600 | 405 | 30.5% | 67.5% | 0.58 |
| 20% | 1,200 | 645 | 48.6% | 53.8% | 0.27 |
| 30% | 1,800 | 796 | 60.0% | 44.2% | 0.19 |
| 40% | 2,400 | 899 | 67.7% | 37.5% | 0.16 |

Moving from 20% to 30% adds 600 flagged customers, of whom about 25% default. Moving from 30% to 40% adds customers who default at about 17%, below the 22.1% average, so the extra flags are less risky than a typical customer.

**Recommendation.** On this data, a review capacity of roughly 20% of customers (risk cutoff about 0.27) balances coverage and accuracy. Extending to 30% reaches 60% of defaulters with diminishing returns, and beyond 30% the extra flags are less risky than average. The right cutoff depends on the bank's cost of review relative to its loss on a default, which this dataset does not contain.

## Limitations

- Taiwan, 2005 data; not representative of UK lending today.
- "Default" is the source label (a missed payment the following month), not a regulatory definition.
- The repayment codes 0 and -2 are not documented in the source.
- One train/test split, with no cross-validation or confidence intervals. With 1,327 test defaulters, the percentages carry sampling noise.
- Only the latest month's utilisation is used, and logistic regression cannot capture non-linear effects.
- Demographic variables were excluded, but other inputs may still correlate with them. No fairness testing was done.
- Weights show association, not cause.

## Reproducing the results

- **SQL:** import `credit_default.csv` into SQLite (for example with DB Browser for SQLite) as a table named `clients`, then run `queries.sql`.
- **Python:** requires pandas and scikit-learn. Place `credit_default.csv` in the same folder as the notebook and run all cells.

## Files

- `queries.sql`: the SQL queries, with a short finding under each
- `results.md`: result tables for all queries
- `credit-risk-default-analysis.ipynb`: the Python model
- `credit_default.csv`: the data

## Licence

Code and write-up: MIT. Data: CC BY 4.0, see the source link above.
