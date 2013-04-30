/*
 * VideoLab
 * by Eduardo Morais 2012 - www.eduardomorais.pt
 *
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
}



/*
 * PREPARE WEBCAM
 */
void prepareCamera() {
    if ($camNum > 0) {
        $cam = new Capture(this, $capWidth, $capHeight);
        $cam.start();
        $feed = $cam;
        $live = true;
        if ($video != null) {
            $video.stop();
        }

        $stopped = false;
        // prepareUI();
        $msgs = "\nLive camera feed";
    }
}


/*
 * PREPARE VIDEO FILE
 */
void prepareVideo() {
    if ($videoFile != null) {
        if ($video != null) {
            $video.stop();
        }
        $video = new Movie(this, $videoFile);
        $video.jump(0);
        $video.loop();
        $video.play();
        $video.read(); // we need to know its size before calling prepareBuffer()
        $feed = $video;
        $live = false;
        if ($cam != null) {
            $cam.stop();
        }
        $stopped = false;
    }
}


/*
 * Select video file
 */
void selectVideo(File selection) {
    if (selection == null) {
        println("Window was closed or the user hit cancel.");
        $videoFile = null;
    } else {
        println("User selected " + selection.getAbsolutePath());
        String fn = selection.getName();
        String fext = fn.substring(fn.lastIndexOf(".") + 1, fn.length());
        String ext;
        boolean ok = false;

        for (int i = 0; i < $videoExts.length; i++) {
            ext = $videoExts[i];
            if (ext.equalsIgnoreCase(fext)) {
                ok = true;
                break;
            }
        }

        if (ok) {
            $stopped = true;
            $videoFile = selection.getAbsolutePath();
            prepareVideo();

            // prepareUI();
        } else if (!$dragged) {
            selectInput("Please select a supported video file...", "selectVideo");
        }
        $msgs = "File selected\n" + fn;
    }
    $dragged = false;
}


/*
 * PREPARE DRAWING BUFFER
 */
void prepareBuffer() {
    $buffer = createGraphics($screenTypes[$screenType][0], $screenTypes[$screenType][1]);
    $monitor = createGraphics($screenTypes[$screenType][0], $screenTypes[$screenType][1]);

    $buffer.beginDraw();
    $buffer.background(0);
    $buffer.endDraw();
    $monitor.beginDraw();
    $monitor.background(0);
    $monitor.endDraw();
}
