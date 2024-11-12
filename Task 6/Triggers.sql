create trigger insertElv
on dbo.t_elv
after insert
as
	if (select count(*) from dbo.t_elv) > 3
		print 'only 3 elevators'
		rollback;
go

create trigger updateElv
on dbo.t_elv
after update
as
	declare @p_new_flr int, @p_old_flr int, @p_elv_id int
	select @p_new_flr = cur_flr from inserted
	select @p_old_flr = cur_flr from deleted
	select @p_elv_id = elv_id from inserted
	
	if @p_elv_id = 1
	begin
		update dbo.t_elv_mvm
		set elv_1 = null
		where flr_num = @p_old_flr

		update dbo.t_elv_mvm
		set elv_1 = 'here'
		where flr_num = @p_new_flr
	end
	else if @p_elv_id = 2
	begin
		update dbo.t_elv_mvm
		set elv_2 = null
		where flr_num = @p_old_flr

		update dbo.t_elv_mvm
		set elv_2 = 'here'
		where flr_num = @p_new_flr
	end
	else if @p_elv_id = 3
	begin
		update dbo.t_elv_mvm
		set elv_3 = null
		where flr_num = @p_old_flr

		update dbo.t_elv_mvm
		set elv_3 = 'here'
		where flr_num = @p_new_flr
	end
go
		
create trigger insertElvMvm
on dbo.t_elv_mvm
after insert
as
	if (select count(*) from dbo.t_elv_mvm) > 6
		print 'NO NO'
		rollback;
go