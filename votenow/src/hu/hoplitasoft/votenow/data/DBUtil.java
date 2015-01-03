package hu.hoplitasoft.votenow.data;

import hu.hoplitasoft.votenow.QuestionCloser;
import hu.hoplitasoft.votenow.Webservice;
import hu.hoplitasoft.votenow.util.EmailListener;
import hu.hoplitasoft.votenow.util.Fields;
import hu.hoplitasoft.votenow.util.Logger;
import hu.hoplitasoft.votenow.util.NotificationUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import org.json.JSONArray;
import org.json.JSONObject;


public class DBUtil {
	
	private static Connection connection = null;
	
	private static Connection getConnection() throws NamingException, SQLException
	{
		if(connection == null)
		{
			Context initContext = new InitialContext();
			Context envContext  = (Context)initContext.lookup("java:/comp/env");
			DataSource ds = (DataSource)envContext.lookup("jdbc/MySQLDS");
			Connection conn = ds.getConnection();
			connection = conn;
		}
		return connection;
	}
	
	public static String addQuestion(String jsonString) 	
	{
		try
		{
			JSONObject object = new JSONObject(jsonString);
			
			String deviceId = object.getString(Fields.DEVICE_ID.toString());
			String deviceType = object.getString(Fields.DEVICE_TYPE.toString());
			String title = object.getString(Fields.QUESTION.toString());
			String email = object.getString(Fields.EMAIL.toString());
			boolean multichoice = object.getBoolean(Fields.MULTICHOICE.toString());
			boolean anonym = object.getBoolean(Fields.ANONYMOUS.toString());
			JSONArray choices = object.getJSONArray(Fields.CHOICES.toString());
			
			int timefn = object.getInt(Fields.TIME_FN.toString());
			Timestamp date = new Timestamp(System.currentTimeMillis()+timefn*1000);
			
			if(title.length() == 0) return Webservice.ERROR_START+"Please give a question!";
			if(!EmailListener.isEmailValid(email)) return Webservice.ERROR_START+"Invalid email address!";
			if(title.length() > 500) return Webservice.ERROR_START+"The question is too long!";
			if(email.length() > 60) return Webservice.ERROR_START+"The email address is too long!";
			if(choices.length() < 2) return Webservice.ERROR_START+"Not enough choices!";
			
			long device_id = DBUtil.getDeviceId(deviceId, deviceType);
			
			String code = CodeUtil.generateCode();
			String insertStr = "INSERT INTO question (email, title, endTime, code, anonym, multichoice, closed, device_id) VALUES(?, ?, ?, ?, ?, ?, 0, ?);";
			PreparedStatement statement = getConnection().prepareStatement(insertStr, Statement.RETURN_GENERATED_KEYS);
			statement.setString(1, email);
			statement.setString(2, title);
			statement.setTimestamp(3, date);
			statement.setString(4, code);
			statement.setBoolean(5, anonym);
			statement.setBoolean(6, multichoice);
			statement.setLong(7, device_id);
			statement.execute();
			
			ResultSet rs = statement.getGeneratedKeys(); 
			long qid = -1; 
			if(rs.next())
			{
				qid = rs.getLong(1);
			}
			statement.close();
			if(qid < 0)
			{
				return Webservice.ERROR_START+"Internal server error!";
			}
			
			for(int i = 0; i<choices.length(); i++)
			{
				String s = choices.getString(i);
				
				if(s.length() > 500) s = s.substring(0, 500);
				
				insertStr = "INSERT INTO chosable (question_id, chosable_number, text) VALUES (?, ?, ?);";
				statement = getConnection().prepareStatement(insertStr);
				statement.setLong(1, qid);
				statement.setInt(2, i);
				statement.setString(3, s);
				statement.execute();
				statement.close();
			}
			
			QuestionCloser.findNextQuestionToCloseStart();
			EmailListener.sendEmail(email, "Code: "+code, EmailListener.createEmailCode(code,title));
			
			return code;
		}
		catch(Exception e)
		{
			e.printStackTrace();
			return Webservice.ERROR_START+e.getMessage();
		}
	}

	public static String addAnswer(String code, String answers, String name, String message, long device_id) 
	{
		try
		{
			PreparedStatement statement = getConnection().prepareStatement("SELECT id, endTime, closed FROM question WHERE code=?;");
			statement.setString(1, code);
			ResultSet resultSet = statement.executeQuery();
			if(resultSet.next())
			{
				if(resultSet.getBoolean("closed") || resultSet.getTimestamp("endTime").getTime() - System.currentTimeMillis() < 0)
				{
					return Webservice.ERROR_START+"The question has expired!";
				}
				long l = resultSet.getLong("id");
				
				resultSet = statement.executeQuery("SELECT * FROM answer WHERE question_id="+l+" AND device_id='"+device_id+"';");
				if(resultSet.first()) return Webservice.ERROR_START+"You have already answered this question"; 
				statement.close();
				
				statement = getConnection().prepareStatement("INSERT INTO answer (question_id, answers, message, device_id, name) VALUES(?, ?, ?, ?, ?);");
				statement.setLong(1, l);
				statement.setString(2, answers);
				statement.setString(3, message);
				statement.setLong(4, device_id);
				if(name.length()>=50) name = name.substring(0, 50);
				statement.setString(5, name);
				statement.executeUpdate();
				statement.close();
				return "Successful rating";
			}
			else
			{
				statement.close();
				return "No such question";
			}
			
		}
		catch(Exception e)
		{
			e.printStackTrace();
			return Webservice.ERROR_START+e.getMessage();
		}
	}

	public static boolean isAlreadyCode(String s) {
		try
		{
			PreparedStatement statement = getConnection().prepareStatement("SELECT * FROM question WHERE code=?;");
			statement.setString(1, s);
			ResultSet resultSet = statement.executeQuery();
			boolean ret = resultSet.first();
			statement.close();
			return ret;
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return true;
	}

	public static List<Timestamp> findNextQuestions() 
	{
		try
		{
			List<Timestamp> list = new ArrayList<Timestamp>();
			PreparedStatement statement = getConnection().prepareStatement("SELECT * FROM question WHERE endTime BETWEEN NOW() AND ADDTIME(NOW(), '0 1:0:0') AND closed=0 ORDER BY endTime ASC LIMIT 10;");
			ResultSet resultSet = statement.executeQuery();
			
			while(resultSet.next())
			{
				Timestamp date = resultSet.getTimestamp("endTime");
				list.add(date);
			}

			statement.close();
			return list;
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return null;
	}
	
	public static void closeAlreadyFinishedQuestions()
	{
		try
		{
			PreparedStatement statement = getConnection().prepareStatement("SELECT * FROM question WHERE endTime < NOW() AND closed=0 ORDER BY endTime;");
			ResultSet resultSet = statement.executeQuery();
			
			while(resultSet.next())
			{
				closeWithId(resultSet.getString("code"));
			}
			statement.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}
	
	private static void closeWithId(String code) {
		try
		{
			Logger.info("Closing question with code: "+code);
			PreparedStatement statement = getConnection().prepareStatement("UPDATE question SET closed=1 WHERE code=?;");
			statement.setString(1, code);
			statement.executeUpdate();
			
			QuestionResult questionResult = getQuestionResult(code);
			EmailListener.sendEmail(questionResult.getEmail(), "Result of question", EmailListener.createEmailContent(questionResult));
			statement.close();
			
			statement = getConnection().prepareStatement("SELECT * FROM device WHERE id=?;");
			statement.setLong(1, questionResult.getDevice_id());
			ResultSet rs = statement.executeQuery();
			if(rs.first())
			{
				NotificationUtil.notificate(code, rs.getString("device_id"), rs.getString("device_type"), questionResult.getTitle());
			}
			statement.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}

	public static String getQuestion(String code, long did) 
	{
		try
		{
			PreparedStatement statement = getConnection().prepareStatement("SELECT * FROM question WHERE code=?;");
			statement.setString(1, code);
			ResultSet resultSet = statement.executeQuery();
			
			boolean r = resultSet.first();
			if(r)
			{
				long timeLeft = resultSet.getTimestamp("endTime").getTime()-System.currentTimeMillis();
				boolean closed = resultSet.getBoolean("closed");
				String s = resultSet.getString("title");
				long qid = resultSet.getLong("id");
				boolean multichoice = resultSet.getBoolean("multichoice");
				boolean anonym = resultSet.getBoolean("anonym");
				
				statement.close();
				
				statement = getConnection().prepareStatement("SELECT * FROM answer WHERE question_id=? AND device_id=?;");
				statement.setLong(1, qid);
				statement.setLong(2, did);
				ResultSet rs2 = statement.executeQuery();
				if(rs2.first())
				{
					statement.close();
					return Webservice.ERROR_START+"You have already rated this question";
				}
				
				
				if(timeLeft<0 || closed)
				{
					statement.close();
					return Webservice.ERROR_START+"The question has expired!";
				}
				
				statement.close();
				
				JSONObject object = new JSONObject();
				object.put(Fields.QUESTION.toString(), s);
				
				statement = getConnection().prepareStatement("SELECT * FROM chosable where question_id = ? ORDER BY id;");
				statement.setLong(1, qid);
				ResultSet rs = statement.executeQuery();
				JSONArray array = new JSONArray();
				while(rs.next())
				{
					String cs = rs.getString("text");
					array.put(cs);
				}
				
				object.put(Fields.CHOICES.toString(), array);
				object.put(Fields.TIME_FN.toString(), timeLeft/1000);
				object.put(Fields.ANONYMOUS.toString(), anonym);
				object.put(Fields.MULTICHOICE.toString(), multichoice);
				
				return object.toString();
			}
			else
			{
				statement.close();
				return Webservice.ERROR_START+"Invalid code!";
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			return Webservice.ERROR_START+e.getMessage();
		}
	}

	public static long getDeviceId(String deviceId, String deviceType) throws Exception
	{
		try
		{
			PreparedStatement statement1 = getConnection().prepareStatement("SELECT id FROM device WHERE device_id=?;");
			statement1.setString(1, deviceId);
			ResultSet resultSet = statement1.executeQuery();
			boolean r = resultSet.first();
			if(r)
			{	
				long id = resultSet.getLong("id");
				statement1.close();
				return id;
			}
			else
			{
				PreparedStatement statement = getConnection().prepareStatement("INSERT INTO device (device_id, device_type) VALUES(?, ?);");
				statement.setString(1, deviceId);
				statement.setString(2, deviceType);
				statement.executeUpdate();
				statement.close();
				
				resultSet = statement1.executeQuery();
				r = resultSet.first();
				
				if(r)
				{
					long id = resultSet.getLong("id");
					statement1.close();
					return id;
				}
				else
				{
					statement1.close();
					throw new Exception("Data base error! Please connect to the developers!");
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			throw e;
		}
	}
	
	public final static int NUMBER_OF_RATE_SELECTION = 5;
	
	public static QuestionResult getQuestionResult(String code) {
		try
		{
			PreparedStatement statement = getConnection().prepareStatement("SELECT * FROM question where code=?;");
			statement.setString(1, code);
			ResultSet resultset = statement.executeQuery();
			if(!resultset.first())
			{
				statement.close();
				return null;
			}
			QuestionResult result = new QuestionResult();
			result.setTitle(resultset.getString("title"));
			result.setEmail(resultset.getString("email"));
			result.setDevice_id(resultset.getLong("device_id"));
			result.setMultichoice(resultset.getBoolean("multichoice"));
			result.setAnonymous(resultset.getBoolean("anonym"));
			long qid = resultset.getLong("id");
			statement.close();
			
			List<String> choices = new ArrayList<String>();
			statement = getConnection().prepareStatement("SELECT * FROM chosable WHERE question_id = ? ORDER BY id;");
			statement.setLong(1, qid);
			resultset = statement.executeQuery();
			while(resultset.next())
			{
				choices.add(resultset.getString("text"));
			}
			statement.close();
			result.setChoices(choices);
			
			statement = getConnection().prepareStatement("SELECT * FROM answer WHERE question_id = ?;");
			statement.setLong(1, qid);
			
			List<OneAnswer> answers = new ArrayList<OneAnswer>();
			ResultSet rs = statement.executeQuery();
			while(rs.next())
			{
				OneAnswer oa = new OneAnswer();
				answers.add(oa);
				oa.setText(rs.getString("message"));
				oa.setAnswers(rs.getString("answers"));
				oa.setName(rs.getString("name"));
			}
			result.setOneAnswers(answers);
			statement.close();
			
			result.calculate();
			return result;
		}
		catch(Exception e)
		{
			e.printStackTrace();
			return null;
		}
	}
	
}
