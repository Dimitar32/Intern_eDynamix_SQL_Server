--1.Create a query to list out the following columns from the tblEventtable, with the mostrecent first: eventname, eventdate
select eventname, eventdate
from dbo.tblEvent
order by eventdate desc

--2.Create a query to list out the id number and name of the last 3 categories from the tblCategory table in alphabetical order:
select top(3) categoryid, categoryname
from dbo.tblCategory
order by categoryname desc

--3.Write a query to showthe first 5 events (in date order) from the tblEvent table:
select top(5) eventName, EventDetails
from dbo.tblEvent
order by eventdate asc

--4.Create a query which uses two separate SELECT statements to showthe first and last 2 events in date order from the tblEvent table.
select top(2)eventname, eventdate
from dbo.tblEvent
order by eventdate desc

select top(2)eventname, eventdate
from dbo.tblEvent
order by eventdate asc

--5.In the tblCategory table, category number 11 is Love and Relationships. Write a queryto list out all of the events from the tblEventtable in category number 11
select*
from dbo.tblEvent
where CategoryID = 11

--6
select*
from dbo.tblEvent
where (CategoryID = 4 or EventDetails like N'% Water %' or 
	CountryID = 8 or countryid = 22 or countryid = 30 or countryid = 35) and eventdate >= '19700101'

--7. Create a query which lists out all of the events which took place in February 2005:
select*
from dbo.tblEvent
where year(eventdate) = 2005 and month(eventdate) = 2
--where eventdate >= '20050201' and eventdate < '20050301'

--8
--Events which aren't in the Transport category (number 14), but which nevertheless include the word Train in the EventDetails column. 
select*from dbo.tblEvent
where CategoryID != 14 and eventdetails like N'%Train%'

--Events which are in the Space country (number 13), but which don't mention Space in either the event name or the event details columns.
select*
from dbo.tblEvent
where CountryID = 13 and (eventname not like N'%Space%' and EventDetails not like N'%Space%')

--Events which are in categories 5 or 6 (War/conflict and Death/disaster), but which don't mention either War or Death in the EventDetails column.
select*
from dbo.tblEvent
where (CategoryID = 5 or CategoryID = 6) and eventdetails not like N'%War%' and EventDetails not like N'%Death%'

--9.Name includes Teletubbies or Name includes Pandy.
select *
from dbo.tblEvent
where EventDetails like N'%Teletubbies%' or EventDetails like N'%Pandy%'

--10.Create a query listing out each event with the length of its name, with the "shortest event" first
select eventname, len(eventname) nameLength
from dbo.tblEvent
order by nameLength asc

--11.Apply WHERE criteria to show only those events in country number 1 (Ukraine).
select CONCAT(eventname, ' (Category', CategoryID, ')') 'Event(Category)', eventdate
from dbo.tblEvent
where countryid = 1

--12.The aim of this exercise is to find this and that in the EventDetails column (in that order). Yourfinal query should showthis:
select eventname, EventDate, 
		CHARINDEX('this', EventDetails) thisPosition, 
		CHARINDEX('that', EventDetails) thatPosition, 
		(CHARINDEX('that', EventDetails) - CHARINDEX('this', EventDetails)) Offset    
from dbo.tblEvent
where EventDetails like N'%this%that%'

--13.
select*, isnull(Summary, 'No summary') 'Using ISNULL', 
		 coalesce(Summary, 'No summary') as 'Using COALESCE', 
		(case when Summary is null then 'No summary' else Summary end) 'Using CASE'
from dbo.tblContinent