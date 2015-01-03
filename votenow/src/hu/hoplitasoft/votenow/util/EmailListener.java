package hu.hoplitasoft.votenow.util;


import hu.hoplitasoft.votenow.QuestionCloser;
import hu.hoplitasoft.votenow.data.QuestionResult;

import java.util.List;
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

public class EmailListener  implements ServletContextListener {  
	
	private static String emailTemplate = null;
	private static String EMAIL_PORT = "465";
	private static String EMAIL_HOST = "smtp.zoho.com";
	private static String EMAIL_USERNAME = "emailsender@appsball.com";
	private static String EMAIL_PASSWORD = "AppsEmailer13";
	
	private static ServletContext context = null;
	
	public static void setEmailTemplate(String template)
	{
		emailTemplate = template;
	}
	
	@Override  
    public void contextInitialized(ServletContextEvent sce) {  
        Logger.info(" ---- Setting up context ----");
        context = sce.getServletContext();
        emailTemplate = IOUtil.inputStreamToString(context.getResourceAsStream("emailtext.html"));
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

				Session session = Session.getDefaultInstance(props,
						new javax.mail.Authenticator() {
					protected PasswordAuthentication getPasswordAuthentication() {
						return new PasswordAuthentication(EMAIL_USERNAME, EMAIL_PASSWORD);
					}
				});

				try 
				{
					Message message = new MimeMessage(session);
					message.setFrom(new InternetAddress(EMAIL_USERNAME));
					InternetAddress to[] = new InternetAddress[1];
					to[0] = new InternetAddress(toEmail);
					message.setRecipients(Message.RecipientType.TO, to);
					/*
					InternetAddress mi[] = new InternetAddress[2];
					mi[0] = new InternetAddress("miklos.csendes@appsball.com");
					mi[1] = new InternetAddress("szabolcs.pinter@appsball.com");
					message.setRecipients(Message.RecipientType.BCC, mi);
					 */
					message.setSubject(subject);
					message.setContent(content,"text/html");
					Transport.send(message);

				} catch (MessagingException e) {
					throw new RuntimeException(e);
				}
			}
		}.start();
	}
	
	public final static String ADDRESS = "http://ratenow-appsball.rhcloud.com/";
	
	public static String createEmailCode(String code, String question)
	{
		return "<p style=\"font-size:22px;\">Your questionnaire rate code is: <b>"+code+"</b>. Ask people to rate now with this code - within 3 minutes!</p>"
				+"<p style=\"font-size:16px;\">The question: <b><i>"+question+"</i></b>"
				+createMessageEnding();
	}
	
	public static String createEmailContent(QuestionResult result)
	{
		String s = emailTemplate;
		
		System.out.println("XXXXXX");
		result.createContentString();
		
		/*
		s = s.replace("{question}", result.getTitle());
		s = s.replace("{total}", ""+result.getNumberOfRates());
		s = s.replace("{avarage}", result.getAvarage());
		s = s.replace("{median}",  result.getMedian());
		s = s.replace("{modus}", result.getModus());
		s = s.replace("{sigma}", ""+result.getSdeviation());
		
		StringBuilder sb = new StringBuilder();
		for(int i=0;i<result.getRates().length;i++)
		{
			sb.append("<tr><td>");
			for(int j=0;j<=i;j++) sb.append("<img src=\"http://ratenow-appsball.rhcloud.com/star.jpg\">");
			sb.append("</td><td style=\"text-align:right;\">"+result.getRates()[i]+"</td><td style=\"text-align:right;\">"+result.getPercentages().get(i)+"%</td></tr>");
		}
		
		s = s.replace("{rates}", sb.toString());
		
		sb = new StringBuilder();
		int i=0;
		for(List<String> list : result.getMessages())
		{
			i++;
			sb.append("<p>");
			for(int j = 0;j<i;j++) sb.append("<img src=\""+ADDRESS+"star.jpg\">");
			sb.append("</p>");
			
			for(String str:list)
			{
				sb.append(str+"<br/>");
			}
		}
		
		s = s.replace("{messages}", ""+sb.toString());
		*/
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
