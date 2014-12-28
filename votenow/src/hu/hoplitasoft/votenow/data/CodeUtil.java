package hu.hoplitasoft.votenow.data;


import hu.hoplitasoft.votenow.util.Logger;

import java.util.Random;

public class CodeUtil {
	
	private static int length = 6;
	private static int maxSame = 3;
	
	private final static Random rnd = new Random();
	private final static char[] characters = {'0','1','2','3','4','5','6','7','8','9'};
	
	public static String generateCode() 
	{
		for(int i=0;i<maxSame;i++)
		{
			String s = generateRandomCode();
			if(!DBUtil.isAlreadyCode(s))
			{
				return s;
			}
		}
		
		length ++;
		Logger.info(" ----------------------- CODE LENGTHS NOW: "+length+" -----------------------------");
		return generateCode();
	}
	
	private static String generateRandomCode()
	{
		StringBuffer sb = new StringBuffer();
		for(int i=0;i<length;i++)
		{
			sb.append(characters[rnd.nextInt(characters.length)]);
		}
		
		return sb.toString();
	}
	
}
