create table models(
    id integer not null auto_increment primary key,
    model_desc varchar(128) not null,
    model_loc varchar(128) not null ,
    data_loc varchar(128) not null ,
    pred_loc varchar(128),
    createdAt timestamp not null default CURRENT_TIMESTAMP
);

begin;
insert into models(model_desc,model_loc,data_loc,pred_loc) values
('Nandi Toyota UTrust Hosur Road-All Purchase','Utrust_Purchase_DT_1.2.rds','Nandi Toyota UTrust Hosur Road-Purchase.csv','Nandi Toyota Utrust Hosur Road-Purchase Prediction1.csv'),
('Popular Bajaj Kochi-Sales','Bajaj_Sales_DT_1.1.rds','Popular Bajaj Kochi-Sales.csv',NULL);

commit;