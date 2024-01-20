
import java.util.ArrayList;
import java.util.List;

// import entwined.pattern.colin_hunt.BleepBloop.Blip;
// import entwined.utils.SimplexNoise;
import heronarts.lx.LX;
import heronarts.lx.model.LXModel;
import heronarts.lx.model.LXPoint;

@LXCategory("Ascension") public
class BleepBloop extends LXPattern {
private
  Blip blip;

  float xOff = 0;
  float zOff = 0;
  float a = 0;
  float hue1 = (float)Math.random() * 360.0f;
  float hue2 = (hue1 + 100.0f) % 360.0f;

public
  BleepBloop(LX lx) {
    super(lx);

    // for every shrub, add a Blip
    // for (int shrubIdx = 0; shrubIdx < model.sub("SHRUB").size(); shrubIdx++)
    // {
    blip = new Blip();
    // System.out.println("BleepBloop - found " + shrubIdx + " shrubs");
    // }
    // System.out.println("BleepBLoop: hue 1 " +  hue1 + " hue 2 " + hue2);
  }

  @Override public void run(double deltaMs) {
    a += .01;
    hue1 = (hue1 + .05f) % 360.0f;
    hue2 = (hue2 + .05f) % 360.0f;

    xOff = (float)Math.cos(a);
    zOff = (float)Math.sin(a);
    for (LXPoint point : model.points) {
      colors[point.index] =
          LX.hsb(blip.getHue(), blip.getSat(point.x, point.y, point.z, a),
                 blip.getBrightness(point.x, point.y, point.z, a));
    }

    blip.update(deltaMs);

    if (a > LX.TWO_PI) {
      a = 0;
    }
  }

private
  class Blip {
    float height;
    float hue;
    // static final float baseHue;
    float speed;
    float tailLen;
    // boolean isTree;
    // int sculptureIdx;

    Blip() {
      height = 0;
      if (Math.random() < .70) {
        hue = hue1;
      } else {
        hue = hue2;
      }
      resetSpeed();
      tailLen = 100;
      // isTree = TorS;
    }

  private
    float getHue() { return hue; }

  private
    void resetSpeed() { speed = 3 + (9 * (float)Math.random()); }
  private
    float getSat(float x, float y, float z, float _a) {

      if (height - y < 0 || height - y > tailLen) {
        return 100;
      }

      // set saturation
      float toReturn = (100 / tailLen) * (height - y) + 15;

      // add simplex sparkle
      toReturn =
          toReturn + ((float)SimplexNoise.noise(x + xOff, z + zOff) * 50.0f);

      // constrin and return
      toReturn = Math.max(Math.min(toReturn, 100), 0);
      return toReturn;
    }

  private
    float getBrightness(float x, float y, float z, float _a) {

      // get rid of edge cases first, Dist > tail or < 0, THEN do the math
      if (height - y < 0 || height - y > tailLen) {
        return 0;
      }

      // get brightness
      float toReturn = -(100 / tailLen) * (height - y) + 100;

      // add simplex sparkle
      toReturn =
          toReturn +
          Math.abs(((float)SimplexNoise.noise(x + xOff, z + zOff) * 30.0f));

      // constrain and return
      toReturn = Math.max(Math.min(toReturn, 100), 0);
      return toReturn;
    }

  private
    void update(double _deltaMs) {
      height += (((float)_deltaMs) / 50) * speed;

      if (height >= tailLen * 2) {
        height = 0;
        resetSpeed();
        if (Math.random() < .70) {
          hue = hue1;
        } else {
          hue = hue2;
        }
      }
    }
  }
}
