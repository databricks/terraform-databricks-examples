SELECT
  T.weekday,
  CASE
    WHEN T.weekday = 1 THEN 'Sunday'
    WHEN T.weekday = 2 THEN 'Monday'
    WHEN T.weekday = 3 THEN 'Tuesday'
    WHEN T.weekday = 4 THEN 'Wednesday'
    WHEN T.weekday = 5 THEN 'Thursday'
    WHEN T.weekday = 6 THEN 'Friday'
    WHEN T.weekday = 7 THEN 'Saturday'
    ELSE 'N/A'
  END AS day_of_week, 
  T.fare_amount, 
  T.trip_distance
FROM
  (
    SELECT
      dayofweek(tpep_pickup_datetime) as weekday,
      *
    FROM
      `samples`.`nyctaxi`.`trips`
    WHERE
      (
        pickup_zip in ({{ pickup_zip }})
        OR pickup_zip in (10018)
      )
      AND tpep_pickup_datetime BETWEEN TIMESTAMP '{{ pickup_date.start }}'
      AND TIMESTAMP '{{ pickup_date.end }}'
      AND trip_distance < 10
  ) T
ORDER BY
  T.weekday
