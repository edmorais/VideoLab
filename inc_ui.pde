/*
 * VideoLab
 * by Eduardo Morais - www.eduardomorais.pt
 */

/*
 * UI
 */

// constants
final int STATUS_OFF         = 0;
final int STATUS_ON          = 1;
final int STATUS_OVER        = 3;
final int STATUS_ONOVER      = 4;
final int STATUS_DISABLED    = 8;

/*
 * BUTTON class
 */
class Button {

    /*
     * Properties
     */

     int x, y, w, h; // dimensions
     PImage imgOn, imgOver, imgDisabled;  // images
     boolean optOn, optOver, optDisabled; // statuses available to the buttons
     int status = 0; // 0 off, 1 on, 3/4 over, 8 disabled
     String name;


    /*
     * Constructor
     */
    Button(String _name, int _x, int _y, boolean _optOn, boolean _optOver, boolean _optDisabled) {
        name = _name;
        x = _x;
        y = _y;
        optOn = _optOn;
        optOver = _optOver;
        optDisabled = _optDisabled;

        // default values
        w = 40;
        h = 40;
        if (optOn) {
            imgOn = loadImage($assetsDir+"buttons/"+name+"_on.png");
            w = imgOn.width;
            h = imgOn.height;
        }
        if (optOver) {
            imgOver = loadImage($assetsDir+"buttons/"+name+"_over.png");
            w = imgOver.width;
            h = imgOver.height;
        }
        if (optDisabled) {
            imgDisabled = loadImage($assetsDir+"buttons/"+name+"_disabled.png");
        }
    }


    /*
     * Draw button on UI buffer
     */
    void show() {
        if (status == STATUS_DISABLED && optDisabled) {
            $UI.image(imgDisabled, x, y);
        } else {
            if ((status == STATUS_OVER || status == STATUS_ONOVER) && optOver) {
                $UI.image(imgOver, x, y);
            } else if (status > STATUS_OFF && optOn) {
                $UI.image(imgOn, x, y);
            }
        }
    }

    /*
     * Mouse over button?
     * outputs boolean so mouse cursor can be changed
     */
    boolean isOver() {
        if (!optOver) {
            return false;
        }
        if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h) {
            if (status <= STATUS_ON && mousePressed) {
                status = status + STATUS_OVER;
            }
            return true;
        }
        if (status >= STATUS_OVER && mousePressed) {
            status = status - STATUS_OVER;
        }
        return false;
    }

} // end class Button


/*
 * PREPARE UI
 */
void prepareUI() {
    $uiMain = new Button[12];

    // main UI
    $uiMain[0] = new Button("main_still", 214, 662, true, true, false);
    $uiMain[1] = new Button("main_live", 40, 662, true, true, true);
    $uiMain[2] = new Button("main_load", 120, 662, true, true, false);

    $uiMain[3] = new Button("main_rateup", 296, 662, true, true, false);
    $uiMain[4] = new Button("main_ratedown", 336, 662, true, true, false);

    $uiMain[5] = new Button("screen_wide", 930, 50, false, true, false);
    $uiMain[6] = new Button("screen_sd", 0, 80, false, true, false);

    $uiMain[7] = new Button("main_help", 963, 610, true, true, false);

    $uiMain[8] = new Button("mode_aspect", 485, 610, true, true, false);
    $uiMain[9] = new Button("mode_interlace", 567, 610, true, true, false);
    $uiMain[10] = new Button("mode_sampling", 650, 610, true, true, false);
    $uiMain[11] = new Button("mode_bitdepth", 735, 610, true, true, false);

    // modes UI
    $uiModes = new Button[4][];

    // aspect ratio:
    $uiModes[MIDX_ASPECT] = new Button[2];
    $uiModes[MIDX_ASPECT][0] = new Button("lab_aspect_43", 485, 662, true, true, false);
    $uiModes[MIDX_ASPECT][1] = new Button("lab_aspect_169", 567, 662, true, true, false);

    // interlace:
    $uiModes[MIDX_INTERLACE] = new Button[3];
    $uiModes[MIDX_INTERLACE][0] = new Button("lab_interlace_p", 485, 662, true, true, false);
    $uiModes[MIDX_INTERLACE][1] = new Button("lab_interlace_i", 567, 662, true, true, false);
    $uiModes[MIDX_INTERLACE][2] = new Button("lab_interlace_magnify", 735, 662, true, true, false);

    // interlace:
    $uiModes[MIDX_SAMPLING] = new Button[7];
    $uiModes[MIDX_SAMPLING][0] = new Button("lab_sampling_444", 485, 662, true, true, false);
    $uiModes[MIDX_SAMPLING][1] = new Button("lab_sampling_422", 528, 662, true, true, false);
    $uiModes[MIDX_SAMPLING][2] = new Button("lab_sampling_420", 567, 662, true, true, false);
    $uiModes[MIDX_SAMPLING][3] = new Button("lab_sampling_411", 607, 662, true, true, false);
    $uiModes[MIDX_SAMPLING][4] = new Button("lab_sampling_y", 650, 662, true, true, false);
    $uiModes[MIDX_SAMPLING][5] = new Button("lab_sampling_uv", 735, 662, true, true, false);
    $uiModes[MIDX_SAMPLING][6] = new Button("lab_sampling_magnify", 816, 662, true, true, false);

    // bit depth:
    $uiModes[MIDX_BITDEPTH] = new Button[5];
    $uiModes[MIDX_BITDEPTH][0] = new Button("lab_bitdepth_8", 485, 662, true, true, false);
    $uiModes[MIDX_BITDEPTH][1] = new Button("lab_bitdepth_4", 528, 662, true, true, false);
    $uiModes[MIDX_BITDEPTH][2] = new Button("lab_bitdepth_2", 567, 662, true, true, false);
    $uiModes[MIDX_BITDEPTH][3] = new Button("lab_bitdepth_1", 607, 662, true, true, false);
    $uiModes[MIDX_BITDEPTH][4] = new Button("lab_bitdepth_gradient", 735, 662, true, true, false);

    controlUI();
}


void controlUI() {
    // MAIN - STILL:
    $uiMain[0].status = $stopped ? STATUS_ON : STATUS_OFF;

    // MAIN - LIVE/LOAD:
    if ($camNum > 0) {
        $uiMain[1].status = $live ? STATUS_ON : STATUS_OFF;
        $uiMain[1].optOver = $live ? false : true;
    } else {
        $uiMain[1].status = STATUS_DISABLED;
        $uiMain[1].optOver = false;
    }
    $uiMain[2].status = $live ? STATUS_OFF : STATUS_ON;

    // MAIN - RATE CONTROL:
    $uiMain[3].status = $rate == 0 || $stopped ? STATUS_ON : STATUS_OFF;
    $uiMain[3].optOver = $rate == 0 || $stopped ? false : true;
    $uiMain[4].status = $rate == $rates.length-1 || $stopped ? STATUS_ON : STATUS_OFF;
    $uiMain[4].optOver = $rate == $rates.length-1 || $stopped ? false : true;

    // MAIN - SCREEN:
    $uiMain[5].status = STATUS_OFF;
    $uiMain[6].status = STATUS_OFF;
    $uiMain[5].optOver = $screenType == 1 ? false : true;
    $uiMain[6].optOver = $screenType == 0 ? false : true;

    // HELP:
    $uiMain[7].status = $helpShow ? STATUS_ON : STATUS_OFF;

    // MAIN - MODES:
    $uiMain[8].status = $mode == MODE_ASPECT ? STATUS_ON : STATUS_OFF;
    $uiMain[9].status = $mode == MODE_INTERLACE ? STATUS_ON : STATUS_OFF;
    $uiMain[10].status = $mode == MODE_SAMPLING ? STATUS_ON : STATUS_OFF;
    $uiMain[11].status = $mode == MODE_BITDEPTH ? STATUS_ON : STATUS_OFF;

    switch ($mode) {
        case MODE_ASPECT:
            $uiModes[MIDX_ASPECT][0].status = $aspect_wide ? STATUS_OFF : STATUS_ON;
            $uiModes[MIDX_ASPECT][1].status = $aspect_wide ? STATUS_ON : STATUS_OFF;
            $uiModes[MIDX_ASPECT][0].optOver = $aspect_wide ? true : false;
            $uiModes[MIDX_ASPECT][1].optOver = $aspect_wide ? false : true;
            break;

        case MODE_INTERLACE:
            $uiModes[MIDX_INTERLACE][0].status = $interlace ? STATUS_OFF : STATUS_ON;
            $uiModes[MIDX_INTERLACE][1].status = $interlace ? STATUS_ON : STATUS_OFF;
            $uiModes[MIDX_INTERLACE][0].optOver = $interlace ? true : false;
            $uiModes[MIDX_INTERLACE][1].optOver = $interlace ? false : true;
            $uiModes[MIDX_INTERLACE][2].status = $mode_scaling > 0 ? STATUS_ON : STATUS_OFF;
            break;

        case MODE_SAMPLING:
            for (int i = 0; i < 4; i++) {
                $uiModes[MIDX_SAMPLING][i].status = $subsampling == i ? STATUS_ON : STATUS_OFF;
                $uiModes[MIDX_SAMPLING][i].optOver = $subsampling == i ? false : true;
            }
            $uiModes[MIDX_SAMPLING][4].status = $sampling_luma ? STATUS_ON : STATUS_OFF;
            $uiModes[MIDX_SAMPLING][5].status = $sampling_chroma ? STATUS_ON : STATUS_OFF;
            if ($sampling_chroma) {
                $uiModes[MIDX_SAMPLING][6].status = $mode_scaling > 0 ? STATUS_ON : STATUS_OFF;
                $uiModes[MIDX_SAMPLING][6].optOver = true;
            } else {
                $uiModes[MIDX_SAMPLING][6].status = STATUS_OFF;
                $uiModes[MIDX_SAMPLING][6].optOver = false;
            }

            break;

        case MODE_BITDEPTH:
            for (int i = 0; i < 4; i++) {
                $uiModes[MIDX_BITDEPTH][i].status = $bitdepth == i ? STATUS_ON : STATUS_OFF;
                $uiModes[MIDX_BITDEPTH][i].optOver = $bitdepth == i ? false : true;
            }
            $uiModes[MIDX_BITDEPTH][4].status = $bitdepth_gradient ? STATUS_ON : STATUS_OFF;
            break;

        default:
            break;
    }


}


void drawUI() {
    $UI.beginDraw();
    $UI.clear();

    // mode background:
    $UI.image($labModeBg[$mode], 485, 656);


    // WRAP UP AND DRAW:
    int o = 0; // mouse over?

    // draw main:
    for (int i = 0; i < $uiMain.length; i++) {
        if (!$helpShow) {
            if ($uiMain[i].isOver()) {
                o++;
                cursor(HAND);
            }
        }
        $uiMain[i].show();
    }

    // draw mode:
    if ($mode > MODE_OFF) {
        for (int i = 0; i < $uiModes[$mode-1].length; i++) {
            if (!$helpShow) {
                if ($uiModes[$mode-1][i].isOver()) {
                    o++;
                    cursor(HAND);
                }
            }
            $uiModes[$mode-1][i].show();
        }
    }

    // mouse not over:
    if (o == 0 && !$helpShow) {
        cursor(ARROW);
    }

    // help?
    if ($helpShow) {
        drawHelp();
    }

    $UI.endDraw();
    image($UI, 0, 0);
}
