package hu.hoplitasoft.votenow.util;

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
			sendPushNotification(code, device, title);
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

	private final static String CERTIFICATE_FILE = "/appsball_votenow.p12";
	private final static String CERTIFICATE_FILE_DEV = "/appsball_votenow_dev.p12";

	private static void sendPushNotification(String code, String device, String title) 
	{
		try
		{
			// InputStream is = Notification.class.getClassLoader().getResourceAsStream(CERTIFICATE_FILE);
			if(title.length()>45) title = title.substring(0,41)+"...";
			String alert = title;
			PushNotificationPayload payload = PushNotificationPayload.complex();
			payload.addAlert(alert);
			payload.addCustomDictionary("code", code);
			// PushedNotifications pns = Push.combined(msg, 1, "", is, "A1S2d3f4,.", true, "1586f354a56140fdc9e8a65b68805ff854407b3be4badc9794dcb17b2c257aa5");

			InputStream is = NotificationUtil.class.getResourceAsStream(CERTIFICATE_FILE);
			PushedNotifications pns = Push.payload(payload, is, "A1S2d3f4,.", false, device);
			for (PushedNotification pn : pns) 
			{
				Logger.info("Pushed notification dev: "+pn.getException());
			}

			is = NotificationUtil.class.getResourceAsStream(CERTIFICATE_FILE_DEV);
			pns = Push.payload(payload, is, "A1S2d3f4,.", true, device);
			for (PushedNotification pn : pns) 
			{
				Logger.info("Pushed notification: "+pn.getException());
			}
		}
		 catch(Exception e)
		{
			e.printStackTrace();
		}
	}
}
