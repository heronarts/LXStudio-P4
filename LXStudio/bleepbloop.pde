package entwined.pattern.colin_hunt;

import java.util.ArrayList;
import java.util.List;

import entwined.core.TSBufferedPattern;
// import entwined.pattern.colin_hunt.BleepBloop.Blip;
import entwined.utils.SimplexNoise;
import heronarts.lx.LX;
import heronarts.lx.model.LXModel;
import heronarts.lx.model.LXPoint;

/**
Blips go up
*/
public
class BleepBloop extends TSBufferedPattern {
private
  List<Blip> blips = new ArrayList<Blip>();

  float xOff = 0;
  float zOff = 0;
  float a = 0;
  float hue1 = (float)Math.random() * 360.0f;
  float hue2 = (hue1 + 100.0f) % 360.0f;

public
  BleepBloop(LX lx) {
    super(lx);

    // for every shrub, add a Blip
    for (int shrubIdx = 0; shrubIdx < model.sub("SHRUB").size(); shrubIdx++) {
      blips.add(new Blip(false, shrubIdx));
      // System.out.println("BleepBloop - found " + shrubIdx + " shrubs");
    }
    // System.out.println("BleepBLoop: hue 1 " +  hue1 + " hue 2 " + hue2);
  }

  @Override public void bufferedRun(double deltaMs) {
    a += .01;
    hue1 = (hue1 + .05f) % 360.0f;
    hue2 = (hue2 + .05f) % 360.0f;

    xOff = (float)Math.cos(a);
    zOff = (float)Math.sin(a);
    int shrubIdx = 0;
    for (LXModel shrub : model.sub("SHRUB")) {
      for (LXPoint cube : shrub.points) {
        colors[cube.index] = LX.hsb(
            blips.get(shrubIdx).getHue(),
            blips.get(shrubIdx).getSat(cube.x, cube.y, cube.z, a),
            blips.get(shrubIdx).getBrightness(cube.x, cube.y, cube.z, a));
      }

      for (Blip blip : blips) {
        blip.update(deltaMs);
      }

      if (a > LX.TWO_PI) {
        a = 0;
      }
      shrubIdx++;
    }
  }

private
  class Blip {
    float height;
    float hue;
    // static final float baseHue;
    float speed;
    float tailLen;
    boolean isOn;
    // boolean isTree;
    // int sculptureIdx;

    Blip(boolean TorS, int _idx) {
      height = 0;
      if (Math.random() < .70) {
        hue = hue1;
      } else {
        hue = hue2;
      }
      speed = 1 + (9 * (float)Math.random());
      tailLen = 100;
      isOn = false;
      // isTree = TorS;
      // sculptureIdx = _idx;

      if (Math.random() < .01) {
        isOn = true;
      }
    }

  private
    float getHue() {
      if (!isOn) {
        return 0;
      }

      return hue;
    }

  private
    float getSat(float x, float y, float z, float _a) {
      if (!isOn) {
        return 0;
      }

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
      if (!isOn) {
        return 0;
      }

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
      if (isOn) { // on
        height += (((float)_deltaMs) / 50) * speed;

        if (height >= tailLen * 2) {
          isOn = false;
          height = 0;
          speed = 1 + (9 * (float)Math.random());
          if (Math.random() < .70) {
            hue = hue1;
          } else {
            hue = hue2;
          }
        }
      } else { // off
        // stagger the turn Ons here
        if (Math.random() < .01) {
          isOn = true;
        }
      }
    }
  }
}
