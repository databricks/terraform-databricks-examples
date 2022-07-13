SELECT
  count(*) as total_trips
FROM
  `samples`.`nyctaxi`.`trips`
WHERE
  tpep_pickup_datetime BETWEEN TIMESTAMP '{{ pickup_date.start }}'
  AND TIMESTAMP '{{ pickup_date.end }}'
  AND pickup_zip IN ({{ pickup_zip }})
