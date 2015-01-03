package hu.hoplitasoft.votenow;

import hu.hoplitasoft.votenow.data.DBUtil;
import hu.hoplitasoft.votenow.util.Logger;

import java.sql.Timestamp;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;


public class QuestionCloser 
{
	private static Timer timer = new Timer();
	private static boolean started = false;
	private final static int MAX_POLL_TIME = 20;
	private static boolean stop = false;

	public static void findNextQuestionToCloseStart()
	{
		if(!started)
		{
			started = true;
			Logger.info("closing votenows");
			DBUtil.closeAlreadyFinishedQuestions();
			findNextQuestionToClose();
		}
	}


	public static void findNextQuestionToClose()
	{
		synchronized (timer) 
		{
			System.out.println("findNextQuestionToClose!!!");
			Timestamp t = new Timestamp(System.currentTimeMillis()+1000*MAX_POLL_TIME);
			List<Timestamp> list = DBUtil.findNextQuestions();
			if(list.size()>0) 
			{
				Timestamp t2 = new Timestamp(list.get(0).getTime()+2000);
				if(t.after(t2)) t = t2;
			}
			
			System.out.println("next time: "+t);
			timer.schedule(new TimerTask() {
				@Override
				public void run() 
				{
					if(!stop)
					{
						System.out.println("Running!!!");
						DBUtil.closeAlreadyFinishedQuestions();
						findNextQuestionToClose();
					}
				}
			}, t);
		}
	}


	public static void stop() {
		stop = true;
	}

}
