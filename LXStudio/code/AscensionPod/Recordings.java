package entwined.modulator;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.stream.JsonWriter;

import heronarts.glx.ui.UI2dContainer;
import heronarts.glx.ui.component.UIButton;
import heronarts.glx.ui.component.UILabel;
import heronarts.glx.ui.vg.VGraphics;
import heronarts.lx.LX;
import heronarts.lx.LXCategory;
import heronarts.lx.LXComponent;
import heronarts.lx.LXPath;
import heronarts.lx.LXSerializable;
import heronarts.lx.clip.LXClip;
import heronarts.lx.mixer.LXBus;
import heronarts.lx.modulator.LXModulator;
import heronarts.lx.parameter.LXParameterListener;
import heronarts.lx.studio.LXStudio.UI;
import heronarts.lx.studio.ui.modulation.UIModulator;
import heronarts.lx.studio.ui.modulation.UIModulatorControls;

@LXCategory("Entwined")
@LXModulator.Global("Recordings")
public class Recordings extends LXModulator implements UIModulatorControls<Recordings> {

  public Recordings(LX lx) {
    super("Recordings");
  }

  private UIButton play, record, stop;
  private LXParameterListener clipListener;
  private LXBus.ClipListener busListener;
  private boolean running = false;

  @Override
  public void buildModulatorControls(UI ui, UIModulator uiModulator, Recordings recordings) {
    uiModulator.setLayout(UIModulator.Layout.VERTICAL);
    uiModulator.setChildSpacing(4);

    final UILabel name = (UILabel)
      new UILabel(0, 0, uiModulator.getContentWidth() - 44, 18)
      .setLabel("<default>")
      .setBackgroundColor(ui.theme.listBackgroundColor)
      .setBorderColor(ui.theme.listBorderColor)
      .setBorderRounding(4)
      .setTextAlignment(VGraphics.Align.CENTER, VGraphics.Align.MIDDLE);

    final UIButton save = (UIButton) new UIButton(0, 0, 18, 18) {
      @Override
      public void onClick() {
        lx.engine.clips.stopClips();
        ui.lx.showSaveFileDialog(
          "Save Recording",
          "Recording File",
          new String[] { "lxr" },
          ui.lx.getMediaFile(LX.Media.PROJECTS, "default.lxr").toString(),
          (path) -> {
            File file = new File(path);
            saveRecording(ui.lx, file);
            name.setLabel(file.getName());
          }
        );
      }
    }
    .setIcon(ui.theme.iconSaveAs)
    .setMomentary(true)
    .setDescription("Save Recording As...");

    final UIButton open = (UIButton) new UIButton(0, 0, 18, 18) {
      @Override
      public void onClick() {
        lx.engine.clips.stopClips();
        ui.lx.showOpenFileDialog(
          "Open Recording",
          "Recording File",
          new String[] { "lxr" },
          ui.lx.getMediaFile(LX.Media.PROJECTS, "default.lxr").toString(),
          (path) -> {
            File file = new File(path);
            openRecording(ui.lx, new File(path));
            name.setLabel(file.getName());
          }
        );
      }
    }
    .setIcon(ui.theme.iconOpen)
    .setMomentary(true)
    .setDescription("Open Recording...");

    this.play = (UIButton) new UIButton(0, 0, 67, 16) {
      @Override
      public void onClick() {
        if (running) {
          lx.engine.clips.stopClips();
        } else {
          lx.engine.clips.stopClips();
          playRecording(lx);
        }
      }
    }
    .setLabel("PLAY")
    .setMomentary(true)
    .setBorderRounding(2);

    this.record = (UIButton) new UIButton(0, 0, 66, 16) {
      @Override
      public void onClick() {
        if (running) {
          lx.engine.clips.stopClips();
          return;
        }

        String label = name.getLabel();
        if (!label.endsWith("*")) {
          name.setLabel(label + "*");
        }

        lx.engine.clips.stopClips();
        for (LXBus bus : lx.engine.mixer.channels) {
          bus.removeClip(0);
          LXClip clip = bus.addClip(0);
          clip.loop.setValue(true);
          bus.arm.setValue(true);
        }
        lx.engine.mixer.masterBus.removeClip(0);
        lx.engine.mixer.masterBus.arm.setValue(true);
        LXClip clip = lx.engine.mixer.masterBus.addClip(0);
        clip.loop.setValue(true);
        ui.lx.engine.clips.launchScene(0);

      }
    }
    .setLabel("RECORD")
    .setMomentary(true)
    .setActiveColor(ui.theme.controlBackgroundColor)
    .setBorderRounding(2);

    this.stop = (UIButton) new UIButton(0, 0, 67, 16) {
      @Override
      public void onClick() {
        ui.lx.engine.clips.stopClips();
      }
    }
    .setLabel("STOP")
    .setMomentary(true)
    .setActiveColor(ui.theme.controlBackgroundColor)
    .setBorderRounding(2);

    // Build UI
    uiModulator.addChildren(
      UI2dContainer.newHorizontalContainer(18, 4, name, save, open),
      UI2dContainer.newHorizontalContainer(16, 4, play, record, stop)
    );

    this.clipListener = p -> {
      this.running = listenedClip.running.isOn();
      if (this.running) {
        if (this.listenedClip.bus.arm.isOn()) {
          this.play.setActiveColor(ui.theme.controlBackgroundColor);
          this.play.setInactiveColor(ui.theme.controlBackgroundColor);
          this.record.setActiveColor(ui.theme.recordingColor);
          this.record.setInactiveColor(ui.theme.recordingColor);
        } else {
          this.play.setActiveColor(ui.theme.primaryColor);
          this.play.setInactiveColor(ui.theme.primaryColor);
          this.record.setActiveColor(ui.theme.controlBackgroundColor);
          this.record.setInactiveColor(ui.theme.controlBackgroundColor);
        }
      } else {
        this.play.setActiveColor(ui.theme.controlBackgroundColor);
        this.play.setInactiveColor(ui.theme.controlBackgroundColor);
        this.record.setActiveColor(ui.theme.controlBackgroundColor);
        this.record.setInactiveColor(ui.theme.controlBackgroundColor);
      }
    };

    ui.lx.engine.mixer.masterBus.addClipListener(this.busListener = new LXBus.ClipListener() {

      @Override
      public void clipAdded(LXBus bus, LXClip clip) {
        if (clip.getIndex() == 0) {
          if (listenedClip != null) {
            listenedClip.running.removeListener(clipListener);
            listenedClip.bus.arm.removeListener(clipListener);
          }
          listenedClip = clip;
          listenedClip.running.addListener(clipListener);
          listenedClip.bus.arm.addListener(clipListener);
        }
      }

      @Override
      public void clipRemoved(LXBus bus, LXClip clip) {
        if (clip == listenedClip) {
          listenedClip.running.removeListener(clipListener);
          listenedClip.bus.arm.removeListener(clipListener);
          listenedClip = null;
        }
      }

    });
  }

  private LXClip listenedClip = null;

  private void saveClip(LX lx, LXBus bus, JsonArray clips) {
    LXClip clip = bus.getClip(0);
    if (clip != null) {
      JsonObject clipObj = new JsonObject();
      clipObj.addProperty("path", bus.getCanonicalPath(lx.engine.mixer));
      clipObj.add("clip", LXSerializable.Utils.toObject(clip, true));
      clips.add(clipObj);
    }
  }

  private void saveRecording(LX lx, File file) {
    JsonObject obj = new JsonObject();
    obj.addProperty("version", LX.VERSION);
    obj.addProperty("timestamp", System.currentTimeMillis());
    JsonArray clips = new JsonArray();
    for (LXBus bus : lx.engine.mixer.channels) {
      saveClip(lx, bus, clips);
    }
    saveClip(lx, lx.engine.mixer.masterBus, clips);
    obj.add("clips", clips);

    try (JsonWriter writer = new JsonWriter(new FileWriter(file))) {
      writer.setIndent("  ");
      new GsonBuilder().create().toJson(obj, writer);
      LX.log("Recording saved successfully to " + file.toString());
    } catch (IOException iox) {
      LX.error(iox, "Could not write recording to output file: " + file.toString());
    }
  }

  public void openRecording(LX lx, File file) {
    try (FileReader fr = new FileReader(file)) {
      JsonObject obj = new Gson().fromJson(fr, JsonObject.class);
      JsonArray clips = obj.get("clips").getAsJsonArray();
      for (int i = 0; i < clips.size(); ++i) {
        JsonObject clipObj = clips.get(i).getAsJsonObject();
        String path = clipObj.get("path").getAsString();
        LXComponent component = LXPath.getComponent(lx.engine.mixer, path);
        if (!(component instanceof LXBus)) {
          lx.pushError("Channel in recording file does not exist: " + path);
        } else {
          LXBus bus = (LXBus) component;
          bus.removeClip(0);
          bus.addClip(clipObj.get("clip").getAsJsonObject(), 0);
        }
      }
    } catch (Throwable x) {
      LX.error(x, "Could not load recording file: " + x.getMessage());
    }
  }

  public void playRecording(LX lx) {
    for (LXBus bus : lx.engine.mixer.channels) {
      bus.arm.setValue(false);
    }
    lx.engine.mixer.masterBus.arm.setValue(false);
    lx.engine.clips.launchScene(0);
  }

  @Override
  protected double computeValue(double deltaMs) {
    return 0;
  }

  @Override
  public void dispose() {
    if (this.busListener != null) {
      lx.engine.mixer.masterBus.removeClipListener(this.busListener);
    }
    if (this.listenedClip != null) {
      this.listenedClip.running.removeListener(this.clipListener);
      this.listenedClip.bus.arm.removeListener(this.clipListener);
      this.listenedClip = null;
    }
    super.dispose();
  }

}