--4.free emp in department
create function f_fre_emp(@dep_nam varchar(50))
	returns table 
	as 
	return(select e.emp_id, e.emp_nam , d.dep_loc , d.dep_nam
			from dbo.t_emp e
			join dbo.t_dep d on e.dep_id = d.dep_id
			where d.dep_nam = @dep_nam and e.emp_sts = 'free')
go

select*
from dbo.f_fre_emp('Service Plan')
go

--5.view all employees
create view v_all_for_emp 
as 
	(select e.emp_id, e.emp_nam, e.emp_ttl, 
			m.man_nam, d.dep_nam, e.emp_sts
	 from dbo.t_emp e
	 join dbo.t_man m on e.man_id = m.man_id
	 join dbo.t_dep d on m.dep_id = d.dep_id
	/* union all
	 select m.man_id ID, m.man_nam, ('manager'),
			('Nothing'), d.dep_nam, (case when tsk_id is null then 'free' else 'busy' end)
	 from dbo.t_man m
	 join dbo.t_dep d on m.dep_id = d.dep_id*/)
go

select *
from dbo.v_all_for_emp
go

--6.procedure give task to free employee
create procedure s_tsk_fre_emp(@tsk_id int, @loc varchar(50), @dep_nam varchar(50))
as
begin
	if @dep_nam not in (select dep_nam from dbo.t_dep)
		print 'There is no department with this name'
	else
	begin
		declare @emp_id int = (select top(1) emp_id
								from dbo.f_fre_emp(@dep_nam)
								where dep_loc = @loc)
		declare @man_id int = (select top(1)man_id
								from dbo.t_man
								where tsk_id = @tsk_id)
		declare @sts varchar(50) = (select sts from dbo.t_tsk where tsk_id = @tsk_id)
		if @sts = 'outstanding'
			update dbo.t_tsk
			set sts = 'in progress'
			where tsk_id = @tsk_id
		if @emp_id is not null
		begin
			declare @dep_id int = (select dep_id from dbo.t_dep where dep_nam = @dep_nam)
			update dbo.t_emp
			set tsk_id = @tsk_id, man_id = @man_id, emp_sts = 'busy', dep_id = @dep_id
			where emp_id = @emp_id

			update dbo.t_tsk
			set num_emp = num_emp + 1
			where tsk_id = @tsk_id
		end
		if @emp_id is null
			print 'no free employees'
	end
end
go

exec s_tsk_fre_emp @tsk_id = 8, @loc = 'office stz', @dep_nam = 'Support'
go

--7.procedure change status and num employees
create procedure s_chg_tsk_sts_num_emp(@tsk_id int, @new_tsk_sts varchar(50), @new_num_emp varchar(50))
as
begin
	declare @old_num_emp int = (select num_emp				--old num of emp who work on that task
								from dbo.t_tsk
								where tsk_id = @tsk_id)
	if @old_num_emp > @new_num_emp							--if old num bigger than new update t_emp,
	begin													--set emp who work on that task to free and 
		declare @n int = @old_num_emp - @new_num_emp
		while @n > 0
		begin
			declare @emp_id int = (select top(1) emp_id
									from dbo.t_emp
									where tsk_id = @tsk_id)
			if @emp_id is not null
			begin
				update dbo.t_emp
				set emp_sts = 'free', tsk_id = null
				where emp_id = @emp_id
			end
			else
				break

			set @n = @n - 1
		end
		update dbo.t_tsk
		set num_emp = @new_num_emp
		where tsk_id = @tsk_id
	end
	if @old_num_emp < @new_num_emp
	begin
		declare @n1 int = @new_num_emp - @old_num_emp
		while @n1 > 0
		begin
			declare @dep_nam varchar(50) = (select d.dep_nam from dbo.t_dep d
											join dbo.t_tsk t on d.dep_id = t.dep_id
											where t.tsk_id = @tsk_id) 
			declare @dep_loc varchar(50) = (select d.dep_loc from dbo.t_dep d
											join dbo.t_tsk t on d.dep_id = t.dep_id
											where t.tsk_id = @tsk_id)
			exec dbo.s_tsk_fre_emp @tsk_id = @tsk_id, @loc = @dep_loc, @dep_nam = @dep_nam
			set @n1 = @n1 - 1
		end
	end
	
	update dbo.t_tsk
	set sts = @new_tsk_sts
	where tsk_id = @tsk_id
end
go

exec s_chg_tsk_sts_num_emp @tsk_id = 5, @new_tsk_sts = 'in progress2', @new_num_emp = 0
go

--8.
create procedure s_tsk_sts(@tsk_id int)
as
begin
	select c.tsk_id, c.old_sts, datediff(hour, lag(c.cng_dat)over(order by c.cng_id),  c.cng_dat) diff_hor, 
			d.dep_nam, (select m.man_nam from dbo.t_man m where m.tsk_id = c.tsk_id) man_nam
	from dbo.t_cng_tsk_sts c
	join dbo.t_tsk t on c.tsk_id = t.tsk_id
	join dbo.t_dep d on t.dep_id = d.dep_id
	where c.tsk_id = @tsk_id
end

exec s_tsk_sts @tsk_id = 3
go

--9.
create procedure s_fin_tsk_one_day
as
begin
	while exists (select tsk_id from dbo.t_cng_tsk_sts where datediff(day, cng_dat, GETDATE()) > 1 and tsk_id is not null)
	begin
		declare @tsk_id int = (select top(1)tsk_id 
								from dbo.t_cng_tsk_sts
								where new_sts = 'complete' and datediff(day, cng_dat, GETDATE()) > 1)
		delete from dbo.t_cng_tsk_sts
		where tsk_id = @tsk_id
		if @tsk_id is not null
		begin
			delete from dbo.t_tsk
			where tsk_id = @tsk_id
		end
	end
end
go

exec dbo.s_fin_tsk_one_day

exec s_ins_tsk @dep_nam = 'Support', @dep_loc = 'office stz'

insert into dbo.t_cng_tsk_sts (old_sts, new_sts, cng_dat, tsk_id)
values('in progress', 'complete', '20230805', 14)

select*from dbo.t_emp
