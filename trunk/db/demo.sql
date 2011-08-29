delete from tasks using tasks, stories, projects where tasks.story_id=stories.id and project_id=projects.id and company_id = -10;
delete from criteria using criteria, stories, projects where criteria.story_id=stories.id and project_id=projects.id and company_id = -10;
delete from stories using stories, projects where project_id=projects.id and company_id = -10;
delete from individuals_projects using individuals_projects, projects where project_id = projects.id and company_id = -10;
delete from individuals where company_id = -10;
delete from iteration_velocities using iteration_velocities, iterations, projects where iteration_id=iterations.id and project_id=projects.id and company_id = -10;
delete from iteration_totals using iteration_totals, iterations, projects where iteration_id=iterations.id and project_id=projects.id and company_id = -10;
delete from iteration_story_totals using iteration_story_totals, iterations, projects where iteration_id=iterations.id and project_id=projects.id and company_id = -10;
delete from release_totals using release_totals, releases, projects where release_id=releases.id and project_id=projects.id and company_id = -10;
delete from iterations using iterations, projects where project_id=projects.id and company_id = -10;
delete from releases using releases, projects where project_id=projects.id and company_id = -10;
delete from story_attributes using story_attributes, projects where project_id=projects.id and company_id = -10;
delete from projects where company_id = -10;
delete from companies where id = -10;

insert into companies (id, name, premium_expiry, premium_limit) values
(-10, "ACME Books", curdate() + interval 30 day, 5);

insert into projects (company_id, id, name, survey_key, survey_mode) values
(-10, -10, "Online Bookstore", "885a0079624d19f24fc02b97040904e6ef981444", 2);

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

insert into tasks (story_id, id, name, description, status_code, estimate, effort, priority, individual_id, reason_blocked) values
(-10, -10, "Create books table", "", 3, 3, 0, 10, -10, ""),
(-10, -11, "Show search screen", "", 3, 2, 0, 20, -11, ""),
(-10, -12, "Show results", "", 3, 3, 0, 30, -11, ""),
(-10, -13, "Test screen", "", 3, 2, 0, 40, -12, ""),
(-11, -14, "Do it", "", 3, 2, 0, 10, -10, ""),
(-11, -15, "Test it", "", 3, 1, 0, 20, -12, ""),
(-12, -16, "Modify schema for additional attributes", "", 3, 1, 0, 10, -11, ""),
(-12, -17, "Create details screen", "", 3, 3, 0, 20, -10, ""),
(-12, -18, "Test details screen", "", 3, 4, 0, 30, -12, ""),
(-13, -19, "Capture billing information", "", 3, 3, 0, 10, -11, ""),
(-13, -20, "Complete financial transaction", "", 3, 4, 0, 20, -10, ""),
(-13, -21, "Notify customer", "", 3, 1, 0, 30, -10, ""),
(-13, -22, "Test purchase", "", 3, 4, 0, 40, -12, ""),
(-14, -23, "Create user table", "", 3, 2, 0, 10, null, ""),
(-14, -24, "Show login screen", "", 1, 2, 2, 20, -10, ""),
(-14, -25, "Show user info on existing screens", "", 1, 2, 2, 30, -11, ""),
(-14, -26, "Test login", "", 0, 2, 2, 40, null, ""),
(-15, -27, "Show user profile screen", "", 0, 2, 2, 10, null, ""),
(-15, -28, "Validate email address", "", 0, 2, 2, 20, null, ""),
(-15, -29, "Test profile", "", 0, 3, 3, 30, null, ""),
(-16, -30, "Edit profile", "", 0, 2, 2, 10, null, ""),
(-16, -31, "Test edits", "", 0, 2, 2, 20, null, ""),
(-17, -32, "Enable button on login", "", 0, 1, 1, 10, null, ""),
(-17, -33, "Send email", "", 0, 1, 1, 20, null, ""),
(-17, -34, "Show confirmation screen", "", 0, 1, 1, 30, null, ""),
(-17, -35, "Test forgot password", "", 0, 2, 2, 40, null, ""),
(-18, -36, "User adds to shopping cart", "", 0, 2, 2, 10, null, ""),
(-18, -37, "User checks out", "", 0, 3, 3, 20, null, ""),
(-18, -38, "Test shopping cart", "", 0, 2, 2, 30, null, "");

insert into criteria (story_id, id, description, status_code, priority) values
(-10, -11, "Search is case insensitive", 1, 10),
(-10, -12, "Search supports strings which are a substring of the matching string", 1, 20),
(-10, -13, "User is presented with a list of matching books", 1, 30),
(-10, -14, "User can refine search without starting over", 1, 40),
(-11, -15, "Search is case insensitive", 1, 10),
(-11, -16, "Search supports strings which are a substring of the matching string", 1, 20),
(-11, -17, "User is presented with a list of matching books", 1, 30),
(-11, -18, "User can refine search without starting over", 1, 40),
(-12, -19, "User sees title of book", 1, 10),
(-12, -20, "User sees author", 1, 20),
(-12, -21, "User sees picture of book", 1, 30),
(-12, -22, "User sees description", 1, 40),
(-12, -23, "User sees price", 1, 50),
(-13, -24, "User sees thumbnail of picture", 1, 10),
(-13, -25, "User sees title", 1, 20),
(-13, -26, "User sees author", 1, 30),
(-13, -27, "User sees price", 1, 40),
(-13, -28, "User enters billing information (first name, last name, street address, city, state/province, zip code, country, phone number, email address", 1, 50),
(-13, -29, "All fields are mandatory", 1, 60),
(-13, -30, "User taken to PayPal on clicking purchase", 1, 70),
(-13, -31, "User receives email when purchase completed", 1, 80),
(-14, -32, "User can click on log in at any point (if not logged on)", 0, 10),
(-14, -33, "User sees name on corner of page if logged in", 0, 20),
(-14, -34, "If credentials, don't match user is told 'Invalid credentials'", 0, 30),
(-14, -35, "Password should be encrypted in non-reversible format", 0, 40),
(-14, -36, "On purchase, user's information is filled in by default", 0, 50),
(-15, -37, "User enters information (login, password, first name, last name, street address, city, state/province, zip code, country, phone number, email address", 0, 10),
(-15, -38, "All fields are mandatory", 0, 20),
(-15, -39, "If login already exists, user told 'Login already taken'", 0, 30),
(-15, -40, "User is sent email to validate email address", 0, 40),
(-15, -41, "User must click on link in email to be able to log in", 0, 50),
(-16, -42, "User can click on Edit profile (by name in upper corner of screen)", 0, 10),
(-16, -43, "Any field can be edited (except for login)", 0, 20),
(-16, -44, "User is sent email to validate new email address if changed", 0, 30),
(-16, -45, "User must click on link in email to be able to log in", 0, 40),
(-17, -46, "User can click on Forgot Password", 0, 10),
(-17, -47, "User is asked to enter email address", 0, 20),
(-17, -48, "If invalid email address, user is told 'Unknown email address'", 0, 30),
(-17, -49, "If valid email address, user is sent email", 0, 40),
(-17, -50, "User clicks on link in email and is allowed to reset password", 0, 50),
(-18, -51, "User clicks on add to shopping cart", 0, 10),
(-18, -52, "User is shown on side of screen number of items in cart and total cost", 0, 20),
(-18, -53, "User can click on Finish shopping to go to existing confirmation screen", 0, 30),
(-18, -54, "Confirmation screen lists all items in cart", 0, 40);

insert into iteration_velocities values
(-10,-10,null,9,9),
(-11,-11,null,10,0);

insert into iteration_totals (id,iteration_id,date,created,in_progress,blocked,done) values
(-10,-10,curdate()-interval 17 day,33,0,0,0),
(-11,-10,curdate()-interval 16 day,28,5,0,0),
(-12,-10,curdate()-interval 15 day,23,8,0,2),
(-13,-10,curdate()-interval 14 day,21,7,0,5),
(-14,-10,curdate()-interval 13 day,20,6,0,7),
(-15,-10,curdate()-interval 12 day,13,7,0,13),
(-16,-10,curdate()-interval 11 day,10,9,0,14),
(-17,-10,curdate()-interval 10 day,10,9,0,14),
(-18,-10,curdate()-interval 9 day,1,11,0,21),
(-19,-10,curdate()-interval 8 day,1,11,0,21),
(-20,-10,curdate()-interval 7 day,1,8,0,24),
(-21,-10,curdate()-interval 6 day,1,8,0,24),
(-22,-10,curdate()-interval 5 day,0,5,0,28),
(-23,-10,curdate()-interval 4 day,0,4,0,28),
(-24,-10,curdate()-interval 3 day,0,0,0,32),
(-25,-11,curdate()-interval 3 day,31,0,0,0),
(-26,-11,curdate()-interval 2 day,25,6,0,0),
(-27,-11,curdate()-interval 1 day,19,6,0,6),
(-28,-11,curdate(),19,6,0,6);

insert into iteration_story_totals (id,iteration_id,date,created,in_progress,blocked,done) values
(-10,-10,curdate()-interval 17 day,9,0,0,0),
(-11,-10,curdate()-interval 16 day,7,2,0,0),
(-12,-10,curdate()-interval 15 day,7,2,0,0),
(-13,-10,curdate()-interval 14 day,7,2,0,0),
(-14,-10,curdate()-interval 13 day,6,3,0,0),
(-15,-10,curdate()-interval 12 day,5,1,0,3),
(-16,-10,curdate()-interval 11 day,5,1,0,3),
(-17,-10,curdate()-interval 10 day,0,6,0,3),
(-18,-10,curdate()-interval 9 day,0,6,0,3),
(-19,-10,curdate()-interval 8 day,0,6,0,3),
(-20,-10,curdate()-interval 7 day,0,5,0,4),
(-21,-10,curdate()-interval 6 day,0,5,0,4),
(-22,-10,curdate()-interval 5 day,0,5,0,4),
(-23,-10,curdate()-interval 4 day,0,5,0,4),
(-24,-10,curdate()-interval 3 day,0,0,0,9),
(-25,-11,curdate()-interval 3 day,10,0,0,0),
(-26,-11,curdate()-interval 2 day,8,2,0,0),
(-27,-11,curdate()-interval 1 day,8,2,0,0),
(-28,-11,curdate(),8,2,0,0);

insert into release_totals (id,release_id,date,created,in_progress,blocked,done) values
(-10,-10,curdate()-interval 17 day,49,0,0,0),
(-11,-10,curdate()-interval 16 day,47,2,0,0),
(-12,-10,curdate()-interval 15 day,47,2,0,0),
(-13,-10,curdate()-interval 14 day,47,2,0,0),
(-14,-10,curdate()-interval 13 day,46,3,0,0),
(-15,-10,curdate()-interval 12 day,45,1,0,3),
(-16,-10,curdate()-interval 11 day,45,1,0,3),
(-17,-10,curdate()-interval 10 day,40,6,0,3),
(-18,-10,curdate()-interval 9 day,40,6,0,3),
(-19,-10,curdate()-interval 8 day,40,6,0,3),
(-20,-10,curdate()-interval 7 day,40,5,0,4),
(-21,-10,curdate()-interval 6 day,40,5,0,4),
(-22,-10,curdate()-interval 5 day,40,5,0,4),
(-23,-10,curdate()-interval 4 day,40,5,0,4),
(-24,-10,curdate()-interval 3 day,40,0,0,9),
(-25,-10,curdate()-interval 2 day,38,2,0,9),
(-26,-10,curdate()-interval 1 day,38,2,0,9),
(-27,-10,curdate(),38,2,0,9);
