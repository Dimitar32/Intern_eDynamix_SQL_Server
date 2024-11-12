--Today s date and the name of the day
SELECT GETDATE() todayDate, DATENAME(DW,GETDATE()) today

--Each number of the date in a separate column
DECLARE @s VARCHAR(20) = CONVERT(VARCHAR(20), GETDATE(), 112)
SELECT SUBSTRING(@s, 1, 1) year1,
		SUBSTRING(@s, 2, 1) year2,
		SUBSTRING(@s, 3, 1) year3,
		SUBSTRING(@s, 4, 1) year4,
		SUBSTRING(@s, 5, 1) month1,
		SUBSTRING(@s, 6, 1) month2,
		SUBSTRING(@s, 7, 1) day1,
		SUBSTRING(@s, 8, 1) day2

--The remaining number of days until End of the year
SELECT DATEDIFF(DAY, GETDATE(), DATEFROMPARTS(YEAR(GETDATE()), 12, 31)) dayToTheEndOfTheYear

--Is the year leap
SELECT (CASE WHEN YEAR(GETDATE()) % 4 = 0 THEN 'Yes' ELSE 'No' END) isLeapYear

--The number of days since the SQL was found :) (the default date)
declare @date smalldatetime = ''
select @date
SELECT DATEDIFF(DAY,CONVERT(DATETIME, 0), GETDATE()) numOfDays

--Return the average day value from the EventDate column in dbo.tblEvent. Also return the total amount of all days.
SELECT AVG(DAY(EventDate)) avgdDayValue,  sum(day(eventdate)) totalDays
FROM dbo.tblEvent

--Rerturn the number of days occuring more than 10 times.
SELECT COUNT(*) 
FROM (
	SELECT COUNT(DAY(e.eventdate)) countDays, DAY(e.EventDate) daysNum
	FROM dbo.tblEvent e
	GROUP BY DAY(e.eventdate)
	HAVING COUNT(DAY(e.eventdate)) > 10) a

--Change the date from the current one to the US standard (EventDate in dbo.tblEvent)
SELECT CONVERT(VARCHAR(10), eventDate, 101) dateUsStandart
FROM dbo.tblEvent

--Find the rows including numbers in the EventName colum. If there is no number in a row, return 'N/A'.
SELECT (CASE WHEN eventname like N'%[0-9]%' THEN eventname ELSE 'N/A' END) numRows
FROM dbo.tblEvent
select*from dbo.tblEvent

--Split a single row from the EventName column in tblEvent, into as many rows as words are in the string.
SELECT *
FROM STRING_SPLIT((
	SELECT eventname
	FROM dbo.tblEvent
	WHERE LEN(eventname) = (SELECT TOP(1)LEN(e.eventname)
							FROM dbo.tblEvent e
							ORDER BY LEN(e.eventname) DESC)
), ' ')

--Join all the columns from a single row in dbo.tblEvent, into a single cell, using '-' as a separator.
SELECT FORMAT(eventid, '##') + ' - ' + 
	   eventname + ' - ' + 
	   eventdetails + ' - ' + 
	   FORMAT(eventdate, 'dd-mm-yyyy') + ' - ' +
	   FORMAT(countryid, '##') + ' - ' +
	   FORMAT(Categoryid, '##') + ' - '
FROM dbo.tblEvent





	

		