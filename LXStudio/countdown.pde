import java.util.logging.Logger;
import java.util.logging.FileHandler;
import java.util.logging.SimpleFormatter;
import java.util.logging.Formatter;
import java.util.logging.LogRecord;

// Here is a fairly basic example pattern that renders a plane that can be moved
// across one of the axes.
@LXCategory(
    "Ascension") public static class CountdownPattern extends LXPattern {
  class MyFormatter extends Formatter {
    @Override public String format(LogRecord record) {
      return record.getMessage() + "\n"; // Just return the message
    }
  }

  Logger logger;

  CompoundParameter brightnessPeriod =
      new CompoundParameter("brightnessPeriod", 2000, 100, 5000)
          .setDescription("rotation period");

  ColorParameter myColor = new ColorParameter("Color", LXColor.RED);

  TriangleLFO brightness = new TriangleLFO("Tri Wave", 0, 1, brightnessPeriod);
  BooleanParameter restart = new BooleanParameter("Restart", false);

public
  CountdownPattern(LX lx) {
    super(lx);
    addParameter("brightnessPeriod", this.brightnessPeriod);
    addParameter("myColor", this.myColor);
    restart.setMode(BooleanParameter.Mode.MOMENTARY);
    addParameter("restart", this.restart);
    addModulator(brightness);

    brightness.start();
    LX.error("test2");
    this.setupLogger();
  }

  void setupLogger() {
    try {
      FileHandler fh;
      this.logger = Logger.getLogger("MyLog");
      fh = new FileHandler("/tmp/mylog.log", true);
      this.logger.addHandler(fh);
      MyFormatter formatter = new MyFormatter();
      fh.setFormatter(formatter);
      // fh.setFlushOnWrite(true);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  void log(String message) { this.logger.info(message); }

public
  void run(double deltaMs) {
    if (this.restart.getValueb()) {
      this.brightness.reset();
      this.brightness.start();
    }
    float bright = this.brightness.getValuef() * 100;
    for (LXPoint p : model.points) {
      colors[p.index] =
          LXColor.hsb(this.myColor.hue.getValuef(),
                      this.myColor.saturation.getValuef(), bright);
    }

    // log("brightness: " + bright + "vs" + this.myColor.brightness.getValuef()
    // +
    //     "hue" + this.myColor.hue.getValuef());
  }
}