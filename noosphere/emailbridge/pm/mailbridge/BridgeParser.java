package pm.mailbridge;

import java.io.BufferedWriter;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Properties;
import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.mail.Address;
import javax.mail.BodyPart;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Part;
import javax.mail.Session;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.methods.GetMethod;
import org.xml.sax.SAXException;


public class BridgeParser {
	
	private static Properties properties = new Properties();
	private static SimpleDateFormat format = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss:S");
	
	public static void main(String[] args) {
	
		try {
			
			Class.forName("com.mysql.jdbc.Driver");
			properties.load(new FileInputStream("parser.properties"));
			
			//FileInputStream reader = new FileInputStream("msg.txt");
			//Message msg = new MimeMessage(Session.getInstance(new Properties()), reader);
			Message msg = new MimeMessage(Session.getInstance(new Properties()), System.in);
			
			log("Message parsed.");
			String[] refs = msg.getHeader("In-Reply-To");
			String[] refsBackup = msg.getHeader("References");
			String subject = msg.getSubject();
			String body;
			if ((body = getBody(msg)) != null) {
				String[] references = parseReferences(refs);
				if (references == null || !valid(references)) {
					log("Reference not found in header field In-Reply-To. Trying references.");
					references = parseReferences(refsBackup);
				}
				if (references == null) {
					replayError(msg, subject, body, "Your email could not be posted due to internal error. Please contact support. Error: NO REFERENCS DEFINED.");
				}
				if (references.length != 6 && references.length != 3) {
					replayError(msg, subject, body, "Your email could not be posted due to internal error. Please contact support. Error: REFERENCS FORMAT ERROR.");
				}
				if (references[0].equals("post")) {
					String table = references[1];
					String userId = references[2];
					String msgId = references[3];
					String objectId = references[4];
					String threadId = references[5];
					post(msg, userId, msgId, table, objectId, threadId, subject, body);
				} else if (references[0].equals("verify")) {
					String msgId = references[1];
					String key = references[2];
					verify(msgId, key);
				} else {
					replayError(msg, subject, body, "Your email could not be posted due to internal error. Please contact support. Error: REFERENCS COMMAND.");
				}
			} else {
				//Error - currently only plain text!
				replayError(msg, subject, body, "Only plain text or html messages are supported.");
			}
			
			log("All done.");
		
		} catch (Exception e) {
			log("Error occured: " + e.getMessage());
			e.printStackTrace();
		}
	}

	private static boolean valid(String[] references) {
		return (references[0].equals("post") && references.length == 6) || (references[0].equals("verify") && references.length == 3);
	}

	private static void log(String string) {
		System.out.println(format.format(new Date()) + " " + string);
	}

	private static void verify(String msgId, String key) throws SQLException, MessagingException, IOException {
		
		log("Verification of message " + msgId);
		HttpClient client = new HttpClient();
		HttpMethod method = new GetMethod(getUrl(msgId, key));
		client.executeMethod(method);
		log("Verification completed. msgId=" + msgId);
	}

	private static void post(Message msg, String userId, String msgId, String table, String objectId, String threadId, String subject, String body) throws SQLException, IOException, MessagingException {
		log("Posting message");
		
		String connStr = "jdbc:mysql://" + properties.getProperty("db");
		log("Database: " + connStr);
		Connection connection = DriverManager.getConnection(connStr, 
									properties.getProperty("user"), 
									properties.getProperty("pass"));
		
		int id = getNextMessageId(connection);
		long key = new Random(System.currentTimeMillis()).nextLong();
		
		Statement stmt = connection.createStatement();
		try {
			String bodySQL = body.replaceAll("'", "''").replaceAll("\\\\", "\\\\\\\\");
			String subjectSQL = subject.replaceAll("'", "''").replaceAll("\\\\", "\\\\\\\\");
			String values = id + "," + objectId + "," + msgId + ",now()," + userId + ",'" + subjectSQL + "','" + bodySQL + "','" + table + "'," + threadId + ",1," + key;
			String operation = "insert into messages_tmp (uid,objectid,replyto,created,userid,subject,body,tbl,threadid,visible,secret_key) values (" + values + ")";
			log(operation);
			stmt.executeUpdate(operation);
			stmt.close();
			
			if (!verifiedByAddress(connection, msg, String.valueOf(id), String.valueOf(key), userId, subject, body)) {
				sendVerificationEmail(msg, String.valueOf(id), String.valueOf(key), subject, body, userId, connection);
			}
		} finally {
			stmt.close();
		}
		
		connection.close();
	}
	
	

	private static boolean verifiedByAddress(Connection connection, Message msg, String msgId, String key, String userId, String subject, String body) throws MessagingException, HttpException, SQLException, IOException {
		log("Testing autoverify.");
		String addrs[] = msg.getHeader("To");
		for (int i = 0; i < addrs.length; i++) {
			InternetAddress address = new InternetAddress(addrs[i]);
			String to = address.getAddress();
			String verify = getVerificationPhrase(to);
			log("Autoverify to: " + to + " -> secret phrase=" + verify);
			if (verify != null) {
				return autoVerify(msg, connection, verify, msgId, key, userId, subject, body);
			}
		}
		return false;
	}

	private static boolean autoVerify(Message msg, Connection connection, String verify, String msgId, String key, String userId, String subject, String body) throws SQLException, HttpException, IOException, MessagingException {
		String select = "select prefs from users where uid=" + userId;
		log("Auto verification select: " + select);
		Statement stmt = connection.createStatement();
		try {
			stmt.execute(select);
			ResultSet result = stmt.getResultSet();
			if (result.next()) {
				String prefs = result.getString(1);
				String phrase = getPref(prefs, "secret_phrase");
				log("Auto verification of message: " + verify + "=?=" + phrase);
				if (verify.equals(phrase)) {
					log("Automatic verification of message " + msgId + " successful.");
					HttpClient client = new HttpClient();
					HttpMethod method = new GetMethod(getUrl(msgId, key));
					client.executeMethod(method);
					return true;
				}
			}
			return false;
		} finally {
			stmt.close();
		}
	}

	private static String getPref(String prefsIn, String string) {
		if (prefsIn == null) {
			return null;
		}
		String[] prefs = prefsIn.split(";");
		for (int i = 0; i < prefs.length; i++) {
			String[] pref = prefs[i].split("=");
			if (pref[0].equals(string)) {
				return pref[1];
			}
		}
		return null;
	}

	private static void sendVerificationEmail(Message msg, String id, String key, String subject, String body, String userId, Connection connection) throws SQLException, MessagingException, IOException {
		String usermail = resolveEmailAddress(msg, subject, body, userId, connection);
		//verification email
		String email = "From: " + properties.getProperty("message_from") + "\n";
		email += "To: " + usermail + "\n";
		email += "Message-ID: <verify." + id + "." + key + "@planetmath.org>\n";
		email += "Subject: " + properties.getProperty("message_verification_subject") + "\n\n";
		email += "In order to certify the submission, please simply reply to this message.\n";
		email += "Alternatively, you can use the following url to certify your submission: " + getUrl(String.valueOf(id), String.valueOf(key)) + "\n";
		email += "For future messages, you might edit preferences of your account (Your settings -> Preferences -> Email Bridge) and set a secret phrase for automatic verification. If you do so, you should email your " + 
					"posts to the following email address to avoid manual verification requirement: " + properties.getProperty("message_autoverify") + "\n\n";
		email += "Below you can find your submission details.\n\n";
		email += "Post subject: " + subject + "\n\n";
		email += "Post content: \n" + body + "\n";
		
		send(email, usermail);
		
		log("Verification email sent to " + usermail);
	}

	private static String getVerificationPhrase(String addr) {
		try {
			if (addr.indexOf(properties.getProperty("verification-delim")) != -1) {
				int begin = addr.indexOf(properties.getProperty("verification-delim")) + 1;
				int end = addr.lastIndexOf('@');
				log("Autoverifucation phrase: substring " + begin + "-" + end + " of string " + addr);
				if (begin >= end) {
					return null;
				}
				String phrase = addr.substring(begin, end);
				return !phrase.equals("") ? phrase : null;
			}
		} catch (Exception e ) {
			e.printStackTrace();
		}
		return null;
	}

	private static String getUrl(String msgId, String key) {
		return properties.getProperty("main_url") + "/?op=verify&msg=" + msgId + "&key=" + key;
	}

	private static int getNextMessageId(Connection connection) throws SQLException {
		Statement stmt = connection.createStatement();
		try {
			stmt.executeUpdate("insert into " + properties.getProperty("messages_sequence") + " values ()");
			ResultSet generated = stmt.getGeneratedKeys();
			generated.next();
			int id = generated.getInt(1);
			stmt.close();
			stmt = connection.createStatement();
			stmt.executeUpdate("delete from " + properties.getProperty("messages_sequence") + " where val < " + id);
			stmt.close();
			stmt = connection.createStatement();
			return id;
		} finally {
			stmt.close();
		}
	}

	private static String resolveEmailAddress(Message msg, String subject, String body, String userId, Connection connection) throws SQLException, MessagingException, IOException {
		Statement stmt = connection.createStatement();
		try {
			String select = "select email from users where uid=" + userId;
			stmt.execute(select);
			ResultSet set = stmt.getResultSet();
			if (set.next()) {
				return set.getString(1);
			} else {
				replayError(msg, subject, body, "Internal error encountered. Contact support.");
			}
			return null;
		} finally {
			stmt.close();
		}
	}

	private static String[] parseReferences(String[] refs) {
		if (refs == null || refs.length == 0) {
			return null;
		}
		for (int i = 0; i < refs.length; i++) {
			String regex = "<.*>";
			Pattern p  = Pattern.compile(regex);
			Matcher m = p.matcher(refs[i]);
			while (m.find()) {
				String match = m.group();
				System.out.println("Reference parsed: " + match);
				int b = match.indexOf("<");
				int e = match.indexOf("@");
				if (b != -1 && e != -1) {
					String str = match.substring(b + 1, e).replaceAll(" ", "");
					String[] references = str.split("\\.");
					if (valid(references)) {
						return references;
					}
				}
			}
		}
		return null;
	}

	private static String getBody(Part msg) throws MessagingException, IOException, SAXException {
		String body = getBody(msg, "text/plain");
		log("Body from text/plain:");
		log(body);
		if (body == null) {
			body = getBody(msg, "text/html");
			log("HTML:");
			log(body);
			body = body.replaceAll("\\<.*?\\>", "");
			log("Parsed:");
			log(body);
		}
		return body;
	}
	
	private static String getBody(Part msg, String contentType) throws MessagingException, IOException, SAXException {
		if (msg.getContentType().startsWith(contentType)) {
			return msg.getContent().toString();
		} else if (msg.getContentType().startsWith("multipart/")) {
			MimeMultipart multi = (MimeMultipart) msg.getContent();
			for (int i = 0; i < multi.getCount(); i++) {
				BodyPart part = multi.getBodyPart(i);
				String content = getBody(part);
				if (content != null) {
					return content;
				}
			}
		}
		return null;
	}

	private static void replayError(Message msg, String subject, String body, String string) throws SQLException, MessagingException, IOException {
		log("Sending error to " + string);
		log("Message:\n" + msg.toString());
		
		String connStr = "jdbc:mysql://" + properties.getProperty("db");
		//System.out.println("Database: " + connStr);
		Connection connection = DriverManager.getConnection(connStr, 
									properties.getProperty("user"), 
									properties.getProperty("pass"));
		
		String usermail = null;
		Address[] from = msg.getFrom();
		for (int i = 0; i < from.length; i++) {
			if (from[i] instanceof InternetAddress) {
				usermail = ((InternetAddress)from[i]).getAddress();
			}
		}
		if (usermail == null) {
			return;
		}
		
		//verification email
		String email = "From: " + properties.getProperty("message_from") + "\n";
		email += "To: " + usermail + "\n";
		email += "Subject: Submission error\n";
		email += "Your submission encountered a problem:\n" + string + "\n\n";
		//email += "Post subject: " + subject + "\n\n";
		//email += "Post content: \n" + body + "\n";
		
		//System.out.println("Message is:");
		//System.out.println(email);
		
		send(email, usermail);
		
		System.exit(0);
	}
	
	private static void send(String email, String address) throws IOException {
		String cmd = properties.getProperty("sendmailcmd") + " " + address;
		log("CMD IS: " + cmd);
		Process process = Runtime.getRuntime().exec(cmd);
		BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(process.getOutputStream()));
		writer.write(email);
		writer.flush();
		writer.close();
	}
}
