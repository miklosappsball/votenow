package hu.hoplitasoft.votenow.util;

import hu.hoplitasoft.votenow.QuestionCloser;
import hu.hoplitasoft.votenow.data.QuestionResult;

import java.io.UnsupportedEncodingException;
import java.util.Properties;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.json.JSONArray;
import org.json.JSONObject;

public class EmailListener  implements ServletContextListener {  
	
	private static String emailTemplate = null;
	private static String choiceTemplate = null;
	
	private static String EMAIL_SENDER = "emailsender@appsball.com";
	private static String EMAIL_PORT = "587";
	private static String EMAIL_HOST = "smtp.sparkpostmail.com";
	
/*	private static String EMAIL_HOST = "smtp.sendgrid.net";*/
	private static String EMAIL_USERNAME = "SMTP_Injection";
	private static String EMAIL_PASSWORD = "5257b29d494314cdb83b8f92c8f77610433b8c0e";

/*	private static String EMAIL_USERNAME = "apikey";
	private static String EMAIL_PASSWORD = "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";
*/	
	/*
	private static String EMAIL_USERNAME = "konfar.andras@appsball.com";
	private static String EMAIL_PASSWORD = "qwert2846";
	*/
	
	private static ServletContext context = null;
	
	@Override  
    public void contextInitialized(ServletContextEvent sce) {  
        Logger.info(" ---- Setting up context ----");
        context = sce.getServletContext();
        emailTemplate = IOUtil.inputStreamToString(context.getResourceAsStream("emailtext.html"));
        choiceTemplate = IOUtil.inputStreamToString(context.getResourceAsStream("choicetemplate.xml"));
        Logger.info(" ----- Setting up the servlet context for email listener -----");
        QuestionCloser.findNextQuestionToCloseStart();
    }  
  
    
	@Override  
    public void contextDestroyed(ServletContextEvent sce) {
		QuestionCloser.stop();
        Logger.info(" ----- Stopping session context -----");
	}  
	
	public static void sendEmail(final String toEmail, final String subject, final String content)
	{
		new Thread()
		{
			public void run() {
				Properties props = new Properties();
				props.put("mail.smtp.host", EMAIL_HOST);
				props.put("mail.smtp.socketFactory.port", EMAIL_PORT);
				props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
				props.put("mail.smtp.auth", "true");
				props.put("mail.smtp.port", EMAIL_PORT);
				props.put("mail.smtp.starttls.enable", "true");
				
				Session session = Session.getDefaultInstance(props,
						new javax.mail.Authenticator() {
					protected PasswordAuthentication getPasswordAuthentication() {
						return new PasswordAuthentication(EMAIL_USERNAME, EMAIL_PASSWORD);
					}
				});

				try 
				{
					Message message = new MimeMessage(session);
					message.setFrom(new InternetAddress(EMAIL_SENDER));
					
					InternetAddress to[] = new InternetAddress[1];
					to[0] = new InternetAddress(toEmail);
					message.setRecipients(Message.RecipientType.TO, to);
					
					InternetAddress mi[] = new InternetAddress[2];
					mi[0] = new InternetAddress("miklos.csendes@appsball.com");
					mi[1] = new InternetAddress("szabolcs.pinter@appsball.com");
					message.setRecipients(Message.RecipientType.BCC, mi);
					
					message.setFrom(new InternetAddress(EMAIL_SENDER, "Vote Now"));
					Logger.info("Email sender"+EMAIL_SENDER);
					message.setSubject(subject);
					message.setContent(content,"text/html; charset=UTF-8");
					Transport.send(message);

				} catch (MessagingException e) {
					e.printStackTrace();
				} catch (UnsupportedEncodingException e) {
					e.printStackTrace();
				}
			}
		}.start();
	}
	
	public final static String ADDRESS = "http://votenow-appsball2.rhcloud.com/";
	
	public static String createEmailCode(String code, String question)
	{
		return "<p style=\"font-size:22px;\">Your questionnaire vote code is: <b>"+code+"</b>. Ask people to vote now with this code – within the time frame!</p>"
				+"<p style=\"font-size:16px;\">The question: <b><i>"+question+"</i></b>"
				+createMessageEnding();
	}
	
	public static String createEmailContent(QuestionResult result)
	{
		String s = emailTemplate;
		
		try
		{
			JSONObject json = new JSONObject(result.createContentString());

			s = s.replace("{question}", json.getString("title"));
			s = s.replace("{total}", ""+json.getInt("numberOfRates"));
			String type = json.getBoolean("anonym") ? "anonymous, " : "non-anonymous, ";
			type += json.getBoolean("multichoice") ? "multichoice" : "single-choice";
			s = s.replace("{type}", type);

			StringBuilder sb = new StringBuilder();
			JSONArray choices = json.getJSONArray("choices");
			for(int i = 0; i<choices.length();i++)
			{
				JSONObject choice = choices.getJSONObject(i);
				String choiceString = choiceTemplate;
				choiceString = choiceString.replace("{choice}", choice.getString("choice"));
				choiceString = choiceString.replace("{percentage}", choice.getInt("number")+" ("+choice.getString("percentage")+")");

				StringBuilder sbc = new StringBuilder();
				if(choice.has("comments"))
				{
					JSONArray comments = choice.getJSONArray("comments");
					boolean first = true;
					for(int j=0;j<comments.length();j++)
					{
						JSONObject comment = comments.getJSONObject(j);
						if(json.getBoolean("multichoice"))
						{
							if(comment.has("name"))
							{
								if(!first) sbc.append(", ");
								sbc.append(comment.getString("name"));
								first = false;
							}
						}
						else
						{
							sbc.append("<div style=\"clear:both; margin-top:5px;\">");
							if(comment.has("name")) sbc.append("<b>"+comment.getString("name")+":</b> ");
							if(comment.has("comment")) sbc.append(comment.getString("comment"));
							sbc.append("</div>");
						}
					}
				}
				choiceString = choiceString.replace("{comments_for_choice}", sbc.toString());

				sb.append(choiceString); 
			}
			
			if(json.has("comments"))
			{
				sb.append("<div style=\"clear:both; font-size: 22pt; font-weight: bold; margin-top: 30px; color: red; text-decoration: underline;\">Comments:</div>");
				JSONArray comments = json.getJSONArray("comments");
				for(int j=0;j<comments.length();j++)
				{
					JSONObject comment = comments.getJSONObject(j);
					sb.append("<div style=\"clear:both; margin-top:5px;\">");
					if(comment.has("name")) sb.append("<b>"+comment.getString("name")+":</b> ");
					if(comment.has("comment")) sb.append(comment.getString("comment"));
					sb.append("</div>");
				}
			}
			
			
			s = s.replace("{choices}", sb.toString());
		}
		catch(Exception e)
		{
			s = "Internal server error("+e.getMessage()+")! Please contact us!";
			e.printStackTrace();
		}
		s += createMessageEnding();
		
		return s;
	}
	
	private static String createMessageEnding() 
	{
		String[] images = {"www","email","facebook","linkedin","twitter","youtube","blog","pinterest"};
		String[] imagesNames = {"Web","E-mail","Facebook","LinkedIn","Twitter","Youtube","Blog","Pinterest"};
		String[] urls = {
				"http://www.appsball.com",
				"mailto:mail@appsball.com",
				"https://www.facebook.com/appsball",
				"https://www.linkedin.com/company/appsball",
				"https://twitter.com/AppsBallLtd",
				"https://www.youtube.com/channel/UC8_zmoLbJC_O5S56fC1Fi_g",
				"https://appsball.blogspot.com",
		"http://www.pinterest.com/appsball/"};

		StringBuilder sb = new StringBuilder();
		
		StringBuilder links = new StringBuilder();
		
		sb.append("<p style=\"margin-top: 30px;\">Honest regards:</p>");
		sb.append("<img style=\"margin-left:150px\" src=\""+ADDRESS+"appsball"+".jpg\" />");
		sb.append("<center><p style=\"margin-top: 30px; font-weight:bold;\">Check frequently for our latest applications in</p></center>");
		sb.append("<center><table style=\"width:700px\"><tr>");
		sb.append("<td><center><img src=\""+ADDRESS+"appstore"+".jpg\" /></center></td>");
		sb.append("<td><center><img src=\""+ADDRESS+"play"+".jpg\" /></center></td>");
		sb.append("</tr></table></center>");

		sb.append("<center><table style=\"border-spacing:30px\"><tr>");
		
		int i=0;
		for(String img : images)
		{
			String url = urls[i];
			String imgName = imagesNames[i++];
			sb.append("<td><a href=\""+url+"\">");
			sb.append("<img src=\""+ADDRESS+img+".jpg\" />");
			sb.append("<p style=\"text-align:center;\">"+imgName+"</p>");
			sb.append("</a></td>");
			
			if(i%2 == 1) links.append("<tr>");
			links.append("<td>"+imgName+"</td>");
			int right = i%2==0 ? 0 : 40;
			links.append("<td style=\"padding-left:20px;padding-right:"+right+"px;\"><a href=\""+url+"\">"+url+"</a></td>");
			if(i%2 == 0) links.append("</tr>");
		}
		
		sb.append("</tr></table>");
		
		sb.append("<table style=\"border-spacing:0px\"><tr>");
		sb.append(links.toString());
		sb.append("</tr></table></center>");
		
		sb.append("<p style=\"font-style:italic\">");
		sb.append("Copyright &#169; 2014 Appsball Ltd., All rights reserved.");
		sb.append("</p>");
		sb.append("<p style=\"color:red;font-weight:bold;font-style:italic;\">");
		sb.append("Please do not reply to this mail.");
		sb.append("</p>");
		sb.append("<p style=\"color:green;font-weight:bold;\">");
		sb.append("Please consider the environment before printing this email");
		sb.append("</p>");

		return sb.toString();
	}

	public static boolean isEmailValid(String email) {
	    boolean isValid = false;

	    String expression = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{2,4}$";
	    CharSequence inputStr = email;

	    Pattern pattern = Pattern.compile(expression, Pattern.CASE_INSENSITIVE);
	    Matcher matcher = pattern.matcher(inputStr);
	    if (matcher.matches()) {
	        isValid = true;
	    }
	    return isValid;
	}
}
