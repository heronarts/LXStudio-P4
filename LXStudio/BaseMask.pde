public
static class BaseMaskEffect extends LXEffect
// implements UIDeviceControls<BaseMaskEffect>
{
public
  enum MaskChoice {
    BASE_ONLY("Base"), STRIPS_ONLY("Strips");

    public final String label;

    private MaskChoice(String label){this.label = label;}

  @Override public String toString() {
    return this.label;
  }
};

EnumParameter<MaskChoice> maskChoice =
    new EnumParameter<MaskChoice>("Mask Choice", MaskChoice.BASE_ONLY)
        .setDescription("Show the base or the strips");

public
BaseMaskEffect(LX lx) {
  super(lx);
  addParameter("maskChoice", this.maskChoice);
}

public
void run(double deltaMs, double enabledAmount) {
  MaskChoice maskChoice = this.maskChoice.getEnum();
  boolean baseOnly = maskChoice == MaskChoice.BASE_ONLY;
  for (LXPoint p : model.points) {
    if (baseOnly) {
      if (p.yn > 0) {
        colors[p.index] = LXColor.gray(0);
      }
    } else {
      if (p.yn == 0) {
        colors[p.index] = LXColor.gray(0);
      }
    }
  }
}

  // @Override public void buildDeviceControls(UI ui, UIDevice uiDevice,
  //                                           BaseMaskEffect pattern) {
  //   uiDevice.setContentWidth(COL_WIDTH);
  //   addColumn(uiDevice, COL_WIDTH, "Mask", newDropMenu(pattern.maskChoice));
  // }

}
