SELECT
  CASE
    WHEN T.pickup_hour = 0 THEN '00:00'
    WHEN T.pickup_hour = 1 THEN '01:00'
    WHEN T.pickup_hour = 2 THEN '02:00'
    WHEN T.pickup_hour = 3 THEN '03:00'
    WHEN T.pickup_hour = 4 THEN '04:00'
    WHEN T.pickup_hour = 5 THEN '05:00'
    WHEN T.pickup_hour = 6 THEN '06:00'
    WHEN T.pickup_hour = 7 THEN '07:00'
    WHEN T.pickup_hour = 8 THEN '08:00'
    WHEN T.pickup_hour = 9 THEN '09:00'
    WHEN T.pickup_hour = 10 THEN '10:00'
    WHEN T.pickup_hour = 11 THEN '11:00'
    WHEN T.pickup_hour = 12 THEN '12:00'
    WHEN T.pickup_hour = 13 THEN '13:00'
    WHEN T.pickup_hour = 14 THEN '14:00'
    WHEN T.pickup_hour = 15 THEN '15:00'
    WHEN T.pickup_hour = 16 THEN '16:00'
    WHEN T.pickup_hour = 17 THEN '17:00'
    WHEN T.pickup_hour = 18 THEN '18:00'
    WHEN T.pickup_hour = 19 THEN '19:00'
    WHEN T.pickup_hour = 20 THEN '20:00'
    WHEN T.pickup_hour = 21 THEN '21:00'
    WHEN T.pickup_hour = 22 THEN '22:00'
    WHEN T.pickup_hour = 23 THEN '23:00'
  ELSE 'N/A'
  END AS `Pickup Hour`,
  T.num AS `Number of Rides`
FROM
  (
    SELECT
      hour(tpep_pickup_datetime) AS pickup_hour,
      COUNT(*) AS num
    FROM
      `samples`.`nyctaxi`.`trips`
    WHERE
      tpep_pickup_datetime BETWEEN TIMESTAMP '{{ pickup_date.start }}'
      AND TIMESTAMP '{{ pickup_date.end }}'
      AND pickup_zip IN ({{ pickup_zip }})
    GROUP BY 1
  ) T
