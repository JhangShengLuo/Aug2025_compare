# Aug2025_compare
Aug2025_compare


This is an excellent project for understanding modern database architectures. I will provide a complete, hands-on tutorial to compare row-oriented PostgreSQL with the columnar Hydra database.

Here are the components for your tutorial, designed to be self-contained and reproducible.

## 1. Docker Compose Setup
This docker-compose.yml file sets up the PostgreSQL and Hydra containers with the specified resource limits. It also includes a Jupyter Notebook service for visualizing the benchmark results later.

## 2. Data Generation and Loading Scripts
Create a directory named data_generation and place the following SQL script inside it. This script will be automatically executed by both PostgreSQL and Hydra when the containers start.
SQL Data Generation Script
Jul 25, 10:17 AM


## 3. Benchmark Queries
Here are the five queries you'll use to benchmark the two databases. You can run these using a SQL client connected to each database.
Benchmark SQL Queries
Jul 25, 10:17 AM

Open

## 4. Tutorial and Report Template
This Markdown file serves as the main tutorial document for your students. It guides them through the entire process from setup to analysis.
Tutorial: PostgreSQL (Row) vs. Hydra (Columnar)
Jul 25, 10:17 AM

Open

I have provided all the necessary components for your tutorial. You can now assemble the files and directories as described, run docker-compose up, and walk through the benchmark and analysis steps. This hands-on approach should give a very clear and memorable lesson on the core differences between these two powerful database architectures.