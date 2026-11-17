# Credit Card Fraud Detection & Risk Analysis

**End-to-end financial analytics portfolio project | Python · MySQL · Power BI · DAX**

This project analyses 100,000 synthetic credit-card transactions to quantify labelled fraud, identify higher-risk transaction segments, examine transaction behaviour, and communicate investigation priorities through a six-page Power BI report and management deliverables.

> **Recruiter quick read — start here.** This README summarises the business question, dataset, strongest measured patterns, technical work, and project limitations. You do not need to open every file to understand the project.

## Project at a glance

| Item | Summary |
|---|---|
| Business question | Which transaction, channel, geographic, timing, and account segments show higher observed fraud rates? |
| Dataset | 100,000 transaction rows · 54 columns · full-year 2026 synthetic dataset |
| Fraud labels | 2,055 fraud-labelled · 97,945 legitimate · **2.055% overall fraud-label rate** |
| Entities | 8,000 customers · 8,000 cards · 3,000 merchants |
| Coverage | 15 merchant categories · 20 merchant countries |
| Tools | Python (Pandas, NumPy, Matplotlib), MySQL 8.0+, Power Query, Power BI, DAX |
| Outputs | Cleaning/EDA notebook, SQL analysis, DAX measures and queries, six dashboard pages, management report, executive presentation |
| Analysis type | Descriptive and diagnostic analysis of a supplied synthetic dataset; not a production fraud model or live alerting system |

## Key findings — the numbers management should notice

All figures below were recalculated from the supplied cleaned CSV. Fraud rate is **fraud-labelled transactions divided by all transactions in the segment with a known 0/1 label**. Rates are descriptive associations, not proof of causation.

| Observed pattern | Evidence in this dataset | Why it matters |
|---|---|---|
| **Online channel has a higher observed fraud rate than in-store** | Online: **1,447 / 45,532 = 3.18%**. In-store: **287 / 35,777 = 0.80%**. Online represents **70.4%** of all fraud-labelled transactions. | Online transactions are a sensible first segment for deeper control and investigation analysis. The rate difference does not by itself explain why fraud occurs. |
| **Transactions flagged as high-risk-country have a much higher rate** | High-risk-country flag = 1: **545 / 4,932 = 11.05%**. Flag = 0: **1,510 / 95,068 = 1.59%**. | The risk flag isolates a small segment (4.9% of transactions) containing 26.5% of fraud labels. Validate country policy and false-positive implications before operational use. |
| **The 01:00–04:59 time window is elevated** | Timestamp-derived hours 01–04: **123 / 1,444 = 8.52%**. All other hours: **1,932 / 98,556 = 1.96%**. The single highest hour is 03:00: **26 / 230 = 11.30%**. | Overnight activity is a candidate for targeted review. The 03:00 segment has a smaller sample than daytime hours, so show counts alongside rates. |
| **Higher transaction velocity is associated with higher fraud rate** | `transactions_last_1h >= 3`: **501 / 8,990 = 5.57%**. Fewer than 3: **1,554 / 91,010 = 1.71%**. | Recent transaction velocity may be useful as a review signal; it is not sufficient evidence to block a transaction. |
| **Large deviations from the 30-day average show an elevated rate** | `amount_vs_avg_ratio >= 5`: **326 / 8,440 = 3.86%**. Below 5: **1,729 / 91,560 = 1.89%**. | Spending deviation can help prioritise review when combined with other signals and transaction context. |
| **The highest-rate merchant categories include Online Retail and Travel & Airlines** | Online Retail: **446 / 13,417 = 3.32%**. Travel & Airlines: **193 / 6,612 = 2.92%**. | Category-level monitoring can help focus analysis, but segment volume and sample size should always accompany the rate. |

### Portfolio-level financial context

| Measure | Recalculated value |
|---|---:|
| Total transaction value | **12,687,197.67 dataset currency units** |
| Fraud transaction value (`transaction_amount` where `is_fraud = 1`) | **349,209.64 dataset currency units** |
| Reported fraud amount lost (`fraud_amount_lost` for fraud-labelled rows) | **279,842.20 dataset currency units** |

**Do not mix these measures:** fraud transaction value is the value of transactions carrying a fraud label; reported fraud amount lost is the separate `fraud_amount_lost` field. The source schema does not confirm a currency code, so no USD/INR symbol is asserted.

## What I built

- **Python data preparation and EDA:** reviewed the 54-column cleaned dataset, assessed data quality, profiled fraud labels, and compared transaction segments.
- **SQL analysis:** wrote MySQL queries for data-quality checks, KPI summaries, fraud trends, channel/category/country analysis, customer/account segments, and transaction behaviour. The SQL file is code-reviewed but has not been executed against a live MySQL instance as part of this package.
- **Power BI and DAX:** designed a six-page report covering Executive Overview, Time & Channel, Merchant & Geographic Risk, Transaction Behaviour, Customer & Account Risk, and Transaction Investigation.
- **Business communication:** prepared a management report and a separate 11-slide executive presentation to translate the analysis into decisions and next-step recommendations.

## Data quality and interpretation notes

- The cleaned CSV contains **100,000 rows and 54 columns**; the file has **zero missing cells** and **zero duplicate transaction IDs** in the reviewed version.
- The transaction timestamps cover **1 January 2026 to 31 December 2026**. This is a synthetic full-year scenario; dates after the current analysis date must not be interpreted as actual future banking activity.
- **Temporal field inconsistency:** `transaction_day_of_week` disagrees with the weekday derived from `transaction_datetime` on **all 100,000 rows**. `is_weekend` disagrees with the timestamp-derived weekend flag on **57,158 rows**. The time-of-day and time-window figures in this README use the parsed transaction timestamp. Correct the source flags before relying on them in a production process.
- The values are synthetic and do not represent actual customer accounts, cardholders, or a bank's operational fraud exposure.
- The dataset is imbalanced: fraud-labelled transactions are 2.055% of the records. Segment rates should be assessed with counts and sample sizes, not percentages alone.
- The work is descriptive/diagnostic. No validated predictive model, production scoring service, real-time detection, or transaction-blocking capability is claimed.
- `fraud_type` and `fraud_amount_lost` are outcome-derived fields. They must not be used as predictive features when predicting `is_fraud` (target leakage).
- The Power BI `.pbix` file is not included. Screenshots show the current six-page report build, not a fully inspectable model. The transaction investigation table and amount-distribution visual still need final visual/aggregation QA in Power BI Desktop.

## Business recommendations suggested by the evidence

1. **Prioritise online transaction review analysis.** Examine authentication, device, merchant, and transaction context before deciding whether additional controls are justified.
2. **Validate the high-risk-country flag.** Review the flag definition, transaction counts, and potential false positives before using it to influence decisions.
3. **Review overnight and high-velocity segments.** Consider layered review rules and monitor both fraud rate and alert volume; do not use a single variable as an automatic blocking rule.
4. **Combine spend deviation with other indicators.** Large amount-to-average ratios can support investigation prioritisation, but should be interpreted with customer history and transaction context.
5. **Fix the weekday/weekend source fields.** Reconcile the source flags against `transaction_datetime` before publishing time-of-week reporting as a trusted business metric.

These are recommendations for further validation and analysis, not measured savings or proven causal interventions.

## Repository structure

```text
Credit-Card-Fraud-Detection-Project/
├── data/
│   └── credit_card_fraud_cleaned.csv
├── notebooks/
│   └── Credit_Card_Fraud_Data_Cleaning_EDA.ipynb
├── python/
│   └── Credit_Card_Fraud_Detection_Cleaning_EDA.py
├── sql/
│   └── Credit_Card_Fraud_Detection_SQL_Analysis.sql
├── dax/
│   ├── Credit_Card_Fraud_Model_Measures.dax
│   ├── Credit_Card_Fraud_6_Page_Query_View.dax
│   └── Credit_Card_Fraud_Combined_DAX_Reference.dax
├── power_bi/
│   ├── Power_BI_Six_Page_Contact_Sheet.png
│   └── screenshots/  # Six Power BI page screenshots
├── project_brief/
│   └── Credit_Card_Fraud_Detection_Business_Problem.pdf
├── reports/
│   ├── Credit_Card_Fraud_Detection_Management_Report.docx
│   └── Credit_Card_Fraud_Detection_Management_Report.pdf
└── presentation/
    └── Credit_Card_Fraud_Detection_Executive_Deck.pptx
```

## How to review this project quickly

1. Read **Key findings** above for the business story and verified segment metrics.
2. Open `power_bi/Power_BI_Six_Page_Contact_Sheet.png` for the six-page dashboard overview.
3. Open the executive deck in `presentation/` for the management narrative and recommendations.
4. Review the management report in `reports/` for methodology, definitions, evidence, limitations, and implementation priorities.
5. Inspect the notebook, SQL, and DAX folders for technical implementation.

## Reproduce the analysis

### Python notebook

1. Install dependencies:

   ```bash
   pip install pandas numpy matplotlib jupyter
   ```
2. Open `notebooks/Credit_Card_Fraud_Data_Cleaning_EDA.ipynb` in Jupyter Notebook, JupyterLab, or Kaggle.
3. Set the CSV path to `data/credit_card_fraud_cleaned.csv` when running locally, or attach the dataset in Kaggle and use its input path.
4. Run the notebook from top to bottom and review the quality checks and EDA outputs.

### SQL

1. Create/select the MySQL database `projectdata`.
2. Import the source CSV into a table named `credit_card_fraud_detection_2026` if it is not already present.
3. Open `sql/Credit_Card_Fraud_Detection_SQL_Analysis.sql` in MySQL Workbench.
4. Verify the imported column names against the script, then execute the view and analysis statements section by section.

### Power BI / DAX

- `dax/Credit_Card_Fraud_Model_Measures.dax` contains reusable model-measure definitions.
- `dax/Credit_Card_Fraud_6_Page_Query_View.dax` contains DAX Query View analysis queries.
- `dax/Credit_Card_Fraud_Combined_DAX_Reference.dax` is a combined reference.
- `power_bi/` contains six screenshots and a contact sheet of the current report pages.
- The editable `.pbix` file is not included; data model relationships, measure execution, slicer interactions, and drill-through should be validated in Power BI Desktop.

## KPI definitions

- **Fraud transactions:** distinct nonblank transaction IDs where `is_fraud = 1`.
- **Legitimate transactions:** distinct nonblank transaction IDs where `is_fraud = 0`.
- **Fraud rate:** fraud transactions divided by transactions with a known 0/1 fraud label.
- **Fraud transaction value:** sum of `transaction_amount` for fraud-labelled transactions.
- **Reported fraud amount lost:** sum of `fraud_amount_lost` for fraud-labelled transactions.

## Limitations

- Synthetic dataset; findings are not real-world bank performance.
- SQL logic has been reviewed but not executed against a live MySQL database in this package.
- Power BI screenshots do not expose the PBIX semantic model or prove every interaction has been tested.
- Temporal source flags are inconsistent and require correction.
- Currency units are not confirmed.
- Findings are associations, not causal conclusions.

 
