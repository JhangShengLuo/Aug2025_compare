# Teacher's Guide: Setting Up the Database Comparison Environment

**Objective:** To set up the necessary environment for the Row vs. Columnar database performance tutorial.

## Section 1: Environment Setup
In this section, you will launch the databases using Docker and load them with 1 million rows of synthetic data.

### 1.1. Start the Environment:

* Ensure you have Docker and Docker Compose installed.

* Open your terminal in the project root and run:

```
# start the environment
docker-compose up -d

# stop the environment
docker-compose down 
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

## Section 2: Environment Ready for Students

The environment is now set up and ready for the students to begin their query performance comparison. They can now follow the `Student_Guide.md`.

To shut down the environment when the tutorial is complete, run:

```
docker-compose down
```
