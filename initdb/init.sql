create table models(
    uid integer not null auto_increment primary key,
    model_loc varchar(128) not null ,
    data_loc varchar(128) not null ,
    pred_loc varchar(128),
    createdAt timestamp not null default CURRENT_TIMESTAMP
);