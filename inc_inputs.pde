/*
 * VideoLab
 * by Eduardo Morais - www.eduardomorais.pt
 */

/*
 * Keyboard
 */

void keyReleased() {


    // pause
    if (key == ' ' && !$helpShow) {
        $stopped = !$stopped;
    }

    // take screenshot
    if (key =='S') { // shift-S
        saveImage();
        $saving = true;
    }

    // leave mode:
    if (key == ESC && !$helpShow) {
        $mode = MODE_OFF;
        $monitor.background(0);
        $mode_scaling = 0;
        $sampling_luma = true;
        $sampling_chroma = true;
        $bitdepth_gradient = false;
        controlHelp();
    }

    // leave help:
    if (key == ESC && $helpShow) {
       leaveHelp();
    }

    // next page
    if (key == ' ' && $helpShow) {
        moreHelp();
    }

    if (key == CODED) {

        // show/leave help:
        if (keyCode == KeyEvent.VK_F1) {
            if ($helpShow) {
                leaveHelp();
            } else {
                $helpShow = true;
                controlHelp();
            }
        }

        // frame rate:
        if (keyCode == DOWN && !$helpShow) {
            if ($rate < $rates.length-1) {
                $rate++;
            }
            msgFrameRate(true);
        }
        if (keyCode == UP && !$helpShow) {
            if ($rate > 0) {
                $rate--;
            }
            msgFrameRate(true);
        }

        // help page:
        if (keyCode == RIGHT && $helpShow) {
            moreHelp();
        }
        if (keyCode == LEFT && $helpShow) {
            if ($helpIndex > 0) {
                $helpIndex--;
            }
        }

    }

    // redraw UI
    controlUI();

}



/*
 * KEY PRESSED
 */
void keyPressed() {
    // disable ESC:
    if (key == ESC) { key = 0; }
    if (key == 'Q' || key == 'q') { key = ESC;}
}



/*
 * MOUSE
 */


/*
 * Mouse Clicked
 */
void mouseReleased() {

    if (!$helpShow) {

        // STILL
        if ($uiMain[0].isOver()) {
            $stopped = !$stopped;
        }


        // camera mode
        if ($uiMain[1].isOver()) {
            $stopped = false;
            if ($camNum > 0 && !$live) {
                prepareCamera();
                prepareBuffer();
            }
        }

        // video file mode
        if ($uiMain[2].isOver()) {
            selectInput("Select a video file:", "selectVideo");
        }

        if ($uiMain[HELP_BUTTON].isOver()) {
            $helpShow = true;
            controlHelp();
        }

        //
        // modes:
        //
        if ($uiMain[7+MODE_ASPECT].isOver()) {
            $mode = $mode == MODE_ASPECT ? MODE_OFF : MODE_ASPECT;
            $monitor.background(0);
            msgAspectRatio();
            controlHelp();
        }
        if ($uiMain[7+MODE_INTERLACE].isOver()) {
            $mode = $mode == MODE_INTERLACE ? MODE_OFF : MODE_INTERLACE;
            $mode_scaling = 0;
            msgFrameRate(false);
            controlHelp();
        }
        if ($uiMain[7+MODE_SAMPLING].isOver()) {
            $mode = $mode == MODE_SAMPLING ? MODE_OFF : MODE_SAMPLING;
            $mode_scaling = 0;
            $sampling_luma = true;
            $sampling_chroma = true;
            msgSampling();
            controlHelp();
        }
        if ($uiMain[7+MODE_BITDEPTH].isOver()) {
            $mode = $mode == MODE_BITDEPTH ? MODE_OFF : MODE_BITDEPTH;
            $bitdepth_gradient = false;
            msgBitDepth();
            controlHelp();
        }


        // frame rate:
        if ($uiMain[4].isOver()) {
            if ($rate < $rates.length-1) {
                $rate++;
            }
            msgFrameRate(true);
        }
        if ($uiMain[3].isOver()) {
            if ($rate > 0) {
                $rate--;
            }
            msgFrameRate(true);
        }

        // Change monitor:
        if ($uiMain[5].isOver() || $uiMain[6].isOver()) {
            $screenType = 1 - $screenType;
            $aspect_wide = $screenType == 0 ? false : true;
            prepareBuffer();
            $monitorOverlay = loadImage("ui/monitor_"+$screenType+".png");
            if ($mode == MODE_ASPECT) {
                msgAspectRatio();
            }
        }

        /*
         * MODES :
         */
        switch ($mode) {
            case MODE_ASPECT:
                if ($uiModes[MIDX_ASPECT][0].isOver() || $uiModes[MIDX_ASPECT][1].isOver()) {
                    $aspect_wide = !$aspect_wide;
                    $monitor.background(0);
                    msgAspectRatio();
                }
                break;

            case MODE_INTERLACE:
                if ($uiModes[MIDX_INTERLACE][0].isOver() || $uiModes[MIDX_INTERLACE][1].isOver()) {
                    $interlace = !$interlace;
                    msgFrameRate(false);
                }
                // scaling
                if ($uiModes[MIDX_INTERLACE][2].isOver()) {
                    $mode_scaling++;
                    $msgs = textGraph(3, $mode_scaling)+"Scanline magnification x"+int(pow(2, $mode_scaling));
                    if ($mode_scaling > 3) {
                        $mode_scaling = 0;
                        $msgs = textGraph(3, $mode_scaling)+"Scanline magnification OFF";
                    }
                }
                break;

            case MODE_SAMPLING:
                for (int i = 0; i < 4; i++) {
                    if ($uiModes[MIDX_SAMPLING][i].isOver()) {
                        $subsampling = i;
                        msgSampling();
                    }
                }
                // luma + chroma
                if ($uiModes[MIDX_SAMPLING][4].isOver()) {
                    $sampling_luma = !$sampling_luma;
                    msgSamplingFilters();
                }
                if ($uiModes[MIDX_SAMPLING][5].isOver()) {
                    $sampling_chroma = !$sampling_chroma;
                    msgSamplingFilters();
                }
                // scaling
                if ($uiModes[MIDX_SAMPLING][6].isOver()) {
                    $mode_scaling++;
                    $msgs = textGraph(3, $mode_scaling)+"Chrominance magnification x"+int(pow(2, $mode_scaling));
                    if ($mode_scaling > 3) {
                        $mode_scaling = 0;
                        $msgs = textGraph(3, $mode_scaling)+"Chrominance magnification OFF";
                    }

                }
                break;

            case MODE_BITDEPTH:
                for (int i = 0; i < 4; i++) {
                    if ($uiModes[MIDX_BITDEPTH][i].isOver()) {
                        $bitdepth = i;
                        msgBitDepth();
                    }
                }
                // gradient
                if ($uiModes[MIDX_BITDEPTH][4].isOver()) {
                    $bitdepth_gradient = !$bitdepth_gradient;
                    $msgs = $bitdepth_gradient ? "\nColor gradient chart ON" : "\nColor gradient chart OFF";
                }
                break;

            default:
                break;
        }

    } else {
        // showing help:
        if ($uiMain[HELP_BUTTON].isOver()) {
            leaveHelp();
        } else {
            moreHelp();
        }
    }


    // redraw UI
    controlUI();

}


/*
 * Drag & drop
 */
void dropEvent(DropEvent dropped) {
    if (dropped.isFile()) {
        $dragged = true;
        selectVideo(dropped.file());
    }

    // redraw UI
    controlUI();
}



/*
 * MESSAGES
 */

// Frame Rate:
void msgFrameRate(boolean graph) {
    float hz = 50/$rates[$rate];
    int df = int(1000/hz);
    $msgs = "\n";
    if (graph) {
        $msgs = textGraph($rates.length-1, $rates.length-$rate-1);
    }

    if ($interlace && $mode == MODE_INTERLACE) {
        $msgs = $msgs + int(hz)+"i video ("+df+"ms between fields)";
    } else if ($mode == MODE_INTERLACE) {
        $msgs = $msgs + int(hz)+"p video ("+df+"ms between frames)";
    } else {
        $msgs = $msgs + int(hz)+"p / frames per second video";
    }
}

// Sampling
void msgSampling() {
    int s1 = $samplings[$subsampling][0];
    int s2 = $samplings[$subsampling][1];
    int f1 = 4 / s1;
    int f2 = s2 == 2 ? 0 : f1 / s2;

    $msgs = "\n4:"+f1+":"+f2+" chroma subsampling";
}

void msgSamplingFilters() {
    String txty = $sampling_luma ? "Luminance ON" : "Luminance OFF";
    String txtuv = $sampling_chroma ? "Chrominance ON" : "Chrominance OFF";
    $msgs = txty + "\n" + txtuv;
}

// Aspect
void msgAspectRatio() {
    $msgs = $aspect_wide ? "\n16:9 widescreen picture ratio" : "\n4:3 standard picture ratio";
}

// Sampling
void msgBitDepth() {
    int bd = int(pow(2, 3-$bitdepth));

    $msgs = bd > 1 ? "\n"+bd+" bits per channel" : "\n1 bit per channel";
}


// Display bar
String textGraph(int total, int level) {
    String txt = "";
    if (total < 4) {
        total = total * 2;
        level = level * 2;
    }
    if (total > 0 && level <= total) {
        for (int i = 0; i < level; i++) {
            txt = txt + "|||||||||";
        }
        for (int i = 0; i < total-level; i++) {
            txt = txt + "-------";
        }
        txt = txt + "\n";
    }
    return txt;
}