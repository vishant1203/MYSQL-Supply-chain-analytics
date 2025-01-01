# create temporary table for abs error pct for year 2021

create temporary table forecast_err_table_2021
(SELECT f.customer_code, d.customer, d.market,
	   sum(f.sold_quantity),sum(f.forecast_quantity),
	   sum(f.sold_quantity-f.forecast_quantity) as net_error, 
       round(sum(f.sold_quantity-f.forecast_quantity)*100/sum(f.forecast_quantity),1) as net_error_pct,
		sum(abs(f.sold_quantity-f.forecast_quantity)) as abs_error,
		round(sum(abs(f.sold_quantity-f.forecast_quantity))*100/sum(f.forecast_quantity),1) as abs_error_pct
FROM fact_act_est f
JOIN dim_customer d
ON d.customer_code= f.customer_code
where f.fiscal_year="2021"
group by f.customer_code
);

# create temporary table for abs error pct for year 2020
create temporary table forecast_err_table_2020
(SELECT f.customer_code, d.customer, d.market,
	   sum(f.sold_quantity),sum(f.forecast_quantity),
	   sum(f.sold_quantity-f.forecast_quantity) as net_error, 
       round(sum(f.sold_quantity-f.forecast_quantity)*100/sum(f.forecast_quantity),1) as net_error_pct,
		sum(abs(f.sold_quantity-f.forecast_quantity)) as abs_error,
		round(sum(abs(f.sold_quantity-f.forecast_quantity))*100/sum(f.forecast_quantity),1) as abs_error_pct
FROM fact_act_est f
JOIN dim_customer d
ON d.customer_code= f.customer_code
where f.fiscal_year="2020"
group by f.customer_code
);

# forecast accuracy report for the year 2021
with f21 as (select customer_code, customer, market, CASE
			WHEN abs_error_pct>100 THEN 0
            WHEN abs_error_pct<=100 THEN (100-abs_error_pct)
            END as forecast_accuracy_2021 
from forecast_err_table_2021
order by forecast_accuracy_2021 asc),


# forecast accuracy report for the year 2020
f20 as (select customer_code, customer, market, CASE
			WHEN abs_error_pct>100 THEN 0
            WHEN abs_error_pct<=100 THEN (100-abs_error_pct)
            END as forecast_accuracy_2020
from forecast_err_table_2020
order by forecast_accuracy_2020 asc)


# to check drop in forecast accuracy from year 2020 to 2021
SELECT f21.customer_code, f21.customer, f21.market, f20.forecast_accuracy_2020, f21.forecast_accuracy_2021,
(f21.forecast_accuracy_2021- f20.forecast_accuracy_2020) AS drop_from_2020_to_2021
FROM f21
JOIN f20
USING (customer_code, customer, market)
ORDER BY drop_from_2020_to_2021 asc