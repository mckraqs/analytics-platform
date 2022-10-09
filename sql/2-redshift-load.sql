-- S3 to Redshift COPY command - expected behavior of Airflow operator
-- Before running, please change S3 location URL and credentials IAM role
COPY nyc.main_data
FROM 's3://mpolakowski-showcase-ap-data-prod/gold/nyc/'
IAM_ROLE 'arn:aws:iam::001234567890:role/ap-role-redshift-prod'
FORMAT AS PARQUET;

-- Simple select to check
SELECT * FROM nyc.main_data;
