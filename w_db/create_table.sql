
create table biodatabase1 ( 
    biodatabase_id  integer       not null primary key auto_increment, 
    name            varchar(128)  not null,
    description    text
    );

create table bioentry (
    bioentry_id     integer     not null primary key,
    biodatabase_id  integer     not null,
    accession       varchar(40) not null,
    identifier      varchar(40) ,
    name            varchar(40) not null,
    description     text,
    species_id      integer,    
    foreign key (biodatabase_id) references biodatabase (biodatabase_id) on delete cascade on update cascade,
    foreign key (species_id) references species (species_id) on delete cascade on update cascade
    );
    
create table species  (
   species_id       integer      primary key,
   name             varchar(100) not null,
   ncbi_id          integer      not null
   );

create table plate  (
   plate_id         integer not null primary key,
   biodatabase_id   integer ,
   name             varchar(40) not null,
   description      varchar(100)
   );

create table plate96  (
   plate96_id      integer not null primary key,
   plate_id         integer not null,
   name             varchar(40),
   foreign key (plate_id) references plate (plate_id) on delete cascade on update cascade
   );

create table plate_feature (
   plate_feature_id integer primary key,
   plate_id         integer not null,
   name             varchar(40) not null,
   value            varchar(100) not null,
   foreign key (plate_id) references plate (plate_id) on delete cascade on update cascade
   );

create table element (
   element_id   integer    not null primary key auto_increment, 
   plate_id     integer    not null,
   row          varchar(3) not null,
   col          integer not null,
   bioentry_id  integer    ,
   sample_id    varchar(40),
   foreign key (plate_id) references plate (plate_id) on delete cascade on update cascade,
   foreign key (bioentry_id) references bioentry (bioentry_id)  on delete cascade on update cascade
   );   

create table element96 (
   element96_id   integer    not null primary key,
   plate96_id     integer    not null,
   row          integer    not null,
   col          varchar(4) not null,
   foreign key (element96_id) references element (element_id)  on delete cascade on update cascade,
   foreign key (plate96_id) references plate96 (plate96_id) on delete cascade on update cascade
   );   

create table biosequence (
   biosequence_id integer primary key,
   bioentry_id    integer not null,
   seq            longtext,
   description    varchar(40),
   foreign key (bioentry_id) references bioentry (bioentry_id) on delete cascade on update cascade
   );
    
create table bioentry_feature (
   bioentry_feature_id integer primary key,
   bioentry_id         integer not null,
   name                varchar(20),
   value               varchar(200),
   foreign key (bioentry_id) references bioentry (bioentry_id) on delete cascade on update cascade
   );

   create index idx_bioentry_id ON bioentry (bioentry_id);
   create index idx_bioentry_2 ON bioentry (accession);
   create index idx_plate_id ON plate (plate_id);
   create index idx_element_id ON element (element_id);
   create index idx_element_2 ON element (plate_id, row, col);
   
   create index idx_bioentry_feature_id on bioentry_feature (bioentry_feature_id);
   create index idx_bioentry_feature_2 on bioentry_feature (bioentry_id);
   create index idx_bioentry_feature_3 on bioentry_feature (name);
   
create table software (
   software_id      integer primary key,
   name             varchar(40) not null,
   version          varchar(20)
   );

create table user (
   user_id    integer primary key auto_increment,
   name       varchar(100) not null,
   full_name  varchar(100) not null,
   email      varchar(100) 
   );

create table pathway (
   pathway_id  integer primary key,
   name        varchar(200) not null,
   description text
   );   

   create index idx_pathway_id on pathway (pathway_id);
   create index idx1_pathway_id on pathway (name);

create table assay (
   assay_id           integer primary key,
   user_id            varchar(30) not null,
   plate_id           integer,
   pathway_id           integer,
   software_id        integer,
   name               varchar (100)  not null,
   filename           varchar (100)  not null,
   upload_log         text,
   assay_date         date,
   assay_desc         varchar(100),
   replicate          integer,
   protocol           text,
   share              integer,
   foreign key (plate_id) references plate (plate_id) on delete cascade on update cascade,
   foreign key (pathway_id) references pathway (pathway_id) on delete cascade on update cascade,
   foreign key (software_id) references software (software_id) on delete cascade on update cascade
   );

   create index idx_assay_id on assay (assay_id);
   create index idx1_assay_id on assay (plate_id, pathway_id, user_id);


create table assay_feature (
   assay_feature_id                 integer primary key,
   assay_id                         integer not null,
   name                             varchar(30),
   value                            varchar(40),
   foreign key (assay_id)   references assay (assay_id) on delete cascade on update cascade
);

   create index idx_assay_feature_id on assay_feature (assay_feature_id);
   create index idx_assay_feature_2 on assay_feature (assay_id);


create table assay_result (
   assay_result_id      integer primary key,
   assay_id             integer not null,
   element_id           integer not null,
   value                integer not null,
   signal	            varchar(20),
   flash_time           varchar(20),
   measure_time         varchar(20),
   foreign key (assay_id)   references assay (assay_id) on delete cascade on update cascade,
   foreign key (element_id) references element (element_id) on delete cascade on update cascade
   );

   create index idx_assay_result_id on assay_result (assay_result_id);
   create index idx_assay_result_2 on assay_result (assay_id);
   create index idx_assay_result_3 on assay_result (element_id);
   
create table analysis (
   analysis_id          integer primary key,
   assay_result_id      integer not null,
   function             varchar(20) not null,
   setting              varchar(30),
   value                varchar(20) not null,
   foreign key (assay_result_id)  references assay_result (assay_result_id) on delete cascade on update cascade
   );

   create index idx_analysis_id on analysis (analysis_id);
   create index idx_analysis_1 on analysis (assay_result_id);
   create index idx_analysis_2 on analysis (function, setting);

create table t0 (
   rand_num       integer,
   assay_id       integer,
   row            varchar(3),
   col            integer,
   plate_id       integer,
   be_id          integer,
   sample_id      varchar(40)
);

   create index idx_t0_rand_num on t0 (rand_num);
   create index idx_t0_plate_id on t0 (plate_id);

create table t1 (
   rand_num       integer,
   assay_id       integer,
   row            varchar(3),
   col            integer,
   plate_id       integer,
   be_id          integer,
   sample_id      varchar(40),
   db_name        varchar(100)
);

   create index idx_t1_rand_num on t1 (rand_num);
   create index idx_t1_be_id on t1 (be_id);

create table t2 (
   rand_num       integer,
   assay_id       integer,
   row            varchar(3),
   col            integer,
   plate_id       integer,
   be_id          integer,
   sample_id      varchar(40),
   db_name        varchar(100),
   be_name        varchar(200),
   accession      varchar(40),
   identifier     varchar(40)
);

   create index idx_t2_rand_num on t2 (rand_num);
   create index idx_t2_be_id on t2 (be_id);

create table t3 (
   rand_num       integer,
   assay_id       integer,
   row            varchar(3),
   col            integer,
   plate_id       integer,
   be_id          integer,
   sample_id      varchar(40),
   db_name        varchar(100),
   be_name        varchar(200),
   accession      varchar(40),
   identifier     varchar(40),
   fea_name       varchar(20),
   fea_value      varchar(200)
);

   create index idx_t3_rand_num on t3 (rand_num);
   create index idx_t3_be_id on t3 (be_id);


======== ruby ===========

[config]
enviroment.rb: ActiveRecord::Base.pluralize_table_names = false

[command]
rails screen

ruby script\generate scaffold biodatabase biodatabase
ruby script\generate scaffold assay  assay
ruby script\generate scaffold assay_result assay_result
ruby script\generate scaffold bioentry  bioentry
ruby script\generate scaffold bioentry_feature bioentry_feature
ruby script\generate scaffold biosequence biosequence
ruby script\generate scaffold element element
ruby script\generate scaffold element96 element96
ruby script\generate scaffold plate plate
ruby script\generate scaffold plate96 plate96
ruby script\generate scaffold plate_feature plate_feature
ruby script\generate scaffold software software
ruby script\generate scaffold species species
ruby script\generate scaffold user user
ruby script\generate scaffold topic topic

mongrel_rails start

sudo /sbin/chkconfig -a rails_screen

sudo /sbin/chkconfig -a rails_screen
