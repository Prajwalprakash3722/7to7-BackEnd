create table models(
    id integer not null auto_increment primary key,
    model_desc varchar(128) not null,
    model_loc varchar(128) not null ,
    data_loc varchar(128) not null ,
    pred_loc varchar(128),
    conf_loc varchar(128),
    createdAt timestamp not null default CURRENT_TIMESTAMP
);


begin;
insert into models(model_desc, model_loc, data_loc,pred_loc, conf_loc) values('Nandi Toyota Utrust All Branch-Purchase','UTrust_Purchase_DT_1.2.rds','Nandi Toyota UTrust All Branch-Purchase.csv','Nandi Toyota UTrust All Branch-Purchase - scored.csv','Nandi Toyota UTrust All Branch-Purchase - confusion.csv');
INSERT INTO models(model_desc,model_loc,data_loc,pred_loc) VALUES 
 ('Popular Bajaj Kochi-Sales','Bajaj_Sales_DT_1.1.rds','Popular Bajaj Kochi-Sales.csv','Popular Bajaj Kochi-Sales - scored.csv'),
 ('Popular Hyundai Kochi-New Car Sales','Hyundai Sales_DT_1.1.rds','Popular Hyundai Kochi-New Car Sales.csv','Popular Hyundai Kochi-New Car Sales - scored.csv'),
 ('Nandi Toyota Utrust All Branch-Non Trade-in','UTrust_NonTradeIn_DT_1.1.rds','Nandi Toyota Utrust All Branch-Non Trade-in.csv','Nandi Toyota Utrust All Branch-Non Trade-in - scored.csv');


insert into models(model_desc, model_loc, data_loc,pred_loc, conf_loc) values('Popular Hyundai Kochi-New Car Sales With Modified Warm entries','Hyundai Sales_DT_1.1.rds','Popular Hyundai Kochi-New Car Sale With Warm.csv','Popular Hyundai Kochi-New Car Sale With Warm - scored.csv','Popular Hyundai Kochi-New Car Sale With Warm - confusion.csv');

commit;
--  ('Nandi Toyota UTrust All Branch- Trade-in','UTrust_TradeIn_DT_1.1.rds','Nandi Toyota Utrust All Branch-Trade-in.csv','Nandi Toyota Utrust All Branch-Trade-in - scored.csv');


