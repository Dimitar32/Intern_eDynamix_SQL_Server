--2. insert employee
create procedure dbo.s_ins_emp(@emp_nam varchar(50), @emp_ttl varchar(50), @man_id int, @tsk_id int)
as
begin
	declare @emp_sts varchar(50) = (case when @tsk_id is null then 'free' else 'busy' end)
	declare @dep_id varchar(50)
	select @dep_id = dep_id from dbo.t_man where man_id = @man_id

	insert into dbo.t_emp(emp_nam, emp_sts, emp_ttl, man_id, tsk_id, dep_id)
	values(@emp_nam, @emp_sts, @emp_ttl, @man_id, @tsk_id, @dep_id);
end
go

--3. insert task
create procedure s_ins_tsk(@p_dep_nam varchar(50), @dep_loc varchar(50), @tsk_dsc varchar(50)) 
as
begin
	declare @dep_id int = (select dep_id from dbo.t_dep where dep_nam = @dep_nam and dep_loc = @dep_loc)
	insert into dbo.t_tsk(tsk_dsc, tim_sts, dep_id) 
	values(@tsk_dsc, '0 days', @dep_id)
end
go

exec dbo.s_ins_tsk @dep_nam = 'Service Plan', @dep_loc = 'office stz', @tsk_dsc = 'implement new features'