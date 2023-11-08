import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;

public class ImageReader {
  private BufferedImage image;
  private int width;
  private int height;

  public ImageReader(String imageFilename) {
    try {
      // Read in the image
      image = ImageIO.read(new File(imageFilename));
      width = image.getWidth();
      height = image.getHeight();
      System.out.println("Image width: " + width + ", height: " + height);
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  private int[] mirrorMap(int x, int y) {
    x = Math.floorMod(x, width * 2);
    y = Math.floorMod(y, height * 2);

    if (x >= width)
      x = (width * 2) - x - 1;
    if (y >= height)
      y = (height * 2) - y - 1;

    return new int[] {x, y};
  }

  private float lerp(float s, float e, float t) { return s + (e - s) * t; }

  public int[] getColor(float fx, float fy) {
    System.out.println("fx: " + fx + ", fy: " + fy);
    // Map coordinates via mirrorMap
    int[] mappedTopLeft = mirrorMap((int)fx, (int)fy);
    System.out.println("mappedTopLeft: " + mappedTopLeft[0] + ", " +
                       mappedTopLeft[1]);

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
      System.out.println("c00: " + c00 + ", c10: " + c10 + ", c01: " + c01 +
                         ", c11: " + c11);

      // Calculate the fractional part
      float tx = fx - (int)fx;
      float ty = fy - (int)fy;
      System.out.println("tx: " + tx + ", ty: " + ty);

      // Perform bilinear interpolation
      float interpolatedColor =
          lerp(lerp(c00, c10, tx), lerp(c01, c11, tx), ty);
      rgb[i] = (int)interpolatedColor;
      System.out.println("interpolatedColor: " + interpolatedColor);
    }

    return rgb;
  }

  public static void main(String[] args) {
    ImageReader reader = new ImageReader("lion.png");
    int[] color = reader.getColor(330.3f, -20f);
    System.out.println("Red: " + color[0] + ", Green: " + color[1] +
                       ", Blue: " + color[2]);
  }
}
