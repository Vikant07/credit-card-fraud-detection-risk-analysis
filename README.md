# Credit Card Fraud Detection & Risk Analysis

An end-to-end portfolio project exploring transaction-level fraud patterns, merchant and geographic exposure, transaction behaviour, customer/account characteristics, and investigation workflows using Python, SQL, and Power BI.

> **Dataset context:** The supplied notebook identifies this as a 2026 credit-card fraud detection dataset. The work should be interpreted as analysis of a supplied/synthetic portfolio dataset, not live bank production data.

## Project objectives

- Profile and prepare transaction data for analysis.
- Validate key transaction, entity, date, and fraud-label fields.
- Quantify fraud frequency and reported loss separately from fraudulent transaction value.
- Examine fraud patterns by time, channel, merchant category, country, transaction behaviour, and account/customer segments.
- Present findings in a six-page Power BI report and management-facing report/presentation.

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

## Dataset and validation notes

The cleaned CSV supplied with this project contains 100,000 transaction rows and 54 columns. The independently reviewed file had no remaining missing cells and no duplicate transaction IDs. The target label contains 2,055 fraud-labelled transactions, corresponding to a 2.055% rate among the 100,000 labelled transactions.

A temporal data-quality issue was identified and is disclosed in the report: `transaction_day_of_week` disagrees with the weekday derived from `transaction_datetime` on all 100,000 rows, while `is_weekend` disagrees with the timestamp-derived weekend flag on 57,158 rows. Time-of-week analysis should therefore use timestamp-derived fields until the source flags are corrected.

Currency is not specified in the supplied schema. Monetary figures are therefore described as dataset currency units unless the source currency is independently confirmed. `fraud_transaction_value` and `fraud_amount_lost` are different measures and must not be conflated.

## Tools

- Python: Pandas, NumPy, Matplotlib
- SQL: MySQL 8.0+
- BI: Power BI Desktop, DAX, Power Query
- Deliverables: DOCX, PDF, PPTX

## Reproducing the analysis

### Python notebook

1. Install Python 3.10+ and the dependencies:

   ```bash
   pip install pandas numpy matplotlib jupyter
   ```
2. Open `notebooks/Credit_Card_Fraud_Data_Cleaning_EDA.ipynb` in Jupyter Notebook, JupyterLab, or Kaggle.
3. Set the CSV path in the data-loading cell to `data/credit_card_fraud_cleaned.csv` when running locally, or attach the source dataset in Kaggle and use its input path.
4. Run the notebook top to bottom and review the generated quality checks and EDA outputs.

### SQL

1. Create/select the MySQL database `projectdata`.
2. Import the source CSV into a table named `credit_card_fraud_detection_2026` if it is not already present.
3. Open `sql/Credit_Card_Fraud_Detection_SQL_Analysis.sql` in MySQL Workbench.
4. Review the source column names against the imported table before creating the cleaning view.
5. Execute the view creation and analysis statements section by section.

The SQL file has been reviewed as code; repository users should execute it in their own MySQL instance and validate the returned results.

### Power BI / DAX

- `dax/Credit_Card_Fraud_Model_Measures.dax` contains reusable model-measure definitions.
- `dax/Credit_Card_Fraud_6_Page_Query_View.dax` contains DAX Query View analysis queries.
- `dax/Credit_Card_Fraud_Combined_DAX_Reference.dax` is a combined reference copy.
- The `power_bi/` directory contains six screenshots of the current report pages.

**The editable Power BI `.pbix` file is not included in this repository package.** Screenshots are evidence of the current report build, not a substitute for the PBIX model. Review the screenshots and known issues before treating every visual as final. In particular, the transaction investigation table and amount distribution visual require final aggregation/visual configuration checks.

## Key analytical definitions

- **Fraud transactions:** distinct nonblank transaction IDs where `is_fraud = 1`.
- **Legitimate transactions:** distinct nonblank transaction IDs where `is_fraud = 0`.
- **Fraud rate:** fraud transactions divided by transactions with a known 0/1 fraud label.
- **Fraud transaction value:** sum of `transaction_amount` for fraud-labelled transactions.
- **Reported fraud amount lost:** sum of `fraud_amount_lost` for fraud-labelled transactions.

`fraud_type` and `fraud_amount_lost` are outcome-derived fields. Do not use them as predictive inputs for a model predicting `is_fraud`.

## Selected findings in the supplied analysis

The current report calculates descriptive rates including online vs. in-store channel differences, high-risk-country vs. other-country differences, overnight-hour differences, and transaction-velocity segments. These are associations in the supplied dataset, not demonstrated causal effects. Refer to the management report for the evidence, definitions, and limitations.
 

 
