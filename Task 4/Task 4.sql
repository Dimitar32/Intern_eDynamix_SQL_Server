--1
select *
from tblEventCopy
where CountryID = 7

go
create trigger dontDelete
on dbo.tblEventCopy
for delete as
	declare @countryid int
	declare @eventid int
	select @countryid = countryid from deleted
	select @eventid = eventid from deleted

	if @countryid <> 7
		print'deleted'
	if @countryid = 7
	begin
		print'dont delete uk'
		rollback
	end

delete from dbo.tblEventCopy
where countryid = 7

--2
declare @listEvents varchar(500) = ''
SELECT @listEvents = @listEvents + quotename(eventname, '"') + ', '
FROM dbo.tblEvent
where YEAR(eventdate) >= 2000 and year(eventdate) < 2011

select left(@listEvents, len(@listEvents) - 1) 'list of events'

select*
from dbo.tblEvent
where CHARINDEX(EventName, @listEvents) != 0
go

--3
create view m1 as(
	select e.EventName, e.EventDate, c.CategoryName, cn.CountryName, e.EventDetails
	from dbo.tblEvent e
	join dbo.tblCategory c on e.CategoryID = c.CategoryID
	join dbo.tblCountry cn on e.CountryID = cn.CountryID
)
go
select*from m1
go
--3.1 Get a list of those events which contain none of the letters in the word?OWL 
create view s1 as(
	select EventName, EventDate, CategoryName, CountryName
	from m1
	where EventName not like '%[owl]%' and EventDetails not like '%[owl]%' 
)
go
select * from s1
go

--3.2 Use this to get a list of all of those events which take place in the countries for the events in list 1. 
create view s2 as(
	select*
	from m1
	where CountryName in(
		select distinct countryname
		from s1)
) 
go
select * from s2
go

--3.3 Get a third list of all of the events which share the same categories as any of the events in the second list. 
create view s3 as(	
	select *
	from m1
	where CategoryName in(
		select distinct CategoryName
		from s2)
)
go
select * from s3
go

--4
with sc1(countryname, categoryname) as(
	select distinct cn.countryname, c.categoryname
	from dbo.tblEvent e
	join dbo.tblCountry cn on e.CountryID = cn.CountryID
	join dbo.tblCategory c on e.CategoryID = c.CategoryID
	where cn.CountryName = 'Space'),
nsc1(countryname, categoryname) as(
	select cn.countryname, c.categoryname
	from dbo.tblEvent e
	join dbo.tblCountry cn on e.CountryID = cn.CountryID
	join dbo.tblCategory c on e.CategoryID = c.CategoryID
	where cn.CountryName != 'Space'
)

select distinct nsc1.CountryName
from sc1
join nsc1 on sc1.CategoryName = nsc1.CategoryName

--5
with topCountries(countryID) as(
	select top(3) c.CountryID
	from dbo.tblEvent e
	join dbo.tblCountry c on e.CountryID = c.CountryID
	group by c.CountryID
	order by count(eventname) desc
), topCategories(categoryID) as(
	select top(3) c.CategoryID
	from dbo.tblEvent e
	join dbo.tblCategory c on e.CategoryID = c.CategoryID
	group by c.CategoryID
	order by count(eventname) desc
), tc as(
select *
from topCountries
cross join topCategories)
--select *from tc

select c.countryname, cn.categoryname, count(e.eventid) numEvents
from dbo.tblEvent e
join dbo.tblCountry c on e.CountryID = c.CountryID
join dbo.tblCategory cn on e.CategoryID = cn.CategoryID
where c.countryid in (select tc.countryid
						from tc
						where tc.categoryid = cn.categoryid)
group by c.CountryName, cn.CategoryName
order by numEvents desc
go

--6
create function winner(@eventn varchar(50))
	returns varchar(50) as
	begin
		declare @date date = (select EventDate
									from dbo.tblEvent
									where EventName = @eventn)
		if @date = (select max(eventdate)
					from dbo.tblEvent)
			return 'Newest'
		if @date = (select min(eventdate)
					from dbo.tblEvent)
			return 'Oldest'
		if @eventn = (select top(1) eventname
						from dbo.tblEvent
						order by eventname desc)
			return 'Last alphabetically'
		if @eventn = (select top(1) eventname
						from dbo.tblEvent
						order by eventname asc)
			return 'First alphabetically'
		return 'Not a winner'
	end
go
select eventname, dbo.winner(eventname) winners
from dbo.tblEvent
order by winners
go

--7
create function monthEvents(@i int)
	returns varchar(500) as
	begin
		declare @str varchar(500) = ''
		set @str = @str + 'Events which occurred in ' + (case @i when 1 then 'January: '
																 when 2 then 'February: '
																 when 3 then 'March: '
																 when 4 then 'April: '
																 when 5 then 'May: '
																 when 6 then 'June: '
																 when 7 then 'July: '
																 when 8 then 'August: '
																 when 9 then 'September: '
																 when 10 then 'October: '
																 when 11 then 'November: '
																 when 12 then 'December: '
																 else '' end)
		
		SELECT @str = COALESCE(@str + ',', '') + eventname
		FROM dbo.tblEvent
		WHERE MONTH(EventDate) = @i
		return @str
	end
go

declare @i int = 1
while @i <= 12
	begin
		declare @result varchar(500) = '' + dbo.monthEvents(@i)
		select @result
		set @i = @i + 1
	end
go

--8
create procedure firstEventContinent(@cn varchar(50) output)
as
	select @cn = cn.continentname
	from dbo.tblEvent e
	join dbo.tblCountry c on e.CountryID = c.CountryID
	join dbo.tblContinent cn on c.ContinentID = cn.ContinentID
	where e.EventDate = (select min(e1.eventdate)
						from dbo.tblEvent e1)
go

create procedure eventInContinent(@continent varchar(50))
as
	select e.EventName, e.EventDate, cn.ContinentName
	from dbo.tblEvent e
	join dbo.tblCountry c on e.CountryID = c.CountryID
	join dbo.tblContinent cn on c.ContinentID = cn.ContinentID
	where cn.ContinentName = @continent
go

declare @contname varchar(50)
exec dbo.firstEventContinent @contname out
exec dbo.eventInContinent @continent = @contname

--9
go
create procedure mostEvents(@topCountry varchar(50) output, @eventCountry int output)
as
begin
	select top(1) @topCountry = cn.countryName,
				  @eventCountry = count(e.eventname)
	from dbo.tblEvent e
	join dbo.tblCountry cn on e.CountryID = cn.CountryID
	group by cn.CountryName
	order by count(e.eventname) desc
end
go

declare @topCountry varchar(50), @eventCountry int
exec dbo.mostEvents @topCountry out, @eventCountry out
select @topCountry CountryName, @eventCountry NumEvents