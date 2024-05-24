CREATE TABLE testsch.users (
    user_id INTEGER PRIMARY KEY,
    email VARCHAR(255),
    last_login timestamp
); 

CREATE TABLE testsch.login_count (
    user_id INTEGER PRIMARY KEY,
    last_login timestamp,
    log_count INTEGER --count_no_of_times_updated
);

CREATE TABLE testsch.mail_to (
    id bigserial PRIMARY key,
    to_user INTEGER not null,
    user_email VARCHAR(255),
    warn_time TIMESTAMP,
    sent BOOLEAN default false
); drop table testsch.mail_to ;

INSERT INTO testsch.users values (10001, 'user@example.com', '2023-06-07 12:00:00.000');

insert into testsch.mail_to (to_user,user_email,warn_time,sent)
values (10001,'user@example.com',NOW(),false );

select * from testsch.login_count lc ;

CREATE OR REPLACE FUNCTION testsch.update_login_count()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        -- Insert new row with log_count = 1
        INSERT INTO testsch.login_count (user_id, last_login, log_count)
        VALUES (NEW.user_id, NEW.last_login+'05:30:00.000', 1);
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Check if last_login is updated
        IF (OLD.last_login <> NEW.last_login) THEN
            -- Check if current_date > date_trunc('day', last_login)
            IF (current_date > date_trunc('day', OLD.last_login)) THEN
                -- Reset count to 0 and update last_login
                UPDATE testsch.login_count
                SET log_count = 1, last_login = NEW.last_login+'05:30:00.000'
                WHERE user_id = NEW.user_id;
            ELSE
                -- Increment count by 1 and update last_login
                UPDATE testsch.login_count
                SET log_count = log_count + 1, last_login = NEW.last_login+'05:30:00.000'
                WHERE user_id = NEW.user_id;
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

select u.user_id, u.email, lc.log_count, lc.last_login from testsch.users u, testsch.login_count lc where u.user_id = lc.user_id  ;

CREATE TRIGGER update_login_count_trigger
AFTER INSERT OR UPDATE ON testsch.users
FOR EACH ROW
EXECUTE FUNCTION testsch.update_login_count();


CREATE OR REPLACE FUNCTION testsch.insert_mail_to()
  RETURNS TRIGGER AS
$$
BEGIN
  IF (NEW.log_count > 5) THEN
    -- Check if to_user already exists in mail_to table
    IF EXISTS (SELECT 1 FROM testsch.mail_to WHERE to_user = NEW.user_id) THEN
      -- Update warn_time and sent columns
      UPDATE testsch.mail_to
      SET warn_time = u.last_login + interval '5 hours 30 minutes', sent = false
      FROM testsch.users u
      WHERE testsch.mail_to.to_user = u.user_id
        AND u.user_id = NEW.user_id;
    ELSE
      -- Insert a new record
      INSERT INTO testsch.mail_to (to_user, user_email, warn_time)
      SELECT lc.user_id, u.email, u.last_login + interval '5 hours 30 minutes'
      FROM testsch.login_count lc
      JOIN testsch.users u ON lc.user_id = u.user_id
      WHERE lc.user_id = NEW.user_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$
LANGUAGE plpgsql;


-----------------------depreciated-below----------------------------------------------
CREATE OR REPLACE FUNCTION testsch.insert_mail_to()
  RETURNS TRIGGER AS
$$
BEGIN
  IF (NEW.log_count > 5) THEN
    INSERT INTO testsch.mail_to (to_user, user_email, warn_time)
    SELECT lc.user_id, u.email, u.last_login + interval '5 hours 30 minutes'
    FROM testsch.login_count lc
    JOIN testsch.users u ON lc.user_id = u.user_id
    WHERE lc.user_id = NEW.user_id;

    -- The id column and sent column will be automatically populated
    -- as bigserial and false respectively.
  END IF;

  RETURN NEW;
END;
$$
LANGUAGE plpgsql;
-----------------------depreciated-above----------------------------------------------
CREATE TRIGGER insert_mail_to_trigger
AFTER INSERT OR UPDATE ON testsch.login_count
FOR EACH ROW
EXECUTE FUNCTION testsch.insert_mail_to();

INSERT INTO testsch.users values (10001, 'sharishth.singh@example.com', NOW()- interval '5 hours 30 minutes') on conflict (user_id) 
do update set last_login = excluded.last_login;
INSERT INTO testsch.users values (10002, 'himesh@example.com', NOW()- interval '5 hours 30 minutes') on conflict (user_id) 
do update set last_login = excluded.last_login;
--INSERT INTO testsch.users values (10003, 'dummy@example.com', to_timestamp('2023-05-08 11:15:00', 'YYYY-MM-DD HH24:MI:SS')- interval '5 hours 30 minutes') on conflict (user_id) 
--do update set last_login = excluded.last_login;
INSERT INTO testsch.users values (10003, 'dummy@example.com', NOW()- interval '5 hours 30 minutes') on conflict (user_id) 
do update set last_login = excluded.last_login;

select * from testsch.users u ;
select * from testsch.login_count lc order by user_id asc ;
select * from testsch.mail_to mt;
select user_email from testsch.mail_to mt;

truncate table testsch.users ;
truncate table testsch.login_count ;
truncate table testsch.mail_to ;

select now(), current_date+1;
SELECT * FROM pg_trigger ;
SELECT * FROM testsch.login_count WHERE user_id = 10001;

-- Test values
select mt.id ,mt.user_email from testsch.mail_to mt where sent=false;
INSERT INTO testsch.mail_to (id ,sent) values ( 22 ,true)
on conflict (id)
do update SET sent=true;
