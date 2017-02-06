/*
 * VideoLab
 * by Eduardo Morais 2013-2017 - www.eduardomorais.pt
 */

/*
 * UTILITY FUNCTIONS:
 * to read config file, logging, saving images, and etecetera
 */


/**
 * simple convenience wrapper object for the standard
 * Properties class to return pre-typed numerals
 */
class Config extends Properties {

    boolean getBoolean(String id, boolean defState) {
        return boolean(getProperty(id,""+defState));
    }

    int getInt(String id, int defVal) {
        return int(getProperty(id,""+defVal));
    }

    float getFloat(String id, float defVal) {
        return float(getProperty(id,""+defVal));
    }

    String getString(String id, String defVal) {
        return getProperty(id,""+defVal);
    }

    int[] getIntArray(String id) {
        String[] str = getProperty(id).split("[, ]+");
        int[] arr = new int[str.length];
        for(int i = 0; i < arr.length; i++) {
            arr[i] = -1;
        }
        for(int i = 0; i < str.length; i++) {
            if (int_in_array(int(str[i]), arr) == false) {
                arr[i] = int(str[i]);
            } else {
                arr = shorten(arr);
            }
        }
        println(arr);
        return arr;
    }

} // end class Config


/*
 * INTEGER IN ARRAY?
 */
static boolean int_in_array(int n, int[] arr) {
    if (arr != null && arr.length > 0) {
        for (int i = 0; i < arr.length; i++) {
            if (arr[i] == n) {
                return true;
            }
        }
    }
    return false;
}


/*
 * WAIT millisseconds
 */
void wait(int ms) {
    long st = millis();
    while (st + ms > millis()) {
        // wait
    }
}

/*
 * Save image with the date in the filename
 */
void saveImage() {
    String ff = $savePNG ? ".png" : ".jpg";
    Date now = new Date();
    SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd_HHmmss");
    save($saveFolder+"/screen_" + df.format(now) + ff);
}


/*
 * Write log file
 * http://stackoverflow.com/questions/17010222/how-do-i-append-text-to-a-csv-txt-file-in-processing
 */
void writeLog(String txt) {
    if ($logging) {
        writeLog(txt, "");
    }
}
void writeLog(String txt, String before) {
    if ($logging) {
        SimpleDateFormat df = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
        Date now = new Date();
        txt = df.format(now) + " - " + txt;
        if (before != "") {
            txt = before + "\n" + txt;
        }

        try {
            PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(sketchPath($saveLog), true)));
            out.println(txt);
            out.close();
        } catch (IOException e) {
            println("Error writing logfile.");
        }
    }
}
