use elavator;

create table dbo.t_elv(
	elv_id int not null identity(1, 1),
	cur_flr int not null default 0,
	max_flr int not null,
	cur_kg int not null default 0,
	max_kg int not null,
	cur_ppl int not null default 0,
	max_ppl int not null,
	psg_ids varchar(50)
)

create table dbo.t_psg(
	psg_id int not null identity(1, 1),
	cur_flr int not null default 0,
	flr_to_go int not null,
	psg_kg int not null
)

create table dbo.t_elv_mvm(   --elevator movement 
	elv_1 int not null,
	elv_2 int not null,
	elv_3 int not null
)