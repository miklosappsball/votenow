package hu.hoplitasoft.votenow;

import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.jws.soap.SOAPBinding.Style;

@WebService
@SOAPBinding(style = Style.RPC)
public interface IWebservice {
	
	public String test();
	public String addQuestion(String jsonStr);
	public String addAnswer(String code, String answers, String name, String message, String deviceType, String deviceId);
	public String getQuestion(String code, String deviceType, String deviceId);
	public String getQuestionResult(String code, String deviceId);
}
