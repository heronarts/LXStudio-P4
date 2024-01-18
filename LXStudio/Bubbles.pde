import java.util.ArrayList;
import java.util.List;

import heronarts.lx.LX;
import heronarts.lx.model.LXPoint;
import heronarts.lx.modulator.LinearEnvelope;
import heronarts.lx.parameter.BoundedParameter;
import heronarts.lx.parameter.DiscreteParameter;
import heronarts.lx.utils.LXUtils;

@LXCategory("Ascension") public static class Bubbles extends LXPattern {
  public final DiscreteParameter ballCount = new DiscreteParameter("NUM", 10, 1, 150);
  final BoundedParameter maxRadius = new BoundedParameter("RAD", 50, 5, 100);
  final BoundedParameter speed = new BoundedParameter("SPEED", 1, 0, 5);
  final BoundedParameter hue = new BoundedParameter("HUE", 0, 0, 360);
  private LinearEnvelope decay = new LinearEnvelope(0,0,2000);
  private int numBubbles = 0;
  private List<Bubble> bubbles;

  private class Bubble {
    public float theta = 0;
    public float yPos = 0;
    public float bHue = 0;
    public float baseSpeed = 0;
    public float radius = 0;

    public Bubble(float maxRadius) {
      theta = PodUtils.random(0, 360);
      bHue = PodUtils.random(0, 30);
      baseSpeed = PodUtils.random(2, 5);
      radius = PodUtils.random(5, maxRadius);
      yPos = model.yMin - radius * PodUtils.random(1,10);
    }

    public void move(float speed) {
      yPos += baseSpeed * speed;
    }
  }

  public Bubbles(LX lx) {
    super(lx);

    addParameter("ballCount", ballCount);
    addParameter("maxRadius", maxRadius);
    addParameter("speed", speed);
    addParameter("hue", hue);
    addModulator(decay);

    bubbles = new ArrayList<Bubble>(numBubbles);
    for (int i = 0; i < numBubbles; ++i) {
      bubbles.add(new Bubble(maxRadius.getValuef()));
    }
  }

  public void addBubbles(int numBubbles) {
    for (int i = bubbles.size(); i < numBubbles; ++i) {
      bubbles.add(new Bubble(maxRadius.getValuef()));
    }
  }

  @Override
  public void run(double deltaMs) {
    if (getChannel().fader.getNormalized() == 0) return;

    // if (bubbles.size() == 0) {
    //   enabled.setValue(false);
    //   // setCallRun(false);
    // }

    for (LXPoint cube : model.points) {
      colors[cube.index] = LX.hsb(
        0,
        0,
        0
      );
    }
    numBubbles = ballCount.getValuei();

    if (bubbles.size() < numBubbles) {
      addBubbles(numBubbles);
    }

    for (int i = 0; i < bubbles.size(); ++i) {
      if (bubbles.get(i).yPos > model.yMax + bubbles.get(i).radius) { //bubble is now off screen
        if (numBubbles < bubbles.size()) {
          bubbles.remove(i);
          i--;
        } else {
          bubbles.set(i, new Bubble(maxRadius.getValuef()));
        }
      }
    }

    for (Bubble bubble: bubbles) {
      for (LXPoint cube : model.points) {
        if (PodUtils.abs(bubble.theta - cube.theta) < bubble.radius && PodUtils.abs(bubble.yPos - (cube.y - model.yMin)) < bubble.radius) {
          float distTheta = LXUtils.wrapdistf(bubble.theta, cube.theta, 360) * 0.8f;
          float distY = bubble.yPos - (cube.y - model.yMin);
          float distSq = distTheta * distTheta + distY * distY;

          if (distSq < bubble.radius * bubble.radius) {
            float dist = PodUtils.sqrt(distSq);
            colors[cube.index] = LX.hsb(
              (bubble.bHue + hue.getValuef()) % 360,
              50 + dist/bubble.radius * 50,
              PodUtils.constrain(cube.y/model.yMax * 125 - 50 * (dist/bubble.radius), 0, 100)
            );
          }
        }
      }

      bubble.move(speed.getValuef() * (float)deltaMs * 60 / 1000);
    }
  }
}
