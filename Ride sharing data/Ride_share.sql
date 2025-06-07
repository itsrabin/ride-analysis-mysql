--created database ride_share
create database ride_share;

USE ride_share;

SELECT *
FROM ride_sharing_data
LIMIT 20;

SELECT COUNT(*) 
FROM ride_sharing_data;

-- Counting the total number of rides that were, completed, canceled and those whose data doesn't show.
SELECT
    Ride_Status,
    COUNT(*) AS Number_of_Trips
FROM ride_sharing_data
WHERE Ride_Status IN ('Completed', 'Canceled', 'No-show')
GROUP BY Ride_Status
ORDER BY Number_of_Trips DESC;

-- Total rides and revenue by vehicle type:
SELECT Vehicle_Type, COUNT(*) AS total_rides, SUM(Fare_Amount) AS total_revenue
FROM ride_sharing_data
WHERE Ride_Status = 'Completed'
GROUP BY Vehicle_Type;

-- Top pickup-dropoff combinations:
SELECT Pickup_Location, Dropoff_Location, COUNT(*) AS ride_count
FROM ride_sharing_data
GROUP BY Pickup_Location, Dropoff_Location
ORDER BY ride_count DESC
LIMIT 10;

-- User type behavior analysis:
SELECT User_Type, COUNT(*) AS total_rides, AVG(User_Rating) AS avg_rating, AVG(Fare_Amount) AS avg_fare
FROM ride_sharing_data
GROUP BY User_Type;

-- Impact of traffic and weather on ride duration:
SELECT Traffic_Level, Weather_Condition, AVG(Ride_Duration_min) AS avg_duration
FROM ride_sharing_data
GROUP BY Traffic_Level, Weather_Condition;

-- I need to convert my Ride_DateTime column to a proper DATETIME data type. The best tool for this is the STR_TO_DATE() function. This function parses a text string based on a format you specify and turns it into a real date/time value
-- Add a new column with the correct DATETIME type:
ALTER TABLE ride_sharing_data
ADD COLUMN ride_time DATETIME;

-- Update the new column by converting the text from the old column:
UPDATE ride_sharing_data
SET ride_time = STR_TO_DATE(Ride_DateTime, '%d-%m-%y %H:%i');

 -- Drop the old text column:
 ALTER TABLE ride_sharing_data
DROP COLUMN Ride_DateTime;

-- Rename the new column to the original name:
ALTER TABLE ride_sharing_data
CHANGE COLUMN ride_time Ride_DateTime DATETIME;

-- This query identifies rush hours by grouping times of day and analyzing ride volume and price.
SELECT
    CASE
        WHEN HOUR(ride_time) BETWEEN 6 AND 9 THEN '1. Morning Rush'    -- Covers 06:00:00 to 09:59:59
        WHEN HOUR(ride_time) BETWEEN 10 AND 16 THEN '2. Mid-Day'       -- Covers 10:00:00 to 16:59:59
        WHEN HOUR(ride_time) BETWEEN 17 AND 19 THEN '3. Evening Rush'  -- Covers 17:00:00 to 19:59:59
        ELSE '4. Night'                                               -- Covers all other hours (00-05 and 20-23)
    END AS time_segment,
    COUNT(User_ID) AS number_of_trips,
    AVG(Fare_Amount) AS average_price,
    AVG(Distance_km) AS average_distance
FROM
    ride_sharing_data
WHERE
     Ride_Status = 'Completed'
GROUP BY
    time_segment
ORDER BY
    time_segment;

DESCRIBE ride_sharing_data;
