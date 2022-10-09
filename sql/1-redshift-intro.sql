-- Create nyc schema
CREATE schema nyc;

-- Create main_data table.
CREATE TABLE nyc.main_data (
  pulocationid text
  , trip_type text
  , payment_type text
  , total_fare_amount float
);
