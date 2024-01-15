import heronarts.lx.LX;
import heronarts.lx.model.LXPoint;
import heronarts.lx.modulator.SawLFO;
import heronarts.lx.pattern.LXPattern;

//import Utils;

@LXCategory("Ascension") public class Radar extends LXPattern {
    float time = 0;
    // All values below are on the scale from zero to one.
    // std dev of the gaussian function that determines the thickness of the line
    final double deviation = 0.03;
    final double minSweepCenter = 0;
    final double maxSweepCenter = 1;
    final double periodMs = 3000;
    final double periodMsMin = 250;
    final double periodMsMax = 3000;
    final SinLFO periodModulator = new SinLFO(periodMsMin, periodMsMax, periodMs);
    
    final SawLFO radarSweepModulator = new SawLFO(minSweepCenter, maxSweepCenter,
            periodModulator);
    final float[] detectedBrightness;

    double previousSweepPosition = minSweepCenter;

    public Radar(LX lx) {
        super(lx);
        addModulator(radarSweepModulator).start();
        addModulator(periodModulator).start();

        detectedBrightness = new float[lx.getModel().points.length];
    }

    // Returns the gaussian for that value, based on center and deviation.
    // Everything is based on a zero-to-one scale.
    float gaussian(float value, float center) {
        return (float) Math.exp(-Math.pow(value - center, 2) / twoDeviationSquared);
    }

    final double twoDeviationSquared = 2 * deviation * deviation;

    @Override
    protected void run(double deltaMs) {
        time += deltaMs;
        float sweepPosition = radarSweepModulator.getValuef();
        // XXX - local or global??
        for (LXPoint cube : model.points) {
            float mappedCubeZ = 1 - PodUtils.map(cube.z, model.zMin, model.zMax);
            //float mappedCubeZ = 1;
            if (previousSweepPosition < mappedCubeZ && sweepPosition > mappedCubeZ) {
                // Sweep just passed the cube, randomly set whether this cube is "detected"
                if (Math.random() > 0.95) {
                    detectedBrightness[cube.index] = 1;
                }
            }

            float brightnessValue = Math.max(detectedBrightness[cube.index] * 100,
                    5 + gaussian(mappedCubeZ, sweepPosition) * 65);

            colors[cube.index] = LX.hsb(
                    time / 20000 * 360 + 160 - 80 * brightnessValue / 100,
                    100 - 30 * brightnessValue / 100,
                    brightnessValue);

            // This was my original math for exponential decay but it's dependent on the
            // framerate being 60fps. I
            // replaced it with the below "exp" method to work with any framerate.
            // detectedBrightness[cube.index] = detectedBrightness[cube.index] * 0.99f;

            // TODO make the 0.75 a parameter from 0.5 to 2, default val 0.75
            detectedBrightness[cube.index] = (float) Math.exp(Math.log(detectedBrightness[cube.index])
                    - deltaMs / (periodModulator.getValuef() * 0.5));
        }
        previousSweepPosition = sweepPosition;
    }
}
