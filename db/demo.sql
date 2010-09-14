delete from tasks where id < 0;
delete from stories where id < 0;
delete from individuals_projects where project_id < 0;
delete from individuals where id < 0;
delete from iterations where id < 0;
delete from releases where id < 0;
delete from story_attributes where id < 0;
delete from projects where id < 0;
delete from companies where id < 0;

insert into companies (id, name) values
(-10, "ACME Books");

insert into projects (company_id, id, name, survey_key, survey_mode, premium_expiry, premium_limit) values
(-10, -10, "Online Bookstore", "885a0079624d19f24fc02b97040904e6ef981444", 2, curdate(), 5);

insert into individuals (company_id, id, login, email, first_name, last_name, crypted_password, salt, activated_at, accepted_agreement, role) values
(-10, -10, "demo", "demo@planigle.com", "Fred", "Hacker", "b98229cbf40ba20980cfbba4c75fda2a903d8bbc", "c305359343ecf79911ebcd78267b9ff00911119f", now() - interval 1 day, now(), 1),
(-10, -11, "demo_s", "demo@planigle.com", "Suzy", "Coder", "b98229cbf40ba20980cfbba4c75fda2a903d8bbc", "c305359343ecf79911ebcd78267b9ff00911119f", now() - interval 1 day, now(), 1),
(-10, -12, "demo_t", "demo@planigle.com", "Tom", "Tester", "b98229cbf40ba20980cfbba4c75fda2a903d8bbc", "c305359343ecf79911ebcd78267b9ff00911119f", now() - interval 1 day, now(), 1),
(-10, -13, "demo_e", "demo@planigle.com", "Ed", "Owner", "b98229cbf40ba20980cfbba4c75fda2a903d8bbc", "c305359343ecf79911ebcd78267b9ff00911119f", now() - interval 1 day, now(), 1);

insert into individuals_projects (project_id, individual_id) values
(-10, -10),
(-10, -11),
(-10, -12),
(-10, -13);

insert into iterations (project_id, id, name, start, finish) values
(-10, -10, "Iteration 1", curdate() - interval 17 day, curdate() - interval 3 day),
(-10, -11, "Iteration 2", curdate() - interval 3 day, curdate() + interval 11 day),
(-10, -12, "Iteration 3", curdate() + interval 11 day, curdate() + interval 25 day),
(-10, -13, "Iteration 4", curdate() + interval 25 day, curdate() + interval 39 day),
(-10, -14, "Iteration 5", curdate() + interval 39 day, curdate() + interval 53 day),
(-10, -15, "Iteration 6", curdate() + interval 53 day, curdate() + interval 67 day);

insert into releases (project_id, id, name, start, finish) values
(-10, -10, "1.0", curdate() - interval 17 day, curdate() + interval 67 day);

insert into story_attributes (project_id, id, name, value_type, is_custom, width, ordering, `show`) values
(-10,-10,'Id',0,0,60,'10.00000',0),
(-10,-11,'Name',0,0,200,'20.00000',1),
(-10,-12,'Description',1,0,300,'30.00000',0),
(-10,-13,'Acceptance Criteria',1,0,300,'40.00000',0),
(-10,-14,'Release',3,0,100,'50.00000',0),
(-10,-15,'Iteration',3,0,100,'60.00000',1),
(-10,-16,'Team',3,0,75,'70.00000',1),
(-10,-17,'Owner',3,0,110,'80.00000',1),
(-10,-18,'Size',2,0,50,'90.00000',1),
(-10,-19,'Estimate',2,0,60,'100.00000',0),
(-10,-20,'Actual',2,0,50,'110.00000',0),
(-10,-21,'To Do',2,0,50,'120.00000',1),
(-10,-22,'Status',3,0,100,'130.00000',1),
(-10,-23,'Public',3,0,60,'140.00000',0),
(-10,-24,'Rank',2,0,40,'150.00000',1),
(-10,-25,'User Rank',2,0,90,'160.00000',0);

insert into stories (project_id, id, name, effort, status_code, priority, release_id, iteration_id, individual_id, is_public, description, reason_blocked) values
(-10, -10, "User searches books by name", 2, 3, 10, -10, -10, -13, 1, "", ""),
(-10, -11, "User searches books by author", 1, 3, 20, -10, -10, -13, 1, "", ""),
(-10, -12, "User views book details", 1, 3, 30, -10, -10, -13, 1, "", ""),
(-10, -13, "User buys book", 5, 3, 40, -10, -10, -13, 1, "", ""),
(-10, -14, "User logs in", 2, 1, 50, -10, -11, -13, 1, "", ""),
(-10, -15, "User creates profile", 3, 0, 60, -10, -11, -13, 1, "", ""),
(-10, -16, "User updates profile", 2, 0, 70, -10, -11, -13, 1, "", ""),
(-10, -17, "User forgets password", 1, 0, 80, -10, -11, -13, 1, "", ""),
(-10, -18, "User adds book to shopping cart", 2, 0, 90, -10, -11, -13, 1, "", ""),
(-10, -19, "User removes book from shopping cart", 1, 0, 100, -10, null, -13, 1, "", ""),
(-10, -20, "User chooses shipping option", 1, 0, 110, -10, null, -13, 1, "", ""),
(-10, -21, "User views order status", 5, 0, 120, -10, null, -13, 1, "", ""),
(-10, -22, "Admin imports new books", 3, 0, 130, -10, null, -13, 1, "", ""),
(-10, -23, "Admin views books to ship", 2, 0, 140, -10, null, -13, 1, "", ""),
(-10, -24, "Admin disables book for purchases", 1, 0, 150, -10, null, -13, 1, "", ""),
(-10, -25, "Admin updates info on book", 2, 0, 160, -10, null, -13, 1, "", ""),
(-10, -26, "User comments on book", 2, 0, 170, -10, null, -13, 1, "", ""),
(-10, -27, "Admin deletes book comment", 1, 0, 180, -10, null, -13, 1, "", ""),
(-10, -28, "User views other books by author", 1, 0, 190, -10, null, -13, 1, "", ""),
(-10, -29, "User views related books", 3, 0, 200, -10, null, -13, 1, "", ""),
(-10, -30, "User creates wish list", 3, 0, 210, -10, null, -13, 1, "", ""),
(-10, -31, "User buys gift card", 2, 0, 220, -10, null, -13, 1, "", ""),
(-10, -32, "User views history of orders", 3, 0, 230, -10, null, -13, 1, "", "");
