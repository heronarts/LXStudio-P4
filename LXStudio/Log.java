import java.util.logging.*;
import java.util.logging.Logger;

public class Log {

  private static Logger logger;

  static class MyFormatter extends Formatter {
    @Override
    public String format(LogRecord record) {
      return record.getMessage() + "\n"; // Just return the message
    }
  }

  // public Log() { this.setupLogger(); }

  private static void setupLogger() {
    try {
      FileHandler fh;
      Log.logger = Logger.getLogger("MyLog");
      fh = new FileHandler("/tmp/mylog.log", true);
      Log.logger.addHandler(fh);
      MyFormatter formatter = new MyFormatter();
      fh.setFormatter(formatter);
      // fh.setFlushOnWrite(true);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  public static void log(String message) {
    if (Log.logger == null) {
      Log.setupLogger();
    }

    Log.logger.info(message);
  }
}