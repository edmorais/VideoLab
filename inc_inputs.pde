/*
 * VideoLab
 * by Eduardo Morais 2013-2021 - www.eduardomorais.pt
 */

/*
 * INPUT FUNCTIONS:
 * keyPressed/Released events, mouse/drop events
 */


/*
 * Keyboard
 */

void keyReleased() {

    // pause
    if (key == ' ' && !$helpShow) {
        $stopped = !$stopped;
        if ($stopped) {
            writeLog("Keyboard: Paused video.");
        } else {
            writeLog("Keyboard: Resumed video.");
        }
    }

    // take screenshot
    if (key == 'S') { // shift-S
        saveImage();
        $saving = true;
        $msgs = "Saved image";
        writeLog("Keyboard: Saved image.");
    }

    // toggle logging
    if (key == 'L') { // shift-L
        if ($logging) {
            writeLog("Keyboard: Logging off from now on...\n");
            $logging = false;
            $msgs = "Logging OFF";
        } else {
            $logging = true;
            $msgs = "Logging ON";
            writeLog("Keyboard: Logging back on...");
        }
    }

    // leave mode:
    if (key == ESC && !$helpShow) {
        $mode = MODE_OFF;
        $monitor.background(0);
        $mode_scaling = 0;
        $sampling_luma = true;
        $sampling_chroma = true;
        $bitdepth_gradient = false;
        $stopped = false;
        controlHelp();
        writeLog("Keyboard: Left current module.");
    }

    // leave help:
    if (key == ESC && $helpShow) {
       leaveHelp();
       writeLog("Keyboard: Left help (Esc. key).");
    }

    // next page
    if (key == ' ' && $helpShow) {
        writeLog("Keyboard: Next help page (Spacebar).");
        moreHelp();
    }

    if (key == CODED) {

        // show/leave help:
        if (keyCode == KeyEvent.VK_F1) {
            if ($helpShow) {
                leaveHelp();
                writeLog("Keyboard: Left help (F1 key).");
            } else {
                $helpShow = true;
                controlHelp();
                writeLog("Keyboard: Invoked help.");
            }
        }

        // frame rate:
        if (keyCode == DOWN && !$helpShow) {
            if ($rate < $rates.length-1) {
                $rate++;
                writeLog("Keyboard: Frame rate change - " + 50/$rates[$rate] + "fps.");
            }
            msgFrameRate(true);
        }
        if (keyCode == UP && !$helpShow) {
            if ($rate > 0) {
                $rate--;
                writeLog("Keyboard: Frame rate change - " + 50/$rates[$rate] + "fps.");
            }
            msgFrameRate(true);
        }

        // help page:
        if (keyCode == RIGHT && $helpShow) {
            writeLog("Keyboard: Next help page (Arrow).");
            moreHelp();
        }
        if (keyCode == LEFT && $helpShow) {
            if ($helpIndex > 0) {
                $helpIndex--;
                writeLog("Keyboard: Previous help page (Arrow).");
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
    if (key == 'Q' || key == 'q') {
        writeLog("Keyboard: Exit program (pressed Q).\n\n");
        key = ESC;
    }
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
            if ($stopped) {
                writeLog("Mouse: Paused video.");
            } else {
                writeLog("Mouse: Resumed video.");
            }
        }


        // camera mode
        if ($uiMain[1].isOver()) {
            $stopped = false;
            if ($camNum > 0 && !$live) {
                writeLog("Mouse: Load webcam feed.");
                prepareCamera();
                prepareBuffer();
            }
        }

        // video file mode
        if ($uiMain[2].isOver()) {
            writeLog("Mouse: Load video file.");
            selectInput("Select a video file:", "selectVideo");
        }

        if ($uiMain[HELP_BUTTON].isOver()) {
            $helpShow = true;
            writeLog("Mouse: Invoked help.");
            controlHelp();
        }

        //
        // modes:
        //
        if ($uiMain[7+MODE_ASPECT].isOver()) {
            $mode = $mode == MODE_ASPECT ? MODE_OFF : MODE_ASPECT;
            $monitor.background(0);
            $stopped = false;
            msgAspectRatio();
            controlHelp();
            if ($mode == MODE_ASPECT) {
                writeLog("Mouse: Entered module ASPECT RATIO.");
                if ($helpShow) { writeLog("Help is automatically on."); }
                if ($aspect_wide) {
                    writeLog("Aspect: Ratio is set at 16:9.");
                } else {
                    writeLog("Aspect: Ratio is set at 4:3.");
                }
            } else {
                writeLog("Mouse: Left Aspect Ratio module.");
            }
        }
        if ($uiMain[7+MODE_INTERLACE].isOver()) {
            $mode = $mode == MODE_INTERLACE ? MODE_OFF : MODE_INTERLACE;
            $mode_scaling = 0;
            msgFrameRate(false);
            controlHelp();
            if ($mode == MODE_INTERLACE) {
                writeLog("Mouse: Entered module INTERLACE.");
                if ($helpShow) { writeLog("Help is automatically on."); }
                if ($interlace) {
                    writeLog("Interlace: Scanning is set to interlaced.");
                } else {
                    writeLog("Interlace: Scanning is set to progressive.");
                }
            } else {
                writeLog("Mouse: Left Interlace module.");
            }
        }
        if ($uiMain[7+MODE_SAMPLING].isOver()) {
            $mode = $mode == MODE_SAMPLING ? MODE_OFF : MODE_SAMPLING;
            $mode_scaling = 0;
            $sampling_luma = true;
            $sampling_chroma = true;
            controlHelp();
            if ($mode == MODE_SAMPLING) {
                writeLog("Mouse: Entered module SAMPLING.");
                if ($helpShow) { writeLog("Help is automatically on."); }
                msgSampling();
            } else {
                writeLog("Mouse: Left Sampling module.");
            }
        }
        if ($uiMain[7+MODE_BITDEPTH].isOver()) {
            $mode = $mode == MODE_BITDEPTH ? MODE_OFF : MODE_BITDEPTH;
            $bitdepth_gradient = false;
            controlHelp();
            if ($mode == MODE_BITDEPTH) {
                writeLog("Mouse: Entered module BIT DEPTH.");
                if ($helpShow) { writeLog("Help is automatically on."); }
                msgBitDepth();
            } else {
                writeLog("Mouse: Left Bit Depth module.");
            }
        }


        // frame rate:
        if ($uiMain[4].isOver()) {
            if ($rate < $rates.length-1) {
                $rate++;
                writeLog("Mouse: Frame rate change - " + 50/$rates[$rate] + "fps.");
            }
            msgFrameRate(true);
        }
        if ($uiMain[3].isOver()) {
            if ($rate > 0) {
                $rate--;
                writeLog("Mouse: Frame rate change - " + 50/$rates[$rate] + "fps.");
            }
            msgFrameRate(true);
        }

        // Change monitor:
        if ($uiMain[5].isOver() || $uiMain[6].isOver()) {
            $screenType = 1 - $screenType;
            $aspect_wide = $screenType == 0 ? false : true;
            prepareBuffer();
            $monitorOverlay = loadImage("ui/monitor_"+$screenType+".png");
            if ($aspect_wide) {
                writeLog("Mouse: Switched to 16:9 screen.");
            } else {
                writeLog("Mouse: Switched to 4:3 screen.");
            }
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
                    prepareBuffer();
                    $stopped = false;
                    if ($aspect_wide) {
                        writeLog("Aspect: Switched to 16:9 ratio.");
                    } else {
                        writeLog("Aspect: Switched to 4:3 ratio.");
                    }
                    msgAspectRatio();
                }
                break;

            case MODE_INTERLACE:
                if ($uiModes[MIDX_INTERLACE][0].isOver() || $uiModes[MIDX_INTERLACE][1].isOver()) {
                    $interlace = !$interlace;
                    if ($interlace) {
                        writeLog("Interlace: Switched to interlaced scan.");
                    } else {
                        writeLog("Interlace: Switched to progressive scan.");
                    }
                    msgFrameRate(false);
                }
                // scaling
                if ($uiModes[MIDX_INTERLACE][2].isOver()) {
                    $mode_scaling++;
                    $msgs = textGraph(3, $mode_scaling)+"Scanline magnification x"+int(pow(2, $mode_scaling));
                    writeLog("Interlace: Scanline magnification x"+int(pow(2, $mode_scaling)));
                    if ($mode_scaling > 3) {
                        $mode_scaling = 0;
                        $msgs = textGraph(3, $mode_scaling)+"Scanline magnification OFF";
                        writeLog("Interlace: Scanline magnification off.");
                    }
                }
                break;

            case MODE_SAMPLING:
                for (int i = 0; i < 4; i++) {
                    if ($uiModes[MIDX_SAMPLING][i].isOver()) {
                        $subsampling = i;
                        msgSampling(); // inc writeLog
                    }
                }
                // luma + chroma
                if ($uiModes[MIDX_SAMPLING][4].isOver()) {
                    $sampling_luma = !$sampling_luma;
                    msgSamplingFilters();
                    if ($sampling_luma) {
                        writeLog("Sampling: Luminance on.");
                    } else {
                        writeLog("Sampling: Luminance off.");
                    }
                }
                if ($uiModes[MIDX_SAMPLING][5].isOver()) {
                    $sampling_chroma = !$sampling_chroma;
                    msgSamplingFilters();
                    if ($sampling_chroma) {
                        writeLog("Sampling: Chrominance on.");
                    } else {
                        writeLog("Sampling: Chrominance off.");
                    }
                }
                // scaling
                if ($uiModes[MIDX_SAMPLING][6].isOver()) {
                    $mode_scaling++;
                    $msgs = textGraph(3, $mode_scaling)+"Chrominance magnification x"+int(pow(2, $mode_scaling));
                    writeLog("Sampling: Chroma magnification x"+int(pow(2, $mode_scaling)));
                    if ($mode_scaling > 3) {
                        $mode_scaling = 0;
                        $msgs = textGraph(3, $mode_scaling)+"Chrominance magnification OFF";
                        writeLog("Sampling: Chroma magnification off.");
                    }

                }
                break;

            case MODE_BITDEPTH:
                for (int i = 0; i < 4; i++) {
                    if ($uiModes[MIDX_BITDEPTH][i].isOver()) {
                        $bitdepth = i;
                        msgBitDepth(); // write log
                    }
                }
                // gradient
                if ($uiModes[MIDX_BITDEPTH][4].isOver()) {
                    $bitdepth_gradient = !$bitdepth_gradient;
                    $msgs = $bitdepth_gradient ? "\nColor gradient chart ON" : "\nColor gradient chart OFF";
                    if ($bitdepth_gradient) {
                        writeLog("Bitdepth: Gradient overlay on.");
                    } else {
                        writeLog("Bitdepth: Gradient overlay off.");
                    }
                }
                break;

            default:
                break;
        }

    } else {
        // showing help:
        if ($uiMain[HELP_BUTTON].isOver()) {
            writeLog("Mouse: Left help.");
            leaveHelp();
        } else {
            writeLog("Mouse: Next help page.");
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
        writeLog("Drag and drop: Load video file.");
        selectVideo(dropped.file());
    }

    // redraw UI
    controlUI();
}
