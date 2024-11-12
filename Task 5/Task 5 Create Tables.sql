create table t_dep(
	dep_id int primary key identity(1, 1),
	dep_name varchar(50) not null,
	dep_loc varchar(50) not null
)

create table t_tsk(
	tsk_id int primary key identity(1, 1),
	tsk_dsc varchar(50) not null default '.',
	pty varchar(50) not null default 'low',
	sts varchar(50) default 'outstanding',
	tsk_str_dat date not null default getdate(),
	tsk_end_dat date not null default dateadd(month, 6, getdate()),
	num_emp int default 0,
	tim_sts varchar(50) not null,
	dep_id int not null foreign key references t_dep(dep_id)
)

create table t_man(
	man_id int primary key identity(1, 1),
	man_nam varchar not null,
	dep_id int not null foreign key references t_dep(dep_id),
	tsk_id int not null foreign key references t_tsk(tsk_id)
)

create table t_emp(
	emp_id int primary key identity(1, 1),
	emp_nam varchar not null,
	emp_sts varchar(50) not null default 'free',
	emp_ttl varchar not null,
	emp_loc varchar not null,
	man_id int not null foreign key references t_man(man_id),
	tsk_id int null foreign key references t_tsk(tsk_id)
)

create table t_cng_tsk_sts(
	cng_id int primary key identity(1, 1),
	old_sts varchar(50) not null,
	new_sts varchar(50) not null,
	cng_dat date not null,
	cng_tin time not null
)

create table t_tsk_Archive(
	tsk_id int primary key,
	tsk_dsc varchar(50) not null,
	pty varchar(50) not null,
	sts varchar(50) default 'complete',
	tsk_str_dat date not null,
	tsk_end_dat date not null,
	num_emp int default 0,
	tim_sts varchar(50) not null,
	dep_id int not null foreign key references t_dep(dep_id)
)

create table t_tsk_Archive1(
	ach_id int primary key identity(1, 1),
	tsk_id int null,
	tsk_dsc varchar(50) not null,
	pty varchar(50) not null,
	sts varchar(50) default 'complete',
	tsk_str_dat date not null,
	tsk_end_dat date not null,
	num_emp int default 0,
	tim_sts varchar(50) not null,
	dep_id int not null foreign key references t_dep(dep_id)
)