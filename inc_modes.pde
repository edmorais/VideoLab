/*
 * VideoLab
 * by Eduardo Morais 2013-2017 - www.eduardomorais.pt
 */

/*
 * MODE FUNCTIONS
 * aspect ratio, interlace, chroma sampling, and bit depth simulation functions
 */


/*
 * Mode globals
 */

// aspect mode:
boolean $aspect_wide = false;

// interlace mode:
boolean $interlace = true;
int $field = 0;

// bitdepth mode:
int $bitdepth = 0;
int[] $bitdepths = {255, 16, 4, 2};
boolean $bitdepth_gradient = false;

// subsampling mode:
int $subsampling = 1;
int[][] $samplings = {{1,1}, {2,1}, {2,2}, {4,1}};
boolean $sampling_chroma = true;
boolean $sampling_luma = true;

// more...
int $mode_scaling = 0;


/*
 * Plain
 */
void video_plain() {
    $monitor.beginDraw();
    $monitor.image($feed, 0, 0, $monitor.width, $monitor.height);
    $monitor.endDraw();
}

/*
 * ASPECT RATIO
 */
void video_aspect() {
    $monitor.beginDraw();
    if ($screenType == 0 && $aspect_wide) {
        // 16:9 over 4:3
        $monitor.image($feed, 0, $monitor.height*0.125, $monitor.width, $monitor.height*0.75);

    } else if ($screenType == 1 && !$aspect_wide) {
        // 4:3 over 16:9
        $monitor.image($feed, $monitor.width*0.125, 0, $monitor.width*0.75, $monitor.height);

    } else {
        $monitor.image($feed, 0, 0, $monitor.width, $monitor.height);
    }
    $monitor.endDraw();
}

/*
 * INTERLACER
 */
void video_interlace() {
    $buffer.beginDraw();
    $buffer.image($feed, 0, 0, $buffer.width, $buffer.height);
    $buffer.endDraw();

    $buffer.loadPixels();
    $monitor.beginDraw();
    $monitor.loadPixels();

    // toggle field:
    $field = 1 - $field;
    // get the scanline:
    int step = $interlace ? 2 : 1;
    int dy = int(pow(2, $mode_scaling));

    for (int ix = 0; ix < $buffer.width; ix++) {
        for (int iy = $field*dy; iy < $buffer.height; iy = iy + (dy*step)) {

            $pxl = $buffer.pixels[ix+iy*$buffer.width];

            for (int jy = 0; jy < dy; jy++) {
                if (iy+jy < $monitor.height) {
                    // draw:
                    if (dy > 2 && dy-jy == 1) {
                        $pxl = color(brightness($pxl));
                    }
                    $monitor.pixels[ix+((iy+jy)*$monitor.width)] = $pxl;
                }
            }
        }
    }

    // draw monitor:
    $monitor.updatePixels();
    $monitor.endDraw();
}

/*
 * BIT DEPTH
 */
void video_bitdepth() {
    $monitor.beginDraw();
    $monitor.image($feed, 0, 0, $monitor.width, $monitor.height);
    if ($bitdepth_gradient) {
        $monitor.image($labOverlayGradient, ($monitor.width-$labOverlayGradient.width)/2, ($monitor.height-$labOverlayGradient.height)/2);
    }
    $monitor.endDraw();
    $monitor.filter(POSTERIZE, $bitdepths[$bitdepth]);

}

/*
 * CHROMA SAMPLING
 */
void video_subsampling() {
    $buffer.beginDraw();
    $buffer.image($feed, 0, 0, $buffer.width, $buffer.height);
    $buffer.endDraw();

    $buffer.loadPixels();
    $monitor.beginDraw();
    $monitor.loadPixels();

    int dx = int(pow(2, $mode_scaling)) * $samplings[$subsampling][0];
    int dy = int(pow(2, $mode_scaling)) * $samplings[$subsampling][1];
    float y = 127;
    float u = 0;
    float v = 0;
    int s = $mode_scaling + 1;

    // check modes:
    if (!$sampling_luma && !$sampling_chroma) {
        y = 24;
    }

    for (int ix = 0; ix < $buffer.width; ix = ix + dx) {
        for (int iy = 0; iy < $buffer.height; iy = iy + dy) {
            // sampling block
            if ($sampling_chroma) {
                $pxl = $buffer.pixels[ix+iy*$buffer.width];
                u = yuv_u($pxl);
                v = yuv_v($pxl);
            }

            for (int jx = 0; jx < dx; jx++) {
                for (int jy = 0; jy < dy; jy++) {
                    // individual pixels
                    if (ix+jx < $buffer.width && iy+jy < $buffer.height) {
                        if ($sampling_luma) {
                            y = yuv_y($buffer.pixels[ix+jx+((iy+jy)*$buffer.width)]);
                        }

                        $monitor.pixels[ix+jx+((iy+jy)*$monitor.width)] = color(rgb_yuv(y,u,v, s));
                    }
                }
            }
        }
    }

    // draw monitor:
    $monitor.updatePixels();
    $monitor.endDraw();
    colorMode(RGB);
}

/*
 * Chroma sampling helper functions
 */
float yuv_y(color pxl) {
    return (0.299*red(pxl)+0.587*green(pxl)+0.114*blue(pxl));
}
float yuv_u(color pxl) {
    return (-0.147*red(pxl)-0.289*green(pxl)+0.436*blue(pxl));
}
float yuv_v(color pxl) {
    return (0.615*red(pxl)-0.515*green(pxl)-0.1*blue(pxl));
}

color rgb_yuv(float y, float u, float v, int s) {

    u = u * s; // saturation factor
    v = v * s;

    float r = y + 1.14*v;
    float g = y - 0.395*u - 0.581*v;
    float b = y + 2.032*u;
    return color(r, g, b);
}
