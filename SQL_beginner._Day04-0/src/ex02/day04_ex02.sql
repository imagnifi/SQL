CREATE VIEW v_generated_dates AS
SELECT generate_series(DATE '2022-01-01', '2022-01-31', '1 day')::DATE AS generated_date
ORDER BY 1;






