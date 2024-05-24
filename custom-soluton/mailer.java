	package com.example.mailtimmer;

// time dependencies
import java.util.TimerTask;
import java.util.Date;

// db dependencies
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.PreparedStatement;

// mail dependencies
import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;


/**
*
*@author Sharishth Singh
*
**/

public class ScheduledTask extends TimerTask {
	
	private static class PostgreSQLJDBC {
		public static void main(String[]args) {
			Connection c = null;
			Statement stmt = null;
			Statement updstmt = null;
			PreparedStatement p=null;
			try {
				Class.forName("org.postgresql.Driver");
				c = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres",
		            "postgres", "dbpassord");
				System.out.println("Opened database successfully");
				stmt = c.createStatement();
				updstmt = c.createStatement();
				
				// mail creds ---START---
				
				String fromEmail = "sender@email.com";
		        

		        // SMTP server configuration
		        String smtpHost = "yourhostdomainORip";
		        int smtpPort = 587; // Change to the appropriate port for your SMTP server

		        // SMTP authentication credentials
		        String username = "username";
		        String password = "password";

		        // Email content
		        String subject = "Hello from JavaMail";
		        String body = "This is a test email sent from JavaMail.";		        

		        // Set up JavaMail properties
		        Properties props = new Properties();
		        props.put("mail.smtp.host", smtpHost);
		        props.put("mail.smtp.port", smtpPort);
		        props.put("mail.smtp.auth", "true");
		        props.put("mail.smtp.starttls.enable", "false");
		        props.put("mail.smtp.ssl.enable", "false");
		        
		        // Create a Session object with authentication
		        Authenticator auth = new Authenticator() {
		            protected PasswordAuthentication getPasswordAuthentication() {
		                return new PasswordAuthentication(username, password);
		            }
		        };
		        Session session = Session.getInstance(props, auth);
		        
		        // mail creds ---END---
				
				// fetch query
				String sql = "select * from testsch.mail_to mt where sent=false";
				ResultSet rs = stmt.executeQuery(sql);
				while ( rs.next() ) {
					//	 res = rs.getInt("res");
					int tbl_id = rs.getInt("id");
					String to_email = rs.getString("user_email");
					//System.out.println("Result: "+to_email);
					boolean sentStatus = rs.getBoolean("sent");
					//System.out.println("Result: "+sentStatus);
					System.out.println("Sending mail to: "+tbl_id+":: "+to_email+" ::IsAlreadySent: "+sentStatus);
					if (sentStatus==false) {
						System.out.println("Sending Email...");
						String updsql = "update testsch.mail_to set sent=true where id="+tbl_id;
						System.out.println(updsql);
						try {
							// Create a MimeMessage object
							MimeMessage message = new MimeMessage(session);

							// Set the sender and recipient addresses
							message.setFrom(new InternetAddress(fromEmail));
							message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to_email));

							// Set the subject and body of the email
							message.setSubject(subject);
							message.setText(body);

							// Send the email
							Transport.send(message);

							System.out.println("Email sent successfully.");
							// update sent status in DB
							p = c.prepareStatement(updsql);
							p.execute();
						} catch (Exception e) {
							System.err.println("Failed to send email. Error: " + e.getMessage());
						}
						
			            
						/*
						try {
				            // Create a MimeMessage object
				            MimeMessage message = new MimeMessage(session);

				            // Set the sender and recipient addresses
				            message.setFrom(new InternetAddress(fromEmail));
				            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to_email));

				            // Set the subject and body of the email
				            message.setSubject(subject);
				            message.setText(body);

				            // Send the email
				            Transport.send(message);

				            System.out.println("Email sent successfully.");
				            System.out.println("Sending mail to: "+to_email+" ::IsAlreadySent: "+sentStatus);
				        } catch (MessagingException e) {
				            System.err.println("Failed to send email. Error: " + e.getMessage());
				        }
						*/
					}
				}
				rs.close();
				stmt.close();
		        c.close();
			} catch (Exception e) {
				e.printStackTrace();
		        System.err.println(e.getClass().getName()+": "+e.getMessage());
		        System.exit(0);
			} finally {
				System.out.println("code executed");
			}
		}
	}
	
	public void connectdb(String [] args) {
		PostgreSQLJDBC.main(args);
	}

	Date now; // to display current time

	// Add your task here
	public void run() {
		now = new Date(); // initialize date
		System.out.println("Time is :" + now); // Display current time
	}
}
