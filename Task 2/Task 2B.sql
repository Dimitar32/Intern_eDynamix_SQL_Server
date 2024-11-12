--Sum of the integers in the date 
DECLARE @s VARCHAR(20) = CONVERT(VARCHAR(20), GETDATE(), 112)
DECLARE @sum INT = 0
DECLARE @i INT = 1

WHILE @i <= 8
BEGIN
	SET @sum = @sum + CONVERT(INT, SUBSTRING(@s, @i, 1))
	SET @i = @i + 1
END

SELECT @sum

--Reversed name of the day, capital letters only
SELECT UPPER(REVERSE(DATENAME(DW,GETDATE()))) reveresedToday

--Data length of the name of the day. Character count of the name of the day
DECLARE @weekDayName VARCHAR(20) = DATENAME(DW,GETDATE())
SELECT DATALENGTH(@weekDayName) dataLen, LEN(@weekDayName) charCount

--Is the day even or odd number
SELECT (CASE WHEN day(getdate()) % 2 = 0 THEN 'even' ELSE 'odd' END) evenOrOddDay

--How much days have you been in eDynamix and remaining days until the end of your internship
SELECT DATEDIFF(DAY, '20230717', GETDATE()) daysInEDynamix, DATEDIFF(DAY, GETDATE(), '20231017') endOfInternship

--Return random letter of the day`s name each run
DECLARE @weekDayName1 VARCHAR(20) = DATENAME(DW,GETDATE())
SELECT substring(@weekDayName1, cast(round(rand()*len(@weekDayName1),0) as int), 1)

--Divide the year by the day and return a result with 2 places after the decimal point. Round the number to nearest integer.
declare @n decimal(10, 2) = year(getdate())/(day(getdate())*1.00)
select round(@n, 0), @n

go
--Return the first and last word from the EventName in separate columns. If there is only one word in the column, add 'Single word' to the string.
create function splitNameLastElement(@name varchar(50))
	returns varchar(50) as
	begin
		if LEN(@name) - LEN(REPLACE(@name, ' ', '')) + 1 = 1
			return @name + 'Single word'
		return(select top(1)reverse(value)
				from string_split(reverse(@name),' '))
	end
go

create function splitNameFirstElement(@name varchar(50))
	returns varchar(50) as
	begin
		if LEN(@name) - LEN(REPLACE(@name, ' ', '')) + 1 = 1
			return @name + 'Single word'
		return(select top(1)value
				from string_split(@name,' '))
	end
go

select dbo.splitNameFirstElement(eventName) firstElement, dbo.splitNameLastElement(eventName) lastElement
from dbo.tblEvent


--Duplicate the word 'the' from the EventDetails column in dbo.tblEvent
select replace(eventdetails, 'the', 'thethe')
from dbo.tblEvent

