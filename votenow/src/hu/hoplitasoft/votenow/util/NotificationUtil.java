package hu.hoplitasoft.votenow.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import javapns.Push;
import javapns.notification.PushNotificationPayload;
import javapns.notification.PushedNotification;
import javapns.notification.PushedNotifications;

import com.google.android.gcm.server.Message;
import com.google.android.gcm.server.Result;
import com.google.android.gcm.server.Sender;

public class NotificationUtil 
{	
    private static final String SENDER_ID = "AIzaSyDWEuqkQGKNt4UZ-FBUFsslGjinDn-CTnw";
    
   
	public static void notificate(String code, String device, String devicetype, String title) {
		
		if(devicetype.startsWith("IOS"))
		{
			sendPushNotification(code, device, title, devicetype);
		}
		else
		{
			sendGCMMessage(code, device, title);
		}
	}
	
	private static int id = 1;

	private static void sendGCMMessage(String code, String device, String title) 
	{
		Sender sender = new Sender(SENDER_ID);
		Message message = new Message.Builder()
		.addData("ratecode", code)
		.addData("title", title)
		.addData("id", ""+(id++))
		.build();
		
		try {
			Result result = sender.send(message, device, 1);
			String error = result.getErrorCodeName();
			if(error != null) Logger.info("ERROR GCM: "+error);
		} 
		catch (IOException e) 
		{
			e.printStackTrace();
		}
	}
	 
	private static boolean production = true;
	private final static String DIR = "WEB-INF/classes";
	
	private final static String CERTIFICATE_FILE = "/appsball_votenow.p12";
	private final static String CERTIFICATE_FILE_DEV = "/appsball_votenow_dev.p12";
	/*
	private final static String CERTIFICATE_FILE = "/angelapp.p12";
	private final static String CERTIFICATE_FILE_DEV = "/angelapp_developer.p12";
	*/
	
	public static InputStream getCertificateFile() throws Exception
	{
		return getCertificateInputStream(CERTIFICATE_FILE);
	}
	
	public static InputStream getCertificateFileDev() throws Exception
	{
		return getCertificateInputStream(CERTIFICATE_FILE_DEV);
	}
	
	private static InputStream getCertificateInputStream(String file) throws Exception
	{
		if(production) return NotificationUtil.class.getResourceAsStream(file);
		else 
		{
			System.out.println(new File(DIR+file).getAbsolutePath());
			return new FileInputStream(new File(DIR+file));
		}
	}
	
	public static void main(String[] args)
	{
		production = false;
		System.out.println(new File("x").getAbsolutePath());
		sendPushNotification("123456", "bd05577b463dc744c6fa8a304f24b85617d5ba8608995515cd551e2077756b9b", "Test title", "IOSD");
		// sendPushNotification("123456", "f29889c563f070d633b4b6df6072b6eaf45472cd1de49c1db3acd4c8410e23b8", "Test title", "IOS");
	}
	
	private static void sendPushNotification(String code, String device, String title, String devicetype) 
	{
		try
		{
			// InputStream is = Notification.class.getClassLoader().getResourceAsStream(CERTIFICATE_FILE);
			if(title.length()>45) title = title.substring(0,41)+"...";
			String alert = title;
			PushNotificationPayload payload = PushNotificationPayload.complex();
			payload.addAlert(alert);
			payload.addCustomDictionary("code", code);
			
			boolean production = !devicetype.startsWith("IOSD");
			sendPayload(payload, production, device);
		}
		 catch(Exception e)
		{
			e.printStackTrace();
		}
	}

	private static void sendPayload(PushNotificationPayload payload, boolean production, String device) throws Exception
	{

		InputStream is = production ? getCertificateFile() : getCertificateFileDev();
		PushedNotifications pns = Push.payload(payload, is, "A1S2d3f4,.", production, device);
		for (PushedNotification pn : pns) 
		{
			Logger.info("Pushed notification dev (production: "+production+"): "+pn.getException());
		}
	}
}
