/*
 *  _    ___     __           __          __
 * | |  / (_)___/ /__  ____  / /   ____ _/ /_
 * | | / / / __  / _ \/ __ \/ /   / __ `/ __ \
 * | |/ / / /_/ /  __/ /_/ / /___/ /_/ / /_/ /
 * |___/_/\__,_/\___/\____/_____/\__,_/_.___/
 *
 * by Eduardo Morais 2013-2017 - www.eduardomorais.pt
 *
 * tested with Processing 3.2.4
 */


/*
 * Libraries
 */
import java.util.*;
import java.text.*;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.awt.event.KeyEvent;
import processing.video.*;
import drop.*;  // http://www.sojamo.de/libraries/drop/

/*
 * GLOBALS (denoted by $)
 */
String $version = "1.3";

// default options:
boolean $live = false;
boolean $stopped = false;
// allowed video file extensions:
String[] $videoExts = {"mov", "avi", "mp4", "mpg", "mpeg"};
String $videoDefault = "video/telefunken.mp4";
String $helpLang = "en";


// video:
Capture $cam;  // camera object
Movie $video;
int $camNum = 0;
PImage $feed;
PGraphics $buffer, $monitor;
SDrop $drop; // drag and drop object

int $capWidth = 640;
int $capHeight = 480;  // capture dimensions
int[][] $screenTypes = {{640, 480, 48, 0}, {736, 414, 0, 33}}; // w, h, x, y
int $screenType = 0;
color $pxl;  // a pixel


// control flags:
int $mode = 0;
boolean $pressing = false;
boolean $dragged = false;
String $videoFile;
// frame rates:
float[] $rates = {1, 2, 4, 6.25, 12.5, 25};
int $rate = 0;
int $cycle = 0;

// UI:
int $windowWidth = 1024;
int $windowHeight = 768;  // screen size
String $assetsDir = "ui/";
PImage $monitorOverlay, $labBackground;
PImage $labOverlayGradient;
PImage[] $labModeBg;
PFont $msgFont;
String $msgs = "";
int $msgCycle = 0;
PGraphics $UI;
Button[] $uiMain;
Button[][] $uiModes;

// Help:
PImage[][] $Help;
int $helpIndex = 0;
boolean $helpShow = true;
String[] $helpSections = {"main", "aspect", "interlace", "sampling", "bitdepth"};
boolean[] $helpShown;

// miscs:
String $saveFolder = "Saved Images";
String $saveLog = "VideoLab.log";
boolean $savePNG = true;
boolean $saving = false;
boolean $logging = false;
int $screenLogDelay = 60;
int $screenLogTime = 0;

// constants:
final int MODE_OFF           = 0;
final int MODE_ASPECT        = 1;
final int MODE_INTERLACE     = 2;
final int MODE_SAMPLING      = 3;
final int MODE_BITDEPTH      = 4;

final int HELP_BUTTON        = 7;

final int MIDX_ASPECT        = MODE_ASPECT - 1;
final int MIDX_INTERLACE     = MODE_INTERLACE - 1;
final int MIDX_SAMPLING      = MODE_SAMPLING - 1;
final int MIDX_BITDEPTH      = MODE_BITDEPTH - 1;
