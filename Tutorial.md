# Hands-On Tutorial: Row vs. Columnar Database Performance
**Objective:** To understand the fundamental performance differences between a traditional row-oriented database (PostgreSQL) and a columnar database (ClickHouse) through hands-on benchmarking.

## Section 1: Environment Setup
In this section, we will launch our databases using Docker and load them with 1 million rows of synthetic data.

### 1.1. Start the Environment:

* Ensure you have Docker and Docker Compose installed.

* Open your terminal in the project root and run:

```
docker-compose up -d
```

* This command will download the images and start the PostgreSQL, ClickHouse, pgAdmin, Tabix, and Jupyter containers. The initial data generation may take a few minutes.

### 1.2. Connect to the Databases:

* We will use web-based UIs to interact with our databases.

* **PostgreSQL (Row-Store):**

  * Open your web browser to `http://localhost:5050` to access pgAdmin.
  * Login with the email `admin@example.com` and the password `admin`.
  * Click on "Add New Server".
  * In the "General" tab, give the server a name (e.g., `PostgreSQL-Row`).
  * In the "Connection" tab, enter the following:
    * Host name/address: `postgres`
    * Port: `5432`
    * Maintenance database: `postgres_db`
    * Username: `admin`
    * Password: `password`
  * Click "Save". You can now browse the `postgres_db` database.

* **ClickHouse (Columnar-Store):**

  * Open your web browser to `http://localhost:8080` to access Tabix.
  * Click on "Add server".
  * Enter the following:
    * Server name: `ClickHouse-Columnar`
    * Host: `clickhouse`
    * Port: `8123`
  * Click "Save". You can now query the `default` database.

### 1.3. Verify Data Loading:

* In pgAdmin, open a query tool for the `postgres_db` and run:

```sql
SELECT COUNT(*) FROM orders_row;
```

* In Tabix, run the following query:

```sql
SELECT COUNT(*) FROM orders_columnar;
```

* Both queries should return `1,000,000`.

## Section 2: Query Benchmarks
Now, let's run the benchmark queries.

### 2.1. Instructions:

1. In pgAdmin, open a query tool for the `postgres_db`.
2. In Tabix, open a query editor.
3. First, get a sample `order_id` for the point-lookup query. Run this on the PostgreSQL DB:

```sql
SELECT order_id FROM orders_row LIMIT 1;
```

4. Copy the UUID and replace `'your-uuid-here'` in the benchmark script with it.
5. Run each of the 5 benchmark queries on both databases.
6. Record the Execution Time for each query in the table below.

### 2.2. Results Table:

| Query Type | PostgreSQL Time (ms) | ClickHouse Time (ms) | Winner |
|------------|----------------------|-----------------|--------|
| Point Lookup | | | |
| Aggregation | | | |
| Filtering | | | |
| Analytical | | | |
| Full Scan Aggregation | | | |

## Section 3: Performance Analysis
This is where we analyze why we see these performance differences.

### 3.1. Point Lookup: Why did the row-store win?

* PostgreSQL uses a B-tree index on the `order_id`. It can very quickly locate the exact disk block containing the entire row and return it.

* ClickHouse, being columnar, has to "stitch together" the requested columns from different files, which adds overhead for single-row lookups.

### 3.2. Aggregation & Analytical Queries: Why did the columnar-store win?

* ClickHouse only reads the data for the columns mentioned in the query (`region`, `price`, `quantity`, `customer_id`). It completely ignores the other columns, leading to a massive reduction in I/O.

* PostgreSQL, a row-store, must load the entire row into memory for every record it processes, even if it only needs a few columns. This is highly inefficient for analytical workloads.

* Columnar data is also highly compressible, further reducing I/O.

## Section 4: Cheat Sheet - Row vs. Columnar

### 4.1. Feature

| Feature | Row-Oriented (PostgreSQL) | Columnar (ClickHouse) |
|---------|--------------------------|------------------|
| Best For | OLTP (Online Transaction Processing), Web Apps, ERP Systems | OLAP (Online Analytical Processing), Data Warehouses, BI |
| Primary Operation | `INSERT`, `UPDATE`, `DELETE`, Point `SELECTs` | Bulk `SELECTs`, Aggregations (`SUM`, `AVG`, `COUNT`) |
| Data Storage | All values for a single row are stored together. | All values for a single column are stored together. |
| I/O Pattern | Reads entire rows, even if only one column is needed. | Reads only the specific columns needed for a query. |
| Indexing | Heavily relies on B-tree indexes for fast lookups. | Indexes are less critical; relies on efficient column scans. |
| Compression | Moderate compression. | Very high compression, as similar data is stored together. |


### 4.2. Bonus: Visualize Your Results

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
ax.set_xticks(x)
ax.set_xticklabels(df["Query"])
ax.legend()

ax.bar_label(rects1, padding=3)
ax.bar_label(rects2, padding=3)

fig.tight_layout()
plt.yscale('log') # Use a logarithmic scale for better visualization if times vary widely
plt.show()
```

## Conclusion
Congratulations! You've now seen firsthand the fundamental trade-offs between row and columnar databases. This understanding is crucial for choosing the right tool for the job in modern data architectures. You can now safely shut down the environment:

```
docker-compose down
```