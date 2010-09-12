delete from individuals where id < 0;
delete from projects where id < 0;
delete from companies where id < 0;

insert into companies (id, name) values
(-1, "ACME Books");

insert into projects (id, name, survey_key, survey_mode, premium_expiry, premium_limit, company_id) values
(-1, "Online Bookstore", "885a0079624d19f24fc02b97040904e6ef981444", 0, date(now()), 5, -1);

insert into individuals (id, login, email, first_name, last_name, crypted_password, salt, activated_at, accepted_agreement, company_id, role) values
(-1, "demo", "demo@planigle.com", "Fred", "Developer", "b98229cbf40ba20980cfbba4c75fda2a903d8bbc", "c305359343ecf79911ebcd78267b9ff00911119f", now() - interval 1 day, now(), -1, 1);
