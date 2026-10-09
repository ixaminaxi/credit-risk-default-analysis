# SQL results

Results of the queries in `queries.sql`, run on the `clients` table (30,000 customers) of the UCI *Default of Credit Card Clients* dataset (Taiwan, 2005). `default_next_month = 1` means the customer missed the required payment in the month after the data ends, as labelled in the source.

## Q1-Q2. Size and overall default rate

| Customers | Defaults | Default rate (%) |
|---:|---:|---:|
| 30,000 | 6,636 | 22.1 |

## Q3. By repayment status last month (`pay_1`)

| pay_1 | Customers | Defaults | Default rate (%) |
|---|---:|---:|---:|
| -2 | 2,759 | 365 | 13.2 |
| -1 | 5,686 | 954 | 16.8 |
| 0 | 14,737 | 1,888 | 12.8 |
| 1 | 3,688 | 1,252 | 33.9 |
| 2 | 2,667 | 1,844 | 69.1 |
| 3 | 322 | 244 | 75.8 |
| 4 | 76 | 52 | 68.4 |
| 5 | 26 | 13 | 50.0 |
| 6 | 11 | 6 | 54.5 |
| 7 | 9 | 7 | 77.8 |
| 8 | 19 | 11 | 57.9 |

Customers who paid on time or paid the minimum (-1, 0) default at roughly 13-17%. The rate is 33.9% at one month late and 69.1% at two months late. Groups above four months late contain fewer than 100 customers each, so their rates are unstable. Values 0 and -2 are not documented in the source; they are commonly interpreted as "paid the minimum" and "no consumption".

## Q4. By credit limit (NT$)

| Credit limit | Customers | Defaults | Default rate (%) |
|---|---:|---:|---:|
| 1. Under 50k | 4,311 | 1,555 | 36.1 |
| 2. 50k-100k | 7,139 | 1,857 | 26.0 |
| 3. 100k-200k | 7,400 | 1,537 | 20.8 |
| 4. 200k+ | 11,150 | 1,687 | 15.1 |

The lowest-limit group defaults at about 2.4 times the rate of the highest-limit group (36.1% vs 15.1%).

## Q5. By credit utilisation (latest bill / credit limit)

| Utilisation | Customers | Defaults | Default rate (%) |
|---|---:|---:|---:|
| 1. Under 25% | 14,037 | 2,566 | 18.3 |
| 2. 25-50% | 3,589 | 780 | 21.7 |
| 3. 50-75% | 3,579 | 929 | 26.0 |
| 4. 75-100% | 6,672 | 1,723 | 25.8 |
| 5. Over 100% | 2,123 | 638 | 30.1 |

The default rate rises from 18.3% to 30.1% as utilisation increases. The 50-75% and 75-100% bands are almost equal. 590 customers have a negative bill and fall in the lowest band.

## Q6. Lateness and utilisation together

| Payment status | Utilisation | Customers | Defaults | Default rate (%) |
|---|---|---:|---:|---:|
| 1. Paid on time or minimum | 1. Under 50% used | 14,054 | 1,843 | 13.1 |
| 1. Paid on time or minimum | 2. 50%+ used | 9,128 | 1,364 | 14.9 |
| 2. 1 month late | 1. Under 50% used | 2,501 | 748 | 29.9 |
| 2. 1 month late | 2. 50%+ used | 1,187 | 504 | 42.5 |
| 3. 2+ months late | 1. Under 50% used | 1,071 | 755 | 70.5 |
| 3. 2+ months late | 2. 50%+ used | 2,059 | 1,422 | 69.1 |

Lateness dominates. Utilisation matters mainly for customers one month late (29.9% vs 42.5%).

## Q7. Where the defaults sit

| Payment status | Customers | Defaults | % of all customers | % of all defaults |
|---|---:|---:|---:|---:|
| A. 2+ months late | 3,130 | 2,177 | 10.4 | 32.8 |
| B. 1 month late | 3,688 | 1,252 | 12.3 | 18.9 |
| C. On time / minimum / no balance | 23,182 | 3,207 | 77.3 | 48.3 |

Customers two or more months late hold 32.8% of defaults while making up 10.4% of customers. 48.3% of defaults come from customers who paid on time or paid the minimum, so lateness alone does not identify most defaulters.

## Caveats

- The data is from Taiwan in 2005 and is not representative of UK lending today.
- "Default" is as labelled in the source, with no further definition.
- The patterns are descriptive and do not show cause.
