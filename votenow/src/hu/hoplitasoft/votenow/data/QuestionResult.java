package hu.hoplitasoft.votenow.data;


import hu.hoplitasoft.votenow.util.Logger;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;

public class QuestionResult {
	
	private String title;
	private String email;
	private long device_id;
	private long[] rates;
	List<List<String>> messages;
	
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public long getDevice_id() {
		return device_id;
	}
	public void setDevice_id(long device_id) {
		this.device_id = device_id;
	}
	public long[] getRates() {
		return rates;
	}
	public void setRates(long[] rates) {
		this.rates = rates;
	}
	public List<List<String>> getMessages() {
		return messages;
	}
	public void setMessages(List<List<String>> messages) {
		this.messages = messages;
	}
	
	private String modus;
	private long numberOfRates;
	private String avarage;
	private String median;
	private String sdeviation;
	private List<String> percentages;
	
	public List<String> getPercentages() {
		return percentages;
	}
	
	public String getMedian() {
		return median;
	}
	public String getModus() {
		return modus;
	}
	public long getNumberOfRates() {
		return numberOfRates;
	}
	public String getAvarage() {
		return avarage;
	}
	public String getSdeviation() {
		return sdeviation;
	}
	
	public void calculate()
	{

		long maximum = -1;
		modus = "";
		
		long sum = 0;
		
		for(int i=0;i<rates.length;i++)
		{
			sum += rates[i]*(i+1);
			numberOfRates += rates[i];
			
			if(maximum == rates[i])
			{
				modus += ", "+(i+1);
			}
			if(maximum < rates[i])
			{
				maximum = rates[i];
				modus = ""+(i+1);
			}
		}
		
		median = "";
		long now = 0;
		long find = (numberOfRates+1) / 2;
		boolean two = numberOfRates%2 == 0;
		for(int i=0;i<rates.length;i++)
		{
			now += rates[i];
			if(now >= find)
			{
				median = ""+(i+1)+".0";
				if(two && now == find)
				{
					for(int j=i+1;j<rates.length;j++)
					{
						if(rates[j] != 0)
						{
							median = String.format("%.1f", 1.0 * (i+j+2)/2.0);
							break;
						}
					}
				}
				break;
			}
		}
		
		double avg = 1.0f * sum / numberOfRates;
		avarage = String.format("%.1f", avg);
		
		
		double sdevt = 0.0f;
		if(numberOfRates > 1)
		{
			for(int i=0;i<rates.length;i++)
			{
				sdevt += (i+1-avg)*(i+1-avg) * rates[i];
			}
			sdevt = Math.sqrt(sdevt/(numberOfRates-1));
		}
		sdeviation = String.format("%.1f", sdevt);
		
		percentages = new ArrayList<String>();
		
		if(numberOfRates == 0)
		{
			avarage = "-";
			median = "-";
			modus = "-";
			sdeviation = "-";
			for(int i=0;i<rates.length;i++) percentages.add("0.0");
		}
		else
		{	
			for(long rate : rates)
			{
				percentages.add(String.format("%.1f", 100.0*rate/numberOfRates));
			}
		}
	}
	
	public String createContentString() 
	{
		try
		{
		JSONObject json = new JSONObject();
		
		json.put("modus", modus);
		json.put("title", title);
		json.put("numberOfRates", ""+numberOfRates);
		json.put("avarage", avarage);
		json.put("median", median);
		json.put("sdeviation", ""+sdeviation);
		
		JSONArray ratesArray = new JSONArray();
		int i=0;
		for(long rate: rates)
		{
			JSONObject obj = new JSONObject();
			obj.put("rate", rate);
			obj.put("percentage", percentages.get(i));
			ratesArray.put(obj);
			i++;
		}
		json.put("rates", ratesArray);
		
		JSONArray messagesArray = new JSONArray();
		for(List<String> list: messages)
		{
			JSONArray array = new JSONArray();
			for(String str: list) array.put(str);
			messagesArray.put(array);
		}
		json.put("messages", messagesArray);
		
		return json.toString();
		}
		catch(Exception e)
		{
			Logger.info("ERROR IN JSON CREATION!");
			e.printStackTrace();
		}
		return "";
	}
	
	
}
