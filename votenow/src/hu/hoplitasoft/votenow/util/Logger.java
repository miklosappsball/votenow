package hu.hoplitasoft.votenow.util;

public class Logger 
{
	private static java.util.logging.Logger logger = java.util.logging.Logger.getLogger("hu.hoplitasoft.votenow");
	
	public static void info(String s)
	{
		logger.info(s);
	}
}
