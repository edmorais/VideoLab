/*
 * VideoLab
 * by Eduardo Morais 2013 - www.eduardomorais.pt
 *
 */


/*
 * SETUP
 */
void setup() {

    // try to load config file:
    Config cfg = new Config();

    try {
        // load a configuration from a file inside the data folder
        InputStream cf = openStream("config.txt");
        if (cf != null) {
            cfg.load(cf);

            // all values returned by the getProperty() method are Strings
            // so we need to cast them into the appropriate type ourselves
            // this is done for us by the convenience Config class
            $capWidth          = cfg.getInt("cap.width", $capWidth);
            $capHeight         = cfg.getInt("cap.height", $capHeight);

            $saveFolder        = cfg.getString("opt.save", $saveFolder);
            $savePNG           = cfg.getBoolean("opt.png", $savePNG);
        }
    } catch(IOException e) {
        println("couldn't read config file...");
    }

    // set screen:
    size($windowWidth, $windowHeight);
    frame.setTitle("VideoLab » "+$version);
    smooth();
    background(0);

    // initialise GUI:
    $drop = new SDrop(this);

    // initialise camera:
    $camNum = Capture.list().length;

    if ($live && $camNum > 0) {
        // prepare camera and initialise scanned image buffer:
        prepareCamera();
        prepareBuffer();
    } else {
        // load a file:
        if ($camNum < 1) { println("No camera detected."); }
        $videoFile = sketchPath("")+$videoDefault;
        prepareVideo();
        prepareBuffer();
    }

    // load background elements
    $monitorOverlay = loadImage($assetsDir+"monitor_"+$screenType+".png");
    $labBackground = loadImage($assetsDir+"lab_bg.png");
    $labModeBg = new PImage[5];
    $labModeBg[0] = loadImage($assetsDir+"lab_mode_zero.png");
    $labModeBg[1] = loadImage($assetsDir+"lab_mode_aspect.png");
    $labModeBg[2] = loadImage($assetsDir+"lab_mode_interlace.png");
    $labModeBg[3] = loadImage($assetsDir+"lab_mode_sampling.png");
    $labModeBg[4] = loadImage($assetsDir+"lab_mode_bitdepth.png");

    $labOverlayGradient = loadImage($assetsDir+"lab_mode_bitdepth_gradient.png");

    $UI = createGraphics($windowWidth, $windowHeight);
    prepareUI();

    // type:
    $msgFont = loadFont($assetsDir+"type/vt.vlw");
    textFont($msgFont);
    textAlign(CENTER, CENTER);

    //help:
    $Help = new PImage[5][];
    $helpShown = new boolean[$Help.length];

    // modes
    $Help[MODE_OFF] = new PImage[6];
    $Help[MODE_ASPECT] = new PImage[6];
    $Help[MODE_INTERLACE] = new PImage[6];
    $Help[MODE_SAMPLING] = new PImage[8];
    $Help[MODE_BITDEPTH] = new PImage[5];
    for (int h = 0; h < $Help.length; h++) {
        for (int i = 0; i < $Help[h].length; i++) {
            $Help[h][i] = loadImage($assetsDir+"help/"+$helpSections[h]+"_"+i+".png");
        }
        $helpShown[h] = false;
    }

}