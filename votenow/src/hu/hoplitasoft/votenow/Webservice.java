package hu.hoplitasoft.votenow;

import hu.hoplitasoft.votenow.data.DBUtil;
import hu.hoplitasoft.votenow.data.QuestionResult;

import javax.jws.WebService;


@WebService
public class Webservice implements IWebservice {
	
	public final static String ERROR_START = "ERROR:";
	
	@Override
	public String test() 
	{
		return "Teszt szöveg";
	}
	
	@Override
	public String addQuestion(String jsonStr) 
	{
		try {
			
			String answer = DBUtil.addQuestion(jsonStr);
			return answer;
		} catch (Exception e) {
			return ERROR_START+e.getMessage();
		}
	}
	
	@Override
	public String getQuestionResult(String code, String deviceId) 
	{
		try {
			QuestionResult result = DBUtil.getQuestionResult(code);
			if(result == null) return ERROR_START+"Could not fint the question in the database";
			return result.createContentString();
		} catch (Exception e) {
			return ERROR_START+e.getMessage();
		}
	}
	
	@Override
	public String addAnswer(String code, String answers, String name, String message, String deviceType, String deviceId)
	{	
		try {
			if(message.length() > 500) return ERROR_START+"The message is too long!";
			long did = DBUtil.getDeviceId(deviceId, deviceType);
			String errorString = DBUtil.addAnswer(code, answers, name, message, did);
			return errorString;
		} catch (Exception e) {
			return ERROR_START+e.getMessage();
		}
	}
	
	@Override
	public String getQuestion(String code, String deviceType, String deviceId)
	{
		try {
			if(deviceType == null || deviceType.length() == 0 || deviceId == null || deviceId.length() == 0)
			{
				return ERROR_START+"Old application version, please update!";
			}
			long did = DBUtil.getDeviceId(deviceId, deviceType);
			String answer = DBUtil.getQuestion(code, did);
			return answer;
		}catch (Exception e) {
			return ERROR_START+e.getMessage();
		}
	}
}
