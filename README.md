
# Row vs. Columnar Database Comparison

This project provides a hands-on tutorial comparing the performance of a traditional row-oriented database (PostgreSQL) with a columnar database (ClickHouse).

## Introduction

This project is designed to provide a clear, practical understanding of the architectural differences between row-oriented and columnar databases. By running a series of benchmark queries against both PostgreSQL and ClickHouse, you will be able to see firsthand how each database performs under different workloads.

## Components

This project includes the following components:

*   **Docker Compose Setup:** A `docker-compose.yaml` file to easily set up the entire environment, including PostgreSQL, ClickHouse, Jupyter Notebook, pgAdmin, and ch-ui.
*   **Data Generation:** A SQL script (`Generate_data.sql`) that creates and populates two tables (`orders_row` and `orders_columnar`) with 10 million rows of synthetic data.
*   **Benchmark Queries:** A set of SQL queries (`Benchmark_Queries.sql`) designed to test various database operations, such as point lookups, aggregations, and filtering.
*   **Tutorial:** A detailed guide (`Student_Guide.md`) that walks you through the entire process, from setting up the environment to running the benchmarks and analyzing the results.
*   **Jupyter Notebook:** A notebook is provided to help you visualize the benchmark results.

## Getting Started

To get started with this project, please refer to the `Student_Guide.md` file for detailed instructions on how to set up the environment, run the benchmarks, and analyze the results.

## Reference

This project is based on the following reference:

*   [ClickHouse](https://clickhouse.com/)
