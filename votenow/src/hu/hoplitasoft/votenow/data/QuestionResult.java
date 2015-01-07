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
	private boolean multichoice;
	private boolean anonymous;
	List<String> choices;
	List<OneAnswer> oneAnswers;
	
	
	
	
	public List<OneAnswer> getOneAnswers() {
		return oneAnswers;
	}
	public void setOneAnswers(List<OneAnswer> oneAnswers) {
		this.oneAnswers = oneAnswers;
	}
	public List<String> getChoices() {
		return choices;
	}
	public void setChoices(List<String> choices) {
		this.choices = choices;
	}
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
	public boolean isMultichoice() {
		return multichoice;
	}
	public void setMultichoice(boolean multichoice) {
		this.multichoice = multichoice;
	}
	public boolean isAnonymous() {
		return anonymous;
	}
	public void setAnonymous(boolean anonymous) {
		this.anonymous = anonymous;
	}

	public List<String> names = new ArrayList<String>();
	public List<String> comments = new ArrayList<String>();
	
	public class AnswerCollection implements Comparable<AnswerCollection>
	{
		public String choice = null;
		public List<String> names = new ArrayList<String>();
		public List<String> comments = new ArrayList<String>();
		public String percentage = null;
		public int number = 0;
		
		@Override
		public int compareTo(AnswerCollection o) {
			return new Integer(o.number).compareTo(new Integer(number));
		}
	}
	
	List<AnswerCollection> answerCollection = new ArrayList<QuestionResult.AnswerCollection>();
	
	public void calculate()
	{
		for(int i = 0; i<choices.size();i++)
		{
			AnswerCollection ac = new AnswerCollection();
			answerCollection.add(ac);
			ac.choice = getChoices().get(i);
		}
		
		for(OneAnswer oa : oneAnswers)
		{
			boolean addedToComments = false;
			for(int i=0;i<oa.getAnswers().length();i++)
			{
				if(oa.getAnswers().charAt(i) != '0')
				{
					AnswerCollection ac = answerCollection.get(i);
					ac.number++;
					if(!anonymous)
					{
						ac.names.add(oa.getName());
					}
					
					if(!multichoice)
					{
						ac.comments.add(oa.getText());
					}
					else
					{
						if(!addedToComments)
						{
							comments.add(oa.getText());
							if(!anonymous) names.add(oa.getName());
							addedToComments = true;
						}
					}
				}
			}
		}
		
		java.util.Collections.sort(answerCollection);
		
		for(AnswerCollection ac: answerCollection)
		{
			ac.percentage = String.format("%.2f%%", 100.0 * ac.number / oneAnswers.size());  
		}
		
	}
	
	public String createContentString() 
	{
		try
		{
			JSONObject json = new JSONObject();
			json.put("title", title);
			json.put("numberOfRates", ""+oneAnswers.size());
			json.put("multichoice", multichoice);
			json.put("anonym", anonymous);
			
			{
				int length = Math.max(comments.size(), names.size());
				if(length > 0)
				{
					JSONArray comments_j = new JSONArray();
					for(int i=0;i<length;i++)
					{
						JSONObject object = new JSONObject();
						if(names.size()>i) object.put("name", names.get(i));
						if(comments.size()>i) object.put("comment", comments.get(i));
						comments_j.put(object);
					}
					json.put("comments", comments_j);
				}
			}
			
			JSONArray jsonarray = new JSONArray();
			for(AnswerCollection ac : answerCollection)
			{
				JSONObject acj = new JSONObject();
				jsonarray.put(acj);
				acj.put("choice", ac.choice);
				acj.put("number", ac.number);
				acj.put("percentage", ac.percentage);
				
				int length = Math.max(ac.comments.size(), ac.names.size());
				if(length > 0)
				{
					JSONArray comments_j = new JSONArray();
					for(int i=0;i<length;i++)
					{
						JSONObject object = new JSONObject();
						if(ac.names.size()>i) object.put("name", ac.names.get(i));
						if(ac.comments.size()>i) object.put("comment", ac.comments.get(i));
						comments_j.put(object);
					}
					acj.put("comments", comments_j);
				}
			}
			json.put("choices", jsonarray);
			
			return json.toString(4);
		}
		catch(Exception e)
		{
			Logger.info("ERROR IN JSON CREATION!");
			e.printStackTrace();
		}
		return "";
	}
	
	
	
}
