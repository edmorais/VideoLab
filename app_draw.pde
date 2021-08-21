/*
 * VideoLab
 * by Eduardo Morais 2013-2021 - www.eduardomorais.pt
 *
 */

/*
 * APP DRAW:
 * main Processing draw() loop
 */


/*
 * DRAW
 */
void draw() {
    boolean ok = false;
    $cycle++;

    if ($live && $cam != null && $cam.available()) {
        ok = true;
        $cam.read();
    } else if ($video != null && $video.available()) {
        ok = true;
        $video.read();
    }

    if (ok) {
        if (!$stopped && $cycle+1 >= $rates[$rate]) {
            $cycle = 0;

            switch($mode) {
                case MODE_ASPECT:
                    video_aspect();
                    break;
                case MODE_INTERLACE:
                    video_interlace();
                    break;
                case MODE_SAMPLING:
                    video_subsampling();
                    break;
                case MODE_BITDEPTH:
                    video_bitdepth();
                    break;
                default:
                    video_plain();
                    break;
            }
        }

        // draw buffer:
        image($monitor, 144 + $screenTypes[$screenType][2], 35 + $screenTypes[$screenType][3], $screenTypes[$screenType][0], $screenTypes[$screenType][1]);

        // draw messages:
        if ($msgCycle < 50 && $msgs != "") {
            teleText($msgs, width/2, $screenTypes[$screenType][3] + $monitor.height-50, 255, 0, 1);
            $msgCycle++;
        } else {
            // clear messages:
            $msgs = "";
            $msgCycle = 0;
        }

        // draw monitor overlay
        image($monitorOverlay, 0, 0);

        // draw ui
        image($labBackground, 0, 600);
        drawUI();

        // flash screen on save:
        if ($saving) {
            background(255);
            $saving = false;
        }
    }

    if ($feed == null) {
        background(32);
        // draw monitor overlay
        image($monitorOverlay, 0, 0);
        // draw ui
        image($labBackground, 0, 600);
        drawUI();
    }

    // screen logging?
    if ($logging && millis() >= $screenLogTime + ($screenLogDelay*1000)) {
        $screenLogTime = millis();
        saveImage();
    }
}
