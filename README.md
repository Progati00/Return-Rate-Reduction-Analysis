# 📊 E-commerce Return Rate Reduction Analysis  

## 📌 Project Overview  
This project analyzes **e-commerce product returns** to identify the key drivers of high return rates and provide actionable insights for reduction.  

**Objective:**  
- Understand *why customers return products*  
- Explore *how return rates vary by category, geography, and marketing channel*  
- Build a **predictive model** for return probability  
- Create **interactive dashboards in Power BI** for visualization  

**Tools & Tech:**  
- **SQL** → Data Cleaning & Preprocessing  
- **Python (Pandas, Scikit-learn, Matplotlib, Seaborn)** → Modeling & Analysis  
- **Power BI** → Dashboards & KPI Visuals  

---

## 🛠️ Dataset  
Synthetic dataset: **`ecommerce_returns_synthetic_data`**  

### After Cleaning in SQL → `updated_ecommerce_returns`  
Columns used:  
- `Order_ID`, `Product_ID`, `User_ID`, `Order_Date`  
- `Product_Category`, `Product_Price`, `Order_Quantity`  
- `Return_Reason`, `Return_Status`  
- `User_Age`, `User_Gender`, `User_Location`  
- `Payment_Method`, `Shipping_Method`, `Discount_Applied`  
- Calculated fields:  
  - `overall_return_rate`  
  - `category_return_rate`  
  - `product_return_rate`  
  - `geography_return_rate`  
  - `reason_pct_of_returns`  

---

## 🧹 SQL Data Preparation  
- Checked for **missing values**  
- Dropped irrelevant columns (`Return_Date`, `Days_to_Return`)  
- Imputed missing `Return_Reason` → `"Not Mentioned"`  
- Calculated:  
  - **Overall return rate**  
  - **Category-level return rate**  
  - **Product-level return rate**  
  - **Geography-level return rate**  
  - **Return reason % contribution**  

```sql
-- Example: Return % by Category
SELECT 
    Product_Category,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN Return_Status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(SUM(CASE WHEN Return_Status = 'Returned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate_pct
FROM ecommerce_returns_synthetic_data 
GROUP BY Product_Category 
ORDER BY return_rate_pct DESC;
````

---

## 🤖 Machine Learning (Python - Logistic Regression)

### Steps

1. **Target Variable**:

   * `Return_Flag` → (1 = Returned, 0 = Not Returned)

2. **Features**:

   * **Categorical**: `Product_Category`, `Return_Reason`, `User_Gender`, `User_Location`, `Payment_Method`, `Shipping_Method`
   * **Numerical**: `Product_Price`, `Order_Quantity`, `User_Age`, `Discount_Applied`

3. **Preprocessing**:

   * One-Hot Encoding for categorical columns
   * Standardization for numerical columns

4. **Model**: Logistic Regression (`max_iter=1000`)

### Results

* **ROC-AUC Score:** `0.84` (after removing leaked engineered features)
* **Classification Report:** Balanced precision & recall
* **Feature Importance:**

  * Discounts and shipping method drive returns the most
  * Younger users show higher return likelihood

---

## 📊 Power BI Dashboard Visuals

### KPI Cards

* **Total Orders**
* **Returned Orders**
* **Overall Return Rate %**
* **Average Discount Applied**
* **Top Returning Category**

### Charts

1. **Area Chart** → *Impact of Discounts on Return Rate*

   * X-axis: Discount\_Applied (binned)
   * Y-axis: Return Rate %

2. **Line Chart** → *Returns Over Time (Yearly trend)*

   * X-axis: Order\_Date (Year)
   * Y-axis: Total Orders
   * Legend: Return\_Status

3. **Pie Chart** → *Return Reasons Breakdown*

   * Values: Count of Return\_Reason
   * Legend: Return\_Reason

4. **Bar Chart** → *Return % by Product Category*

   * X-axis: Product\_Category
   * Y-axis: Return Rate %

5. **Stacked Bar Chart** → *Return Rate by Payment Method + Shipping Method*

   * X-axis: Payment\_Method
   * Y-axis: Return Rate %
   * Legend: Shipping\_Method

6. **Table Chart** → *Category, Return Count, Return %*

   * Columns: Product\_Category | Returned Orders | Total Orders | Return Rate %

---

## 📂 Deliverables

* **SQL scripts** → Data cleaning, aggregations
* **Python notebook** → Logistic regression, feature importance, predictions export
* **Power BI dashboard** → Interactive return rate analysis
* **CSV export** → Predicted return probabilities

---

## 🚀 Insights

* **Discounts** strongly influence return likelihood.
* **Specific product categories** have disproportionately high return rates.
* Return reasons are concentrated around **3–4 major issues**.
* **Payment + Shipping** combinations reveal behavioral return patterns.
* Logistic regression can successfully predict which orders are **most likely to be returned**.

---
