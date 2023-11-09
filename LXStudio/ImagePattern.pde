import java.util.logging.Logger;
import java.util.logging.FileHandler;
import java.util.logging.SimpleFormatter;
import java.util.logging.Formatter;
import java.util.logging.LogRecord;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;

// Here is a fairly basic example pattern that renders a plane that can be moved
// across one of the axes.
@LXCategory("Ascension") public static class ImagePattern extends LXPattern
    implements UIDeviceControls<ImagePattern> {

  class ImageReader {
  private
    BufferedImage image;
  private
    int width;
  private
    int height;

  public
    ImageReader(String imageFilename) {
      try {
        // Read in the image
        image = ImageIO.read(new File(imageFilename));
        width = image.getWidth();
        height = image.getHeight();
        // System.out.println("Image width: " + width + ", height: " + height);
      } catch (IOException e) {
        e.printStackTrace();
      }
    }

  private
    int[] mirrorMap(int x, int y) {
      x = Math.floorMod(x, width * 2);
      y = Math.floorMod(y, height * 2);

      if (x >= width)
        x = (width * 2) - x - 1;
      if (y >= height)
        y = (height * 2) - y - 1;

      return new int[]{x, y};
    }

  private
    float lerp(float s, float e, float t) { return s + (e - s) * t; }

  public
    int[] getColor(float fx, float fy) {
      // fx = fx * 4.0;
      // fy = fy * 4.0;
      // System.out.println("fx: " + fx + ", fy: " + fy);
      // Map coordinates via mirrorMap
      int[] mappedTopLeft = mirrorMap((int)fx, (int)fy);
      // System.out.println("mappedTopLeft: " + mappedTopLeft[0] + ", " +
      //  mappedTopLeft[1]);

      // Bilinear interpolation
      int[] rgb = new int[3];
      for (int i = 0; i < 3; i++) { // For R, G, B values
        int x0 = mappedTopLeft[0];
        int y0 = mappedTopLeft[1];
        // Kinda hacky
        int x1 = x0 < width - 1 ? x0 + 1 : x0;
        int y1 = y0 < height - 1 ? y0 + 1 : y0;

        // Get the colors at the four corners
        float c00 = image.getRaster().getSample(x0, y0, i);
        float c10 = image.getRaster().getSample(x1, y0, i);
        float c01 = image.getRaster().getSample(x0, y1, i);
        float c11 = image.getRaster().getSample(x1, y1, i);
        // System.out.println("c00: " + c00 + ", c10: " + c10 + ", c01: " + c01
        // +
        //  ", c11: " + c11);

        // Calculate the fractional part
        float tx = fx - (int)fx;
        float ty = fy - (int)fy;
        // System.out.println("tx: " + tx + ", ty: " + ty);

        // Perform bilinear interpolation
        float interpolatedColor =
            lerp(lerp(c00, c10, tx), lerp(c01, c11, tx), ty);
        rgb[i] = (int)interpolatedColor;
        // System.out.println("interpolatedColor: " + interpolatedColor);
      }

      return rgb;
    }
  }

  class MyFormatter extends Formatter {
    @Override public String format(LogRecord record) {
      return record.getMessage() + "\n"; // Just return the message
    }
  }

  Logger logger;

  // CompoundParameter pCenterImgX =
  //     new CompoundParameter("pCenterImgX", 0, 0, 300)
  //         .setDescription("pCenterImgX");

  // CompoundParameter pCenterImgY =
  //     new CompoundParameter("pCenterImgY", 0, 0, 300)
  //         .setDescription("pCenterImgY");

  CompoundParameter sweepPeriodX =
      new CompoundParameter("sweepPeriodX", 12000, 2000, 60000)
          .setDescription("sweepPeriodX");

  CompoundParameter sweepPeriodY =
      new CompoundParameter("sweepPeriodY", 5500, 2000, 60000)
          .setDescription("sweepPeriodY");

  ObjectParameter<String> fname =
      new ObjectParameter<String>("filename",
                                  new String[]{
                                      "diag.jpeg",
                                      "diag_blurred.jpeg",
                                      "f_blue_red.jpg",
                                      "f_blue_red_blurred.jpg",
                                      "f_blue_yellow.jpeg",
                                      "f_blue_yellow_blurred.jpeg",
                                      "f_green.jpg",
                                      "f_green_blurred.jpg",
                                      "galaxy.jpg",
                                      "galaxy_blurred.jpg",
                                      "lion.png",
                                      "lion_blurred.png",
                                      "planet.jpeg",
                                      "planet2.jpeg",
                                      "planet2_blurred.jpeg",
                                      "planet_blurred.jpeg",
                                      "red_yellow.jpg",
                                      "red_yellow_blurred.jpg",
                                      "spiral.png",
                                      "spiral2.jpg",
                                      "spiral2_blurred.jpg",
                                      "spiral_blurred.png",
                                      "startrek.jpg",
                                      "startrek_blurred.jpg",
                                  })
          .setDescription("filename of image");
  String currentFname = "";

  // CompoundParameter pScaleImgX = new CompoundParameter("pScaleImgX", 1, -10,
  // 10)
  //                                    .setDescription("pScaleImgX");

  // CompoundParameter pScaleImgY = new CompoundParameter("pScaleImgY", 1, -10,
  // 10)
  //                                    .setDescription("pScaleImgY");

  // Different numbers that don't have high common denominators make the effect
  // look more unique
  SinLFO centerX = new SinLFO("centerX", 0, 1, sweepPeriodX);
  SinLFO centerY = new SinLFO("centerY", 0, 1, sweepPeriodY);
  ImageReader imageReader;

public
  ImagePattern(LX lx) {
    super(lx);
    this.setupLogger();

    // addParameter("pCenterImgX", this.pCenterImgX);
    // addParameter("pCenterImgY", this.pCenterImgY);
    addParameter("sweepPeriodX", this.sweepPeriodX);
    addParameter("sweepPeriodY", this.sweepPeriodY);
    addParameter("fname", this.fname);
    addModulator(this.centerX);
    addModulator(this.centerY);
    centerX.start();
    centerY.start();
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
    if (this.currentFname != this.fname.getObject()) {
      this.currentFname = this.fname.getObject();
      this.imageReader = new ImageReader(
          "/Users/chase/clones-third-party/LXStudio-AscensionPod/" +
          "image-read/" + this.currentFname);
    }
    // float xSpeed = 0.2f;
    // float ySpeed = 0.2f;
    // this.centerImgX += xSpeed; // * deltaMs / 1000;
    // this.centerImgY += ySpeed; // * deltaMs / 1000;
    float centerImgX = centerX.getValuef() * this.imageReader.width;
    float centerImgY = centerY.getValuef() * this.imageReader.height;
    for (LXPoint p : model.points) {
      float imgX =
          (((float)Math.atan2(p.zn - 0.5, p.xn - 0.5) / (PI)) + 1) * 100f;
      imgX += centerImgX;

      float imgY = p.yn * 100f;
      imgY += centerImgY;
      int[] rgb = this.imageReader.getColor(imgX, imgY);

      colors[p.index] = LXColor.rgb(rgb[0], rgb[1], rgb[2]);
    }
  }

  @Override public void buildDeviceControls(UI ui, UIDevice uiDevice,
                                            ImagePattern pattern) {
    uiDevice.setContentWidth(COL_WIDTH);
    addColumn(uiDevice, COL_WIDTH, "img", newDropMenu(pattern.fname),
              newKnob(pattern.sweepPeriodX), newKnob(pattern.sweepPeriodY));
  }
}