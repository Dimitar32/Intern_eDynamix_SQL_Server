create trigger updateNumEmpOnInsert									--update num of emp who work on task
on dbo.t_emp														--when insert new emp
after insert as
	declare @tsk_id int = (select tsk_id from inserted)
	declare @man_id int = (select man_id from inserted)
	declare @dep_id int = (select dep_id from inserted)
	declare @sts varchar(50) = (select emp_sts from inserted)

	if @tsk_id is null and @sts <> 'free'
	begin
		update dbo.t_emp 
		set emp_sts = 'free'
		where emp_id = (select emp_id from inserted)
	end

	if @tsk_id is not null and @sts <> 'busy'
	begin
		update dbo.t_emp
		set emp_sts = 'busy'
		where emp_id = (select emp_id from inserted)
	end

	if @dep_id not in (select dep_id from dbo.t_dep) or 
		@man_id not in (select man_id from dbo.t_man where dep_id = @dep_id) or
		@tsk_id not in (select tsk_id from dbo.t_tsk where dep_id = @dep_id)
		begin 
			print 'unreal infromation'
			rollback
		end

	if @tsk_id is not null and 
		@man_id not in (select man_id from dbo.t_man where tsk_id = @tsk_id) --check if there is a manager with
		begin																 --task like that if not rollback
			print 'unreal information - from trigger'
			rollback
		end
	else
		begin
			update dbo.t_tsk 
			set num_emp = num_emp + 1
			where tsk_id = @tsk_id
		end

insert into dbo.t_emp(emp_nam, emp_sts, emp_ttl, man_id, tsk_id, dep_id)
values('mitio', 'free', 'umnik', 4, 7, 5)

exec s_ins_emp @emp_nam = 'Marian Dimitrov', @emp_ttl = 'mutra', @man_id = 4, @tsk_id = null
go

create trigger updateNumEmpOnDelete					--update num of emp who work on task when delete emp
on dbo.t_emp
after delete as
	declare @tsk_id int = (select e.tsk_id from deleted e)
	update dbo.t_tsk 
	set num_emp = num_emp - 1
	where tsk_id = @tsk_id

exec s_del_emp @emp_id = 40
go

create trigger insertManagerCheck					--check when insert new manager if there are same dep and tsk id's
on dbo.t_man
after insert as
	declare @dep_id int = (select dep_id from inserted)
	declare @tsk_id int = (select tsk_id from inserted)
	declare @dep_id1 int = (select dep_id from dbo.t_tsk where tsk_id = @tsk_id)
	if (select count(*) from dbo.t_man where tsk_id = @tsk_id) > 1
	begin
		print 'that task have manager'
		rollback;
	end
	if @dep_id <> @dep_id1
	begin
		print 'neverni danni'
		rollback;
	end
go

create trigger updateStatusTask							--7.add status updates to changes table(t_cng_tsk_sts)
on dbo.t_tsk
after update as
begin
	declare @old_sts varchar(50) = (select sts from deleted)
	declare @new_sts varchar(50) = (select sts from inserted)
	declare @tsk_id int = (select tsk_id from inserted)
	declare @num_emp int = (select num_emp from inserted)
	if @num_emp = 0 and @new_sts <> 'complete'
	begin
		update dbo.t_tsk
		set sts = 'hold'
		where tsk_id = @tsk_id
	end
	if @old_sts <> @new_sts
	begin
		insert into dbo.t_cng_tsk_sts(old_sts, new_sts, cng_dat, tsk_id)
		values(@old_sts, @new_sts, GETDATE(), @tsk_id)
	end
end
go


update dbo.t_tsk
set sts = 'outstanding'
where tsk_id = 3

select* from t_cng_tsk_sts
--where tsk_id = 3
go

--9. delete and insert in archive
create trigger deleteTask
on dbo.t_tsk
after delete as
begin
	declare @tsk_id int = (select tsk_id from deleted)
	declare @tsk_dsc varchar(50) = (select tsk_dsc from deleted)
	declare @pty varchar(50) = (select pty from deleted)
	declare @sts varchar(50) = (select sts from deleted)
	declare @tsk_str_dat date = (select tsk_str_dat from deleted)
	declare @tsk_end_dat date = (select tsk_end_dat from deleted)
	declare @tim_sts varchar(50) = (select tim_sts from deleted)
	declare @dep_id int = (select dep_id from deleted)

	insert into dbo.t_tsk_Archive1(tsk_id, tsk_dsc, pty, sts, tsk_str_dat, tsk_end_dat, tim_sts, dep_id)
	values(@tsk_id, @tsk_dsc, @pty, @sts, @tsk_str_dat, @tsk_end_dat, @tim_sts, @dep_id)
end

select*from dbo.t_tsk_Archive1