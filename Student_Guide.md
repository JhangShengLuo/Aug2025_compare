# Student's Guide: Row vs. Columnar Database Performance

**Objective:** To understand the fundamental performance differences between a traditional row-oriented database (PostgreSQL) and a columnar database (ClickHouse) through hands-on benchmarking.

## Section 1: Query Benchmarks
Now, let's run the benchmark queries.

### 1.1. Instructions:

1. In pgAdmin, open a query tool for the `postgres_db`.
2. In Grafana, navigate to the "Explore" section and select the ClickHouse data source.
3. First, get a sample `order_id` for the point-lookup query. Run this on the PostgreSQL DB:

```sql
SELECT order_id FROM orders_row LIMIT 1;
```

4. Copy the UUID and replace `'your-uuid-here'` in the benchmark script with it.
5. Run each of the 5 benchmark queries on both databases.
6. Record the Execution Time for each query in the table below.

### 1.2. How to Measure Query Time

*   **PostgreSQL (pgAdmin):** Use the `EXPLAIN ANALYZE` command. In the output, look for the `Execution Time` in the "Query Plan" section. This will be in milliseconds (ms).

*   **ClickHouse (Grafana):** Simply run the query. The execution time is displayed in the top right corner of the query editor. It will say `Query took Xms`.

### 1.3. Results Table:

| Query Type | PostgreSQL Time (ms) | ClickHouse Time (ms) | Winner |
|------------|----------------------|-----------------|--------|
| Point Lookup | | | |
| Aggregation | | | |
| Filtering | | | |
| Analytical | | | |
| Full Scan Aggregation | | | |

## Section 2: Performance Analysis
This is where we analyze why we see these performance differences.

### 2.1. Point Lookup: Why did the row-store win?

* PostgreSQL uses a B-tree index on the `order_id`. It can very quickly locate the exact disk block containing the entire row and return it.

* ClickHouse, being columnar, has to "stitch together" the requested columns from different files, which adds overhead for single-row lookups.

### 2.2. Aggregation & Analytical Queries: Why did the columnar-store win?

* ClickHouse only reads the data for the columns mentioned in the query (`region`, `price`, `quantity`, `customer_id`). It completely ignores the other columns, leading to a massive reduction in I/O.

* PostgreSQL, a row-store, must load the entire row into memory for every record it processes, even if it only needs a few columns. This is highly inefficient for analytical workloads.

* Columnar data is also highly compressible, further reducing I/O.

## Section 3: Cheat Sheet - Row vs. Columnar

### 3.1. Feature

| Feature | Row-Oriented (PostgreSQL) | Columnar (ClickHouse) |
|---------|--------------------------|------------------|
| Best For | OLTP (Online Transaction Processing), Web Apps, ERP Systems | OLAP (Online Analytical Processing), Data Warehouses, BI |
| Primary Operation | `INSERT`, `UPDATE`, `DELETE`, Point `SELECTs` | Bulk `SELECTs`, Aggregations (`SUM`, `AVG`, `COUNT`) |
| Data Storage | All values for a single row are stored together. | All values for a single column are stored together. |
| I/O Pattern | Reads entire rows, even if only one column is needed. | Reads only the specific columns needed for a query. |
| Indexing | Heavily relies on B-tree indexes for fast lookups. | Indexes are less critical; relies on efficient column scans. |
| Compression | Moderate compression. | Very high compression, as similar data is stored together. |


### 3.2. Bonus: Visualize Your Results

1. Create a notebooks directory in your project folder.

2. Open your browser to `http://localhost:8888` to access the Jupyter Lab environment.

3. Create a new Python 3 notebook.

4. Install the necessary library to connect to PostgreSQL from the notebook:

```
%pip install psycopg2-binary pandas matplotlib
```

5. Paste and run the following Python code, replacing the placeholder times with your measured results.

``` python
import matplotlib.pyplot as plt
import pandas as pd

# --- IMPORTANT ---
# Replace these placeholder values with your actual measured times in milliseconds!
data = {
    "Query": ["Point Lookup", "Aggregation", "Filtering", "Analytical", "Full Scan"],
    "PostgreSQL (ms)": [],  # Example values
    "ClickHouse (ms)": []        # Example values
}

df = pd.DataFrame(data)

# Plotting the results
fig, ax = plt.subplots(figsize=(12, 7))
width = 0.35
x = range(len(df["Query"]))

rects1 = ax.bar([i - width/2 for i in x], df["PostgreSQL (ms)"], width, label="PostgreSQL (Row)", color='skyblue')
rects2 = ax.bar([i + width/2 for i in x], df["ClickHouse (ms)"], width, label="ClickHouse (Columnar)", color='lightcoral')

# Add some text for labels, title and axes ticks
ax.set_ylabel('Execution Time (ms) - Lower is Better')
ax.set_title('Performance Comparison: Row vs. Columnar Database')
ax.set_xticklabels(df["Query"])
ax.legend()

ax.bar_label(rects1, padding=3)
ax.bar_label(rects2, padding=3)

fig.tight_layout()
plt.yscale('log') # Use a logarithmic scale for better visualization if times vary widely
plt.show()
```

## Conclusion
Congratulations! You've now seen firsthand the fundamental trade-offs between row and columnar databases. This understanding is crucial for choosing the right tool for the job in modern data architectures.
