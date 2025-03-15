# start UI idea in background
idea() {
    (nohup idea "$@" >/dev/null 2>&1 &);
}