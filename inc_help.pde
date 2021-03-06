/*
 * VideoLab
 * by Eduardo Morais 2013-2017 - www.eduardomorais.pt
 *
 */

/*
 * HELP FUNCTIONS:
 * draw and control tutorial slides
 */

/*
 * HELP
 */
void drawHelp() {
	$UI.image($Help[$mode][$helpIndex], 0, 0);

	$uiMain[HELP_BUTTON].show();
	if ($uiMain[HELP_BUTTON].isOver()) {
		cursor(HAND);
	} else {
		cursor(ARROW);
	}
}

void controlHelp() {
    $helpShow = $helpShown[$mode] ? $helpShow : true;
    $helpIndex = $helpShown[$mode] ? 1 : 0;
    // delete any messages:
    $msgs = $helpShow ? "" : $msgs;
}

void moreHelp() {
    // advance:
    $helpIndex++;
    if ($helpIndex >= $Help[$mode].length) {
        $helpIndex = 0;
        $helpShown[$mode] = true;
        $helpShow = false;
        writeLog("Left help (reached last page).");
    }
}

void leaveHelp() {
    $helpIndex = 0;
    $helpShown[$mode] = true;
    $helpShow = false;
}
