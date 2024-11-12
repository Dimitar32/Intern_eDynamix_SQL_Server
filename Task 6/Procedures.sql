create procedure dbo.s_ins_new_psg
as
begin
	declare @p_cur_flr int, @p_flr_to_go int, @p_psg_kg int	
	
	SELECT @p_cur_flr = CAST(FLOOR(RAND()*(5-0+1)+0) as int)
	SELECT @p_flr_to_go = CAST(FLOOR(RAND()*(5-0+1)+0) as int)
	SELECT @p_psg_kg = CAST(FLOOR(RAND()*(480-60+1)+60) as int)

	if @p_cur_flr <> @p_flr_to_go
		insert into dbo.t_psg(cur_flr, flr_to_go, psg_kg)
		values(@p_cur_flr, @p_flr_to_go, @p_psg_kg)
end
go

exec dbo.s_ins_new_psg
go

create procedure dbo.s_chg
as
begin
	declare @p_psg_kg int, @p_psg_id int, @p_elv_id int, @p_flr int
	
	select top(1)@p_psg_id = psg_id from dbo.t_psg 
	select @p_psg_kg = psg_kg from dbo.t_psg where psg_id = @p_psg_id
	select @p_flr = flr_to_go from dbo.t_psg where psg_id = @p_psg_id 

	select top(1)@p_elv_id = elv_id 
	from dbo.t_elv e, dbo.t_psg p
	where p.psg_id = @p_psg_id and 
		  @p_psg_kg < e.max_kg and 
		  abs(e.cur_flr - p.cur_flr) = (select min(abs(e.cur_flr - p.cur_flr))
										from dbo.t_elv e, dbo.t_psg p
										where psg_id = @p_psg_id and @p_psg_kg < e.max_kg)
	
	update dbo.t_elv
	set cur_flr = @p_flr
	where elv_id = @p_elv_id

	delete from dbo.t_psg
	where psg_id = @p_psg_id
end
go

exec dbo.s_chg
go

create procedure dbo.s_set_elv_flr(@p_elv_1_flr int, @p_elv_2_flr int, @p_elv_3_flr int)
as
begin
	update dbo.t_elv_mvm
	set elv_1 = null, elv_2 = null, elv_3 = null

	update dbo.t_elv_mvm
	set elv_1 = 'here'
	where flr_num = @p_elv_1_flr

	update dbo.t_elv
	set cur_flr = @p_elv_1_flr
	where elv_id = 1

	update dbo.t_elv_mvm
	set elv_2 = 'here'
	where flr_num = @p_elv_2_flr
	
	update dbo.t_elv
	set cur_flr = @p_elv_2_flr
	where elv_id = 2

	update dbo.t_elv_mvm
	set elv_3 = 'here'
	where flr_num = @p_elv_3_flr
	
	update dbo.t_elv
	set cur_flr = @p_elv_3_flr
	where elv_id = 3
end
go

exec dbo.s_set_elv_flr @p_elv_1_flr = 1, @p_elv_2_flr = 1, @p_elv_3_flr = 1
go 

create procedure dbo.s_set_cst(@p_our_flr int, @p_flr_to_go int, @p_our_kg int)
as
begin
	declare @p_elv_id int 

	select top(1)@p_elv_id = elv_id 
	from dbo.t_elv e
	where @p_our_kg < e.max_kg and 
		  abs(e.cur_flr - @p_our_flr) = (select min(abs(e.cur_flr - @p_our_flr))
										from dbo.t_elv e
										where @p_our_kg < e.max_kg)
	
	update dbo.t_elv
	set cur_flr = @p_flr_to_go
	where elv_id = @p_elv_id
end
go

exec dbo.s_set_cst @p_our_flr = 4, @p_flr_to_go = 5, @p_our_kg = 400