-- DISCLAIMER:
-- This analysis is conducted solely for educational and SQL practice purposes. The data used is fictional or
-- anonymized and does not represent any real company, organization, or individual. Any insights or
-- interpretations derived from this analysis are intended for learning and demonstration only.

USE uberdata;

CREATE TABLE ubertable (
	`Date` DATE NOT NULL,
	`Time` TIME NOT NULL,
	`bookingId` VARCHAR(20) NOT NULL,
	`bookingStatus` VARCHAR(50) NOT NULL,
	`customerId` VARCHAR(20) NOT NULL,
	`vehicleType` VARCHAR(20) NOT NULL,
	`pickupLocation` VARCHAR(20) NOT NULL,
	`dropLocation` VARCHAR(20) NOT NULL,
	`cancelledRidesByCustomer` INT NOT NULL,
	`reasonForCancellingByCustomer` VARCHAR(20) NOT NULL,
	`cancelledRidesByDriver` INT NOT NULL,
	`driverCancellationReason` VARCHAR(50) NOT NULL,
	`incompleteRides` INT NOT NULL,
	`incompleteRidesReason` VARCHAR(50) NOT NULL,
	`bookingValue` INT NOT NULL,
	`rideDistance` DECIMAL (4,2) NOT NULL,
	`driverRatings` DECIMAL (2,1) NOT NULL,
	`customerRating` DECIMAL (2,1) NOT NULL,
	`paymentMethod` VARCHAR(20) NOT NULL,
	PRIMARY KEY (`bookingId`)
);

-- DISCLAIMER:
-- This analysis is conducted solely for educational and SQL practice purposes. The data used is fictional or
-- anonymized and does not represent any real company, organization, or individual. Any insights or
-- interpretations derived from this analysis are intended for learning and demonstration only.

-- REVENUE AND BOOKING PERFORMANCE ANALYSIS
-- 1. What is the total booking revenue by month?

SELECT
	MONTH(date) AS monthNum,
    YEAR(date) AS year_,
    MONTHNAME(date) AS monthName,
    SUM(bookingValue) AS totalBookingRevenue
FROM ubertable
GROUP BY
	monthNum,
    year_,
    monthName
ORDER BY monthNum;

-- 2. Which vehicle types generate the highest revenue?

SELECT
	vehicleType,
    SUM(bookingValue) AS totalBookingRevenue
FROM ubertable
GROUP BY vehicleType
ORDER BY totalBookingRevenue DESC;

-- 3. What are the peak booking hours?

SELECT
    HOUR(Time) AS bookingHour,
    COUNT(bookingId) AS totalBookings
FROM ubertable
GROUP BY bookingHour
ORDER BY totalBookings DESC;

-- 4. Which days have the highest ride demand?

SELECT
	DAYNAME(date) AS dayName,
    COUNT(bookingId) AS totalBookings
FROM ubertable
GROUP BY dayName
ORDER BY totalBookings DESC;

-- 5. What is the average booking value per ride?

SELECT
	ROUND(AVG(bookingValue),2) AS avgBookingValue
FROM ubertable;

-- CANCELLATION ANALYSIS
-- 6. What is the overall cancellation rate?

SELECT
    SUM(CASE WHEN bookingStatus LIKE 'Cancelled%' THEN 1 ELSE 0 END) AS totalCancelledRides,
    COUNT(*) AS total_bookings,
    ROUND((SUM(CASE WHEN bookingStatus LIKE 'Cancelled%' THEN 1.0 ELSE 0.0 END) / NULLIF(COUNT(*), 0)) * 100.0,2
    ) AS cancellationRatePercentage
FROM uberTable;

-- 7. Which pickup locations have the highest cancellation rates?

SELECT
	pickupLocation,
    SUM(CASE WHEN bookingStatus LIKE 'Cancelled%' THEN 1 ELSE 0 END) AS totalCancelledRides
FROM uberTable
GROUP BY pickupLocation
ORDER BY totalCancelledRides DESC
LIMIT 5;

-- 8. What are the top reasons customers cancel rides?

SELECT
	reasonForCancellingByCustomer,
    SUM(CASE WHEN bookingStatus LIKE 'Cancelled%' THEN 1 ELSE 0 END) AS totalCancelledRides
FROM uberTable
GROUP BY reasonForCancellingByCustomer
ORDER BY totalCancelledRides DESC;

-- 9. What are the top reasons drivers cancel rides?

SELECT
	driverCancellationReason,
    SUM(CASE WHEN bookingStatus LIKE 'Cancelled%' THEN 1 ELSE 0 END) AS totalCancelledRides
FROM ubertable
GROUP BY driverCancellationReason
ORDER BY totalCancelledRides DESC;


-- 10. Which vehicle types experience the most cancellations?

SELECT
	vehicleType,
    SUM(CASE WHEN bookingStatus LIKE 'Cancelled%' THEN 1 ELSE 0 END) AS totalCancelledRides
FROM ubertable
GROUP BY vehicleType
ORDER BY totalCancelledRides DESC;

-- DRIVER PERFORMANCE ANALYSIS
-- 11. Which drivers/vehicle types receive the highest ratings?'

SELECT
	vehicleType,
    ROUND(AVG(driverRatings),2) AS totalRatings
FROM ubertable
GROUP BY vehicleType
ORDER BY totalRatings DESC;
 
-- 12. How do driver ratings affect booking completion?

SELECT
    driverRatings,
    COUNT(bookingId) AS totalBookings,
    COUNT(CASE
            WHEN bookingStatus = 'Completed'
            THEN 1
        END) AS completed_rides,
    ROUND((COUNT(CASE
                    WHEN bookingStatus = 'Completed'
                    THEN 1
                END) * 100.0) / COUNT(*),2
    ) AS completion_rate_percentage
FROM uberTable
GROUP BY driverRatings
ORDER BY driverRatings DESC;

-- 13. Which pickup locations have the best-rated drivers?

SELECT
    pickupLocation,
    ROUND(AVG(driverRatings),2) AS averageDriverRating,
    COUNT(bookingId) AS totalBookings
FROM uberTable
GROUP BY pickupLocation
ORDER BY averageDriverRating DESC;

-- 14. What is the average ride distance by vehicle type?

SELECT
	vehicleType,
    ROUND(AVG(rideDistance),2) AS avgDistance
FROM uberTable
GROUP BY vehicleType
ORDER BY avgDistance DESC;

-- CUSTOMER BEHAVIOR ANALYSIS
-- 15. Which payment methods are most frequently used?

SELECT
	paymentMethod,
	COUNT(*) AS totalPaymentMethodUsed
FROM uberTable
GROUP BY paymentMethod
ORDER BY totalPaymentMethodUsed DESC;

-- 16. What percentage of rides are incomplete?

SELECT
    SUM(incompleteRides) AS totalIncompleteRides,
    COUNT(*) AS totalBookings,
    ROUND((SUM(incompleteRides) * 100.0) / COUNT(*),2) AS incompleteRidePercentage
FROM uberTable;

-- 17. What are the main reasons for incomplete rides?

SELECT
    incompleteRidesReason,
    COUNT(*) AS totalIncompleteCases,
    ROUND((COUNT(*) * 100.0) / (
            SELECT COUNT(*)
            FROM uberTable
            WHERE incompleteRides = 1),2) AS percentageOfIncompleteRides
FROM uberTable
WHERE incompleteRides = 1
GROUP BY incompleteRidesReason
ORDER BY totalIncompleteCases DESC;

-- 18. Which pickup/drop locations experience the most incomplete rides?

SELECT
    pickupLocation,
    dropLocation,
    COUNT(*) AS totalIncompleteRides,
    ROUND((COUNT(*) * 100.0) / (
            SELECT COUNT(*)
            FROM uberTable
            WHERE incompleteRides = 1
        ),2) AS percentageOfIncompleteRides
FROM uberTable
WHERE incompleteRides = 1
GROUP BY 
	pickupLocation, 
    dropLocation
ORDER BY totalIncompleteRides DESC;

-- 19. Which hours experience the highest incomplete ride frequency?

SELECT
    HOUR(Time) AS bookingHour,
    COUNT(*) AS totalIncompleteRides,
    ROUND((COUNT(*) * 100.0) / (
            SELECT COUNT(*)
            FROM uberTable
            WHERE incompleteRides = 1),2) AS percentageOfIncompleteRides
FROM uberTable
WHERE incompleteRides = 1
GROUP BY bookingHour
ORDER BY totalIncompleteRides DESC;

-- 20. Which pickup locations generate the most revenue?

SELECT
	pickupLocation,
	SUM(bookingValue) AS totalRevenue
FROM uberTable
GROUP BY pickupLocation
ORDER BY totalRevenue DESC;


-- 21. Which routes generate the highest booking value?

SELECT
	pickupLocation,
    COUNT(*) AS numberOfTraveled
FROM ubertable
GROUP BY pickupLocation
ORDER BY numberOfTraveled DESC LIMIT 5;

-- 22. Which areas have the longest average ride distance?

SELECT
	pickupLocation,
    dropLocation,
    rideDistance
FROM ubertable
GROUP BY 
	pickupLocation,
    dropLocation,
    rideDistance
ORDER BY rideDistance DESC;

-- 23. How do bookings change over time?

SELECT
    YEAR(Date) AS bookingYear,
    MONTH(Date) AS bookingMonth,
    COUNT(*) AS totalBookings
FROM uberTable
GROUP BY
    YEAR(Date),
    MONTH(Date)
ORDER BY
    bookingYear,
    bookingMonth;
    
-- 24. What is the trend of cancellation rates over time?

SELECT
    YEAR(`Date`) AS bookingyear,
    MONTH(`Date`) AS bookingmonth,
    COUNT(*) AS totalbookings,
    SUM(CASE WHEN bookingStatus IN ('Cancelled by Customer', 'Cancelled by Driver') 
        THEN 1 ELSE 0 END) AS cancelledRides,
    ROUND((SUM(CASE WHEN bookingStatus IN ('Cancelled by Customer', 'Cancelled by Driver') 
            THEN 1.0 ELSE 0.0 END) * 100.0) / NULLIF(COUNT(*), 0), 2) AS cancellationRate
FROM uberTable
GROUP BY
    YEAR(`Date`),
    MONTH(`Date`)
ORDER BY
    bookingYear,
    bookingMonth;

-- DISCLAIMER:
-- This analysis is conducted solely for educational and SQL practice purposes. The data used is fictional or
-- anonymized and does not represent any real company, organization, or individual. Any insights or
-- interpretations derived from this analysis are intended for learning and demonstration only.



SELECT 
*
FROM ubertable


