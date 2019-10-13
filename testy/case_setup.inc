clippath pathbbox /ury exch def /urx exch def /lly exch def /llx exch def

/pagewidth urx llx sub def
/pageheight ury lly sub def
/margin 8 def


/drawFrame {
    gsave
        margin margin moveto
        pagewidth margin sub            margin lineto
        pagewidth margin sub pageheight margin sub lineto
        margin               pageheight margin sub lineto
        closepath
        stroke
    grestore
} def