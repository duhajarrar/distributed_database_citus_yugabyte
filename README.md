
# Experiment Goals
### This experiment aims to evaluate and compare Yugabyte database VS. Postgres with Citus in terms of Throughput & Latency, under different numbers of Transactions using `pgbench` as an evaluation tool.

## Experiment pre-request: 
1. Install Docker Desktop.
2. Install Postgres.
   
## To run the experiment, do the following steps: 
1. Enter the directory of either [Experiment Setups - Citus](./Experiment%20Setups%20-%20Citus) or [Experiment Setups - Yugabyte](./Experiment%20Setups%20-%20Yugabyte) using `cd <Experiment folder>`.
2. Run the script using `./run_expermint <number of worker nodes>`.
3. After this step, you will get a folder with pgbench log results.

## Find our results after running these steps on both databases in the folder "Experiment Results" above. Our experiment was done using 3 times:
- The 1st time using 3 worker nodes.
- The 2nd time using 5 worker nodes.
- The 3rd time using 7 worker nodes.


## Data analysis
### The R Codes under the [Data Analysis](./Data%20Analysis) folder above are attached as part of the data analysis.

## Collected data
### Collected data used in this experiment is also added in the folder [Experiment Data](./Experiment%20Data).

## Evaluation & Workload
- The workload SQL file is located at [Evaluation Workloads/read50_write50.sql](./Evaluation%20Workloads/read50_write50.sql).
- The `pgbench` used with 20 concurrent clients with the following list of transactions per client: 100, 200, 300, 400, 500.


