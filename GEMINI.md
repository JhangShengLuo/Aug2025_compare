# Project Goal: Row vs. Columnar Database Comparison

This project is designed to provide a hands-on tutorial comparing the performance of a traditional row-oriented database (PostgreSQL) with a columnar database (ClickHouse).

## Key Objectives:

1.  **Clear Comparison:** The primary goal is to provide a clear, practical understanding of the architectural differences between row-oriented and columnar databases.
2.  **Hands-On Experience:** The project should be a hands-on experience for the data team, allowing them to run benchmark queries against both PostgreSQL and ClickHouse.
3.  **Easy to Use:** The project should be easy to set up and use, with a web-based UI for both databases.
4.  **Fast Setup:** The entire process, from setup to benchmark analysis, should be completable within 30 minutes.

## Core Components:

*   **Docker Compose Setup:** A `docker-compose.yaml` file to easily set up the entire environment, including PostgreSQL, ClickHouse, pgAdmin (for PostgreSQL), Tabix (for ClickHouse), and Jupyter Notebook.
*   **Data Generation:** A SQL script (`Generate_data.sql`) that creates and populates two tables (`orders_row` and `orders_columnar`) with 1 million rows of synthetic data.
*   **Benchmark Queries:** A set of SQL queries (`Benchmark_Queries.sql`) designed to test various database operations, such as point lookups, aggregations, and filtering.
*   **Tutorial:** A detailed guide (`Tutorial.md`) that walks the user through the entire process, from setting up the environment to running the benchmarks and analyzing the results.
