package hu.hoplitasoft.votenow;

import hu.hoplitasoft.votenow.util.Fields;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Random;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.json.JSONArray;
import org.json.JSONObject;

public class WSTester 
{
	public final static String BASEURL = "http://localhost:8080/votenow";
	// public final static String BASEURL = "http://votenow-appsball2.rhcloud.com/";
	
	public static void main(String args[])
	{
		try
		{ 
			System.out.println("Starting");

			int number = new Random(System.currentTimeMillis()).nextInt(111111);

			String qcode = getAnswerFromString(createQuestion(number, "IOS", "IOS_DEVICE_ID_1"));
			System.out.println(qcode);

			number = new Random(System.currentTimeMillis()).nextInt(3);
			System.out.println("Waiting for: "+number);
			Thread.sleep(1000*number);
			
			String questionAnswer = createGetQuestion(qcode, "IOS", "IOS_DEVICE_ID_1");
			System.out.println(questionAnswer);
			String questionData = getAnswerFromString(questionAnswer);
			System.out.println(questionData);
			JSONObject obj = new JSONObject(questionData);
			System.out.println("Title: "+obj.getString(Fields.QUESTION.toString()));
			System.out.println("Time left: "+obj.getInt(Fields.TIME_FN.toString()));
			System.out.println("Multichoice: "+obj.getBoolean(Fields.MULTICHOICE.toString()));
			System.out.println("Anonymous: "+obj.getBoolean(Fields.ANONYMOUS.toString()));
			System.out.println("Choices: ");

			JSONArray array = obj.getJSONArray(Fields.CHOICES.toString());

			for(int i=0; i < array.length(); i++)
			{
				System.out.println("\t"+array.getString(i));
			}
			
			String rate = "1";
			for(int i=1; i < array.length();i++) rate += "0";
			
			String s = createAnswer(qcode, rate, "Béla", "message by Béla", "IOS", "IOS_DEVICE_ID_1");
			createAnswer(qcode, "00100", "Andris", "message by Andris", "IOS", "IOS_DEVICE_ID_2");
			createAnswer(qcode, "00010", "Csilla", "message by Csilla", "IOS", "IOS_DEVICE_ID_3");
			createAnswer(qcode, rate, "Anna", "message by Anna", "IOS", "IOS_DEVICE_ID_4");
			System.out.println(s);
			System.out.println(getAnswerFromString(s));
			
			System.out.println("0%                                                       100%");
			for(int i=0;i<60;i++)
			{
				System.out.print('.');
				// Thread.sleep(250);
				Thread.sleep(25);
			}
			System.out.println();
			String json = getAnswerFromString(createGetQuestionResult(qcode, "IOS_DEVICE_ID_1"));
			System.out.println(json);
			System.out.println("Generated qcode: "+qcode);
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}
	
	private static String createGetQuestionResult(String code, String deviceid) {
		String soapMessage = null;
		try {
			soapMessage = inputStreamToString(new FileInputStream("soap-getquestionresult.xml"));
			soapMessage = String.format(soapMessage, code, deviceid);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return inputStreamToString(getDataFromUrlAsInputStream(BASEURL+"/votenowWSDL", soapMessage));
	} 
	
	private static String createGetQuestion(String answer, String devicetype, String deviceid) {
		String soapMessage = null;
		try {
			soapMessage = inputStreamToString(new FileInputStream("soap-getquestion.xml"));
			soapMessage = String.format(soapMessage, answer, devicetype, deviceid);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return inputStreamToString(getDataFromUrlAsInputStream(BASEURL+"/votenowWSDL", soapMessage));
	} 


	private static String getAnswerFromString(String s) 
	{
		int i1 = s.indexOf("<return>")+"<return>".length();
		int i2 = s.indexOf("</return>");
		String answer = s.substring(i1,i2);
		return answer;
	}


	private static String createQuestion(int i, String devicetype, String deviceid) {
		String soapMessage = null;
		try {
			soapMessage = inputStreamToString(new FileInputStream("soap-question.xml"));
			
			JSONObject obj = new JSONObject();
			obj.put(Fields.EMAIL.toString(), "konfar.andras@gmail.com");
			obj.put(Fields.DEVICE_ID.toString(), deviceid);
			obj.put(Fields.DEVICE_TYPE.toString(), devicetype);
			obj.put(Fields.QUESTION.toString(), "Title << \" \' \\ ? "+i);
			obj.put(Fields.MULTICHOICE.toString(), true);
			obj.put(Fields.ANONYMOUS.toString(), false);
			obj.put(Fields.TIME_FN.toString(), 15);
			
			JSONArray array = new JSONArray();
			array.put("Choice 1 (\""+i+"\")");
			array.put("Choice 2 (\""+i+"\")");
			array.put("Choice 3 (\""+i+"\")");
			array.put("Choice 4 (\""+i+"\")");
			array.put("Choice 5 (\""+i+"\")");
			obj.put(Fields.CHOICES.toString(), array);
			
			soapMessage = String.format(soapMessage, obj.toString());
			
			System.out.println(soapMessage);
			
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return inputStreamToString(getDataFromUrlAsInputStream(BASEURL+"/votenowWSDL", soapMessage));
	}
	
	private static String createAnswer(String code, String rate, String name, String message, String devicetype, String deviceid)
	{
		String soapMessage = null;
		try {
			soapMessage = inputStreamToString(new FileInputStream("soap-answer.xml"));
			soapMessage = String.format(soapMessage, code, rate, name, message, devicetype, deviceid);
			System.out.println(soapMessage);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return inputStreamToString(getDataFromUrlAsInputStream(BASEURL+"/votenowWSDL", soapMessage));
	}
	
	
	private static InputStream getDataFromUrlAsInputStream(String url,
			String soapMessage) {
		
		try 
		{	
			HttpParams parameters = new BasicHttpParams();
			HttpConnectionParams.setConnectionTimeout(parameters, 20000);
			HttpConnectionParams.setSoTimeout(parameters, 20000);
			HttpClient client = new DefaultHttpClient(parameters);
			
			HttpPost httppost = new HttpPost(url.toString());
			
			httppost.addHeader("Content-Type", "text/xml; charset=UTF-8");
			
			if (soapMessage != null) httppost.setEntity(new StringEntity(soapMessage, "UTF-8"));
			
			HttpResponse response = client.execute(httppost);
			int statusCode = response.getStatusLine().getStatusCode();
			if (statusCode < 200 || statusCode > 299) {
				System.out.println("Status code error for url ("
						+ url.toString() + "): " + statusCode + " ("
						+ response.getStatusLine().getReasonPhrase() + ")");
			}
			InputStream is = response.getEntity().getContent();

			return is;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
	
	public static String inputStreamToString(InputStream is) {
		try {
			StringBuffer sb = new StringBuffer();
			BufferedReader br = new BufferedReader(new InputStreamReader(is),
					8192);
			String line = br.readLine();
			while (line != null) {
				sb.append(line + "\n");
				line = br.readLine();
			}
			return sb.toString();
		} catch (Exception e) {
			// e.printStackTrace();
		}
		return null;
	}
	
	public static InputStream getXmlResource(String xmlresource) {
		return WSTester.class.getClassLoader().getResourceAsStream(xmlresource);
	}
}
