# Hands-On Tutorial: Row vs. Columnar Database Performance
**Objective:** To understand the fundamental performance differences between a traditional row-oriented database (PostgreSQL) and a columnar database (Hydra) through hands-on benchmarking.

## Section 1: Environment Setup
In this section, we will launch our databases using Docker and load them with 1 million rows of synthetic data.

### 1.1. Start the Environment:

* Ensure you have Docker and Docker Compose installed.

* Create a directory for this project.

* Inside, create the following structure:

```
/your-project-folder
|-- docker-compose.yml
|-- /data_generation
|   |-- 1_init_schema_and_data.sql
|-- /notebooks
```

* Place the provided docker-compose.yml and the SQL script in their respective locations.

* Open your terminal in the project root and run:

```
docker-compose up -d
```

* This command will download the images and start the PostgreSQL, Hydra, and Jupyter containers. The initial data generation may take a few minutes.

### 1.2. Connect to the Databases:

* You can use any SQL client (like pgAdmin, DBeaver, psql, or a VS Code extension) to connect.

* PostgreSQL (Row-Store):

  * Host: `localhost`

  * Port: `5432`

  * Database: `postgres_db`

  * User: `admin`

  * Password: `password`

* Hydra (Columnar-Store):

  * Host: `localhost`

  * Port: `5433`

  * Database: `hydra_db`

  * User: `admin`

  * Password: `password`

### 1.3. Verify Data Loading:

* Connect to each database and run a simple count to ensure the data is loaded:

```
SELECT COUNT(*) FROM orders_row; -- Should return 1,000,000
SELECT COUNT(*) FROM orders_columnar; -- Should return 1,000,000
```

## Section 2: Query Benchmarks
Now, let's run the benchmark queries. Use `EXPLAIN ANALYZE` before each query to see the execution plan and, most importantly, the `Execution Time`.

### 2.1. Instructions:

1. Open two query editor tabs in your SQL client, one for PostgreSQL and one for Hydra.

2. First, get a sample order_id for the point-lookup query. Run this on the PostgreSQL DB:

```
SELECT order_id FROM orders_row LIMIT 1;
```

3. Copy the UUID and replace :lookup_uuid in the benchmark script with it.

4. Run each of the 5 benchmark queries on both databases.

5. Record the Execution Time from the output of `EXPLAIN ANALYZE` for each query in the table below.

### 2.2. Results Table:

| Query Type | PostgreSQL Time (ms) | Hydra Time (ms) | Winner |
|------------|----------------------|-----------------|--------|
| Point Lookup | 0.5 | 1.2 | PostgreSQL |
| Aggregation | 2100 | 900 | Hydra |
| Filtering | 1800 | 700 | Hydra |
| Analytical | 3200 | 1100 | Hydra |
| Full Scan Aggregation | 4500 | 2000 | Hydra |

## Section 3: Performance Analysis
This is where we analyze why we see these performance differences.

### 3.1. Point Lookup: Why did the row-store win?

* PostgreSQL uses a B-tree index on the `order_id`. It can very quickly locate the exact disk block containing the entire row and return it.

* Hydra, being columnar, has to "stitch together" the requested columns from different files, which adds overhead for single-row lookups.

### 3.2. Aggregation & Analytical Queries: Why did the columnar-store win?

* Hydra only reads the data for the columns mentioned in the query (`region`, `price`, `quantity`, `customer_id`). It completely ignores the other columns, leading to a massive reduction in I/O.

* PostgreSQL, a row-store, must load the entire row into memory for every record it processes, even if it only needs a few columns. This is highly inefficient for analytical workloads.

* Columnar data is also highly compressible, further reducing I/O.

## Section 4: Cheat Sheet - Row vs. Columnar

### 4.1. Feature

| Feature | Row-Oriented (PostgreSQL) | Columnar (Hydra) |
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
    "PostgreSQL (ms)": [0.5, 2100, 1800, 3200, 4500],  # Example values
    "Hydra (ms)": [1.2, 900, 700, 1100, 2000]        # Example values
}

df = pd.DataFrame(data)

# Plotting the results
fig, ax = plt.subplots(figsize=(12, 7))
width = 0.35
x = range(len(df["Query"]))

rects1 = ax.bar([i - width/2 for i in x], df["PostgreSQL (ms)"], width, label="PostgreSQL (Row)", color='skyblue')
rects2 = ax.bar([i + width/2 for i in x], df["Hydra (ms)"], width, label="Hydra (Columnar)", color='lightcoral')

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