SELECT
  T.route as `Route`,
  T.frequency as `Route Frequency`,
  concat(
    '<a style="color:',CASE
      WHEN T.total_fare BETWEEN 101
      AND 6000 THEN '#1FA873'
      WHEN T.total_fare BETWEEN 51
      AND 100 THEN '#FFD465'
      WHEN T.total_fare BETWEEN 0
      AND 50 THEN '#9C2638'
      ELSE '#85CADE'
    END,
    ';"> $',
    format_number(T.total_fare, 0),
    '</a>'
  ) as `Total Fares`
FROM
  (
    SELECT
      concat(pickup_zip, '-', dropoff_zip) AS route,
      count(*) as frequency,
      SUM(fare_amount) as total_fare
    FROM
      `samples`.`nyctaxi`.`trips`
    WHERE
      tpep_pickup_datetime BETWEEN TIMESTAMP '{{ pickup_date.start }}'
      AND TIMESTAMP '{{ pickup_date.end }}'
      AND pickup_zip IN ({{ pickup_zip }})
    GROUP BY
      1
  ) T
ORDER BY
  1 ASC
LIMIT
  200
