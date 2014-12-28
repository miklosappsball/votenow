package hu.hoplitasoft.votenow.util;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;

public class IOUtil {
	
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
		}
		return null;
	}
	
}
