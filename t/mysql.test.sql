
/* mysql -h 127.0.0.1 -u test -p test */
/* mysql -h 127.0.0.1 -u test -p test < mysql.test.sql */
/* grant all privileges on test.* to test@127.0.0.1 identified by 'test'; */


drop table if exists user;

create table user(
    id int unsigned not null primary key auto_increment,
    login varchar(128) not null default '',
    password varchar(512) not null default '',
    status enum('online', 'offline') not null default 'offline',
    name varchar(512) not null default '',
    registered datetime not null,
    changed datetime,
    unique key login(login),
    key login_status(login, status)
) CHARACTER SET utf8 COLLATE utf8_bin;

insert into user(login, password, name, status, registered) values('login1', md5(concat('login1', 'password1')), 'name1', 'online', now());
insert into user(login, password, name, status, registered) values('login2', md5(concat('login2', 'password2')), 'name2', 'offline', now());


drop table if exists perm;

create table perm(
    id int unsigned not null primary key auto_increment,
    name varchar(50) not null default '',
    unique key name(name)
) CHARACTER SET utf8 COLLATE utf8_bin;

truncate table perm;
insert into perm(name) values('user_new'), ('user_edit'), ('user_view');
insert into perm(name) values('article_new'), ('article_edit'), ('article_view');
insert into perm(name) values('region_new'), ('region_edit'), ('region_view');
insert into perm(name) values('comment_new'), ('comment_edit'), ('comment_view'), ('comment_moder');
insert into perm(name) values('doc_new'), ('doc_edit'), ('doc_view'), ('doc_publish');
insert into perm(name) values('org_new'), ('org_edit'), ('org_view');


drop table if exists user_perm;

create table user_perm(
    id int unsigned not null primary key auto_increment,
    user_id int unsigned not null,
    perm_id int unsigned not null,
    registered datetime not null,
    unique key user_perm(user_id, perm_id)
) CHARACTER SET utf8 COLLATE utf8_bin;

truncate user_perm;
insert into user_perm(user_id, perm_id, registered) select 1, id, now() from perm;
insert into user_perm(user_id, perm_id, registered) select 2, id, now() from perm;


drop table if exists region;

create table region(
    id int unsigned not null primary key auto_increment,
    title varchar(512) not null default ''
) CHARACTER SET utf8 COLLATE utf8_bin;

truncate region;
insert into region(title) values('region1');
insert into region(title) values('region2');
insert into region(title) values('region3');
insert into region(title) values('region4');
insert into region(title) values('region5');


drop table if exists article;

create table article(
    id int unsigned not null primary key auto_increment,
    user_id int unsigned not null default 0,
    region_id int unsigned not null default 0,
    title varchar(512) not null default '',
    body text,
    status enum('draft', 'publish') not null default 'draft',
    for_first_page bool not null default 0,
    photo int unsigned,
    registered datetime not null,
    changed datetime
) CHARACTER SET utf8 COLLATE utf8_bin;

truncate article;
insert into article(user_id, title, body, registered) values(1, 'title1', 'body1', now());
insert into article(user_id, title, body, registered) values(1, 'title2', 'body2', now());
insert into article(user_id, title, body, registered) values(2, 'title3', 'body3', now());
insert into article(user_id, title, body, registered) values(2, 'title4', 'body4', now());
insert into article(user_id, title, body, registered) values(2, 'title5', '{"n":"name1","v":"va\'l\'ue2"}', now());
insert into article(user_id, title, body, registered) values(5, 'title6', 'body6', now());
insert into article(user_id, title, body, registered) values(5, 'title7', 'body7', now());
insert into article(user_id, title, body, registered) values(5, 'title8', 'body8', now());
insert into article(user_id, title, body, registered) values(5, 'title9', 'body9', now());
insert into article(user_id, title, body, registered) values(5, 'title10', 'body10', now());
insert into article(user_id, title, body, registered) values(5, 'title11', 'body11', now());
insert into article(user_id, title, body, registered) values(5, 'title12', 'body12', now());
insert into article(user_id, title, body, registered) values(5, 'title13', 'body13', now());
insert into article(user_id, title, body, registered) values(5, 'title14', 'body14', now());
insert into article(user_id, title, body, registered) values(5, 'title15', 'body15', now());
insert into article(user_id, title, body, registered) values(5, 'title16', 'body16', now());
insert into article(user_id, title, body, registered) values(5, 'title17', 'body17', now());
insert into article(user_id, title, body, registered) values(5, 'title18', 'body18', now());
insert into article(user_id, title, body, registered) values(5, 'title19', 'body19', now());
insert into article(user_id, title, body, registered) select user_id, concat(title,id,id), body, now() from article limit 19;
update article set region_id=3 where id=5;


drop table if exists article_region;

create table article_region(
    id int unsigned not null primary key auto_increment,
    article_id int unsigned not null,
    region_id int unsigned not null,
    registered datetime not null,
    unique key article_region(article_id, region_id)
) CHARACTER SET utf8 COLLATE utf8_bin;

truncate article_region;
insert into article_region(article_id, region_id, registered) select 1, id, now() from region;




drop table if exists comment;

create table comment(
    id int unsigned not null primary key auto_increment,
    article_id int unsigned not null default 0 comment 'link to article.id',
    user_id int unsigned not null default 0 comment 'link to user.id',
    body text comment 'body of comment',
    registered datetime not null,
    changed datetime
) CHARACTER SET utf8 COLLATE utf8_bin;

truncate comment;
insert into comment(article_id, user_id, body, registered) values(1, 1, 'comment1', now());
insert into comment(article_id, user_id, body, registered) values(1, 1, 'comment2', now());
insert into comment(article_id, user_id, body, registered) values(1, 1, 'comment3', now());
insert into comment(article_id, user_id, body, registered) values(1, 1, 'comment4', now());
insert into comment(article_id, user_id, body, registered) values(2, 1, 'comment5', now());
insert into comment(article_id, user_id, body, registered) values(2, 1, 'comment6', now());




drop table if exists doc;

create table doc(
    id int unsigned not null primary key auto_increment,
    user_id int unsigned not null default 0,
    title varchar(1024) not null default '',
    body text,
    status enum('draft', 'publish') not null default 'draft',
    registered datetime not null,
    changed datetime
) CHARACTER SET utf8 COLLATE utf8_bin;








drop table if exists org;

create table org(
    id int unsigned not null primary key auto_increment,
    title varchar(1024) not null default '',
    
    logo int unsigned,
    body text,
    status enum('online', 'offline') not null default 'offline',
    
    registered datetime not null,
    changed datetime
) CHARACTER SET utf8 COLLATE utf8_bin;

drop table if exists uploadfile;

create table uploadfile(
    id int unsigned not null primary key auto_increment,
    model varchar(64) not null default '',
    
    path varchar(512) not null default '',
    filename varchar(64) not null default '',
    
    ext varchar(12) not null default '',
    width int unsigned not null default 0,
    height int unsigned not null default 0,
    size int unsigned not null default 0,
    md5 varchar(32) not null default '',
    
    registered datetime not null,
    changed datetime
) CHARACTER SET utf8 COLLATE utf8_bin;


