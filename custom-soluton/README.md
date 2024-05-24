# Auto Login Monitoring and Alert System

The following contains two basic components:
1. **trigger.sql:** Creates functions and triggers based on the existing user table created during Spotfire setup. It creates and updates two tables using only the database engine. One table maintains the login count of users and resets the counts as soon as the user logs in the next day. The other table creates a mailing list, based on the first table, with a boolean column to determine whether to send mail or not.
2. **mailer.java:** This code can be used as a service that uses your standard SMTP configuration. It utilizes the table with the boolean column to determine whether to send mail or not, and updates the boolean to mark it as sent after sending the mail to the user.
