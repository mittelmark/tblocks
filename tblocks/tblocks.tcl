#!/usr/bin/env tclsh
##############################################################################
#
# Copyright (C) 2026 Detlef Groth, University of Potsdam, Germany
#
# All rights reserved.
#
# Synopsis:    Presentation tool to create block graphics as SVG files
# Authors:     2026 Detlef Groth, University of Potsdam, Germany
# License:     BSD-3-Clause license 
#
##############################################################################

namespace eval ::tblocks { }
proc ::tblocks::usage {app} {
    puts "Usage $app \[-h,--help|--mode=MODENAME\] INFILE.md OUTFILE.svg"
}
proc ::tblocks::help {app argv} {
    puts {
tblocks - application to create SVG diagram based on Markdown documents

Usage: tblocks [OPTIONS] INFILE [OUTFILE]

Arguments:
    INFILE       - Markdown file used as input for the diagram,
                   if the argument is '-' it is assumed to read from stdin
    OUTFILE      - SVG output file, if not given it used the 
                   basename if the INFILE argument but adds a svg extension
                   if the argument is '-' the program write to stdout 
                
Options:
    --help,-h        - display this help page
    --mode=MODE      - the type of output diagram, current diagram types are
                       boxes, iblocks, inout, linegraph, sequence, table, timeline
    --mono-font=FONT          - a monospaced font from fonts.bunny.net               
    --sans-font=FONT          - a sans serif font from fonts.bunny.net
    --colorN="COL1 COL2 COL3" - setting the color N for the diagram, color1 sets
                                the text color, the next ones set the backgrounds
}
}
proc ::tblocks::header {height width args} {
    array set arg [list -font {Andika "Ubuntu Mono"} -colors [list black black black]]
    array set arg $args
    set fonts $arg(-font)
    set sans [lindex $fonts 0]
    set mono [lindex $fonts 1]
    set code {<?xml version="1.0" encoding="ISO-8859-1"?>
 <svg width="__width__" height="__height__" xmlns="http://www.w3.org/2000/svg">
  <style>
  @import url(https://fonts.bunny.net/css?family=__sans-font__:400,400i,700,700i|__mono-font__:400,400i,700,700i);
  .header {
      font-family: '__Sans-Font__', sans-serif;
      font-size: 28px;
      fill: __COL1__;
  }
  .normal {
      font-family: '__Sans-Font__', sans-serif;
      font-size: 22px;
      fill: __COL2__;
  }
  .small {
      font-family: '__Sans-Font__', sans-serif;
      font-size: 16px;
      fill: __COL2__;
  }
  .large {
      font-family: '__Sans-Font__', sans-serif;
      font-size: 24px;
      fill: __COL2__;
  }
  .mono {
      font-family: '__Mono-Font__', monospaced;
      font-size: 22px;
      fill: __COL2__;
  }
  .bold {
      font-family: '__Sans-Font__', sans-serif;
      font-weight: bold;
      font-size: 22px;
      fill: __COL2__;
  }
  
  </style>
}
set code [regsub -all {__height__} $code $height]
set code [regsub -all {__width__} $code $width]
set sansfont [string tolower [regsub -all { } $sans "-"]]
set monofont [string tolower [regsub -all { } $mono "-"]]
set code [regsub -all {__Sans-Font__} $code $sans]
set code [regsub -all {__Mono-Font__} $code $mono]
set code [regsub -all {__sans-font__} $code $sansfont]
set code [regsub -all {__mono-font__} $code $monofont]
set code [regsub -all {__COL1__} $code [lindex $arg(-colors) 0]]
set code [regsub -all {__COL2__} $code [lindex $arg(-colors) 1]]
return $code
}

proc ::tblocks::footer {} {
    return "</svg>"
}

proc ::tblocks::sequence {xy colors title} {
    set x [lindex $xy 0]
    set y [lindex $xy 1]
    set code {    
    <rect width="240" height="266" x="__x1__" y="__y1__" rx="20" ry="20" fill="__col2__" stroke-width="0" stroke="#888888" />    
    <rect width="240" height="266" x="__x1__" y="__y2__" rx="20" ry="20" fill="__col1__" stroke-width="0" stroke="#888888" />
    <rect width="240" height="266" x="__x1__" y="__y3__" rx="0" ry="0" fill="__col1__" stroke-width="0" stroke="#888888" />    
    <text x="__x2__" y="__y4__" class="header" text-anchor="middle">__title__</text>
    }
    set code [regsub -all __y1__ $code $y]; incr y 100
    set code [regsub -all __y2__ $code $y]; incr y -50
    set code [regsub -all __y3__ $code $y]; incr y -15
    set code [regsub -all __y4__ $code $y]; 
    set code [regsub -all __x1__ $code $x]; incr x 120
    set code [regsub -all __x2__ $code $x]; 
    set code [regsub -all __col1__ $code [lindex $colors 0]]
    set code [regsub -all __col2__ $code [lindex $colors 1]]
    set code [regsub __title__ $code [regsub -all {[#_]{2}} [regsub { *icon:[a-z0-9]+} $title ""] ""]]
    if {[regexp {icon:} $title]} {
        set cmd [regsub {.*icon:([0-9a-zA-z]+).*} $title "\\1"]
        if {[info command ::tblocks::icon-$cmd] ne ""} {
            append code [::tblocks::icon-$cmd [list [expr {$x-100}] [expr {$y-32}]]]
        }
    }

    return $code
}    
proc ::tblocks::arrow-right {xy colors} {
    set x [lindex $xy 0]
    incr x -30
    set y 200
    set arrowx [list 12 25 44 25 12 30]
    set arrowy [list 10 10 25 40 40 25]
    set points ""
    for {set i 0} {$i < [llength $arrowx]} {incr i 1} {
        set xp [expr {[lindex $arrowx $i]+$x-25}]
        set yp [expr {[lindex $arrowy $i]+$y-25}]
        append points "$xp,$yp "
    }
    set points [string trim $points]
    set code   {
        <circle r="24" cx="__x1__" cy="__y1__" fill="__col1__" />
        <polygon points="__points__" style="fill:white;stroke:white;stroke-width:0" />
    }
    set code [regsub -all __x1__ $code $x]; 
    set code [regsub -all __y1__ $code $y];   
    set code [regsub -all __points__ $code $points]; 
    set code [regsub -all __col1__ $code [lindex $colors 1]]
    return $code
}
proc ::tblocks::icon-yes {xy} {
    set x [lindex $xy 0]
    set y [lindex $xy 1]
    set code {
        <circle cx="16" cy="16" r="10" fill="#A2CB90" stroke="#091812" transform="translate(__x__ __y__) scale(1.5)" />
        <line  x1="10" y1="15" x2="14" y2="21" stroke="#091812" stroke-width="1.5" transform="translate(__x__ __y__) scale(1.5)" />
        <line  x1="14" y1="21" x2="22" y2="12" stroke="#091812" stroke-width="1.5" transform="translate(__x__ __y__) scale(1.5)" />
    }
    set code [regsub -all __x__ $code $x]; 
    set code [regsub -all __y__ $code $y];   
    return $code
}

proc ::tblocks::icon-no {xy} {
    set x [lindex $xy 0]
    set y [lindex $xy 1]
    set code {
        <circle cx="16" cy="16" r="10" fill="#E48981" stroke="#181206" transform="translate(__x__ __y__) scale(1.5)" />
        <line  x1="11" y1="11" x2="21" y2="21" stroke="#091812" stroke-width="1.5" transform="translate(__x__ __y__) scale(1.5)" />
        <line  x1="11" y1="21" x2="21" y2="11" stroke="#091812" stroke-width="1.5" transform="translate(__x__ __y__) scale(1.5)"  />
    }
    set code [regsub -all __x__ $code $x]; 
    set code [regsub -all __y__ $code $y];   
    return $code
}
    
proc ::tblocks::table {xy colors title} {
    set x [lindex $xy 0]
    set y [lindex $xy 1]
    set code {    
    <rect width="460" height="396" x="__x1__" y="__y1__" rx="20" ry="20" fill="__col2__" stroke-width="0" stroke="#888888" />    
    <rect width="460" height="396" x="__x1__" y="__y2__" rx="20" ry="20" fill="__col1__" stroke-width="0" stroke="#888888" />
    <rect width="460" height="396" x="__x1__" y="__y3__" rx="0" ry="0" fill="__col1__" stroke-width="0" stroke="#888888" />    
    <text x="__x2__" y="__y4__" class="header" text-anchor="middle">__title__</text>
    }
    set code [regsub -all __y1__ $code $y]; incr y 200
    set code [regsub -all __y2__ $code $y]; incr y -150
    set code [regsub -all __y3__ $code $y]; incr y -12
    set code [regsub -all __y4__ $code $y]; 
    set code [regsub -all __x1__ $code $x]; incr x 230
    set code [regsub -all __x2__ $code $x]; 
    set code [regsub -all __col1__ $code [lindex $colors 1]]
    set code [regsub -all __col2__ $code [lindex $colors 2]]
    set code [regsub __title__ $code [regsub -all {[#_]{2}} [regsub { *icon:[a-zA-Z0-9]+} $title ""] ""]]
    if {[regexp {icon:} $title]} {
        set cmd [regsub {.*icon:([0-9a-zA-z]+).*} $title "\\1"]
        if {[info command ::tblocks::icon-$cmd] ne ""} {
            append code [::tblocks::icon-$cmd [list [expr {$x-200}] [expr {$y-36}]]]
        }
    }
    return $code
}
proc ::tblocks::in-out {colors} {
    set col1 [lindex $colors 0]
    set col2 [lindex $colors 1]
    set code {
        <polygon points="180,130 290,130 290,115 320,150 290,185 290,170 180,170" fill="__col2__" stroke-width="2" stroke="#888888" />
        <polygon points="540,130 650,130 650,115 680,150 650,185 650,170 540,170" fill="__col2__" stroke-width="2" stroke="#888888" />
        <rect width="260" height="180" x="320" y="60" rx="20" ry="20" fill="__col1__" stroke-width="2" stroke="#888888" />
        <circle cx="150" cy="150" r="70" fill="__col1__" stroke-width="2" stroke="#888888" />
        <circle cx="750" cy="150" r="70" fill="__col1__" stroke-width="2" stroke="#888888" />
    }
    set code [regsub -all {__col1__} $code $col1]
    set code [regsub -all {__col2__} $code $col2]
    return $code
}
    
proc ::tblocks::box {xy colors title} {
    set x [lindex $xy 0]
    set y [lindex $xy 1]
    set code {
<rect width="460" height="240" x="__x1__" y="__y1__" rx="20" ry="20" fill="__col1__" stroke-width="2" stroke="#888888" />
<rect width="260" height="60" x="__x2__" y="__y2__" rx="20" ry="20" fill="__col2__" stroke-width="2" stroke="#888888" />   
<text x="__x3__" y="__y3__" class="header" text-anchor="middle">__title__</text>
}        
    set code [regsub __x1__ $code $x]; incr x 100
    set code [regsub __x2__ $code $x]; incr x 130
    set code [regsub __x3__ $code $x]; 
    set code [regsub __y1__ $code $y]; incr y -30
    set code [regsub __y2__ $code $y]; incr y 40
    set code [regsub __y3__ $code $y]; 
    set code [regsub __col1__ $code [lindex $colors 0]]
    set code [regsub __col2__ $code [lindex $colors 1]]
    set code [regsub __title__ $code [regsub -all {[#_]{2}} $title ""]]
    return $code
}
proc ::tblocks::text {cx cy text style anchor} {
    set text [string map {"&" "ampersand"} $text]
    set text [string map {">" "GREATER"} $text]    
    set text [string map {"<" "LOWER"} $text]        
    while {[regexp {^ } $text]} {
        set text [regsub {^ } $text WSP]
    }
    set code {   <text x="__x__" y="__y__" class="__style__" text-anchor="__anchor__">__text__</text>}
    set code [regsub __x__ $code $cx]
    set code [regsub __y__ $code $cy]    
    set code [regsub __text__ $code $text]        
    set code [regsub __style__ $code $style] 
    set code [regsub __anchor__ $code $anchor]     
    set code [string map {"ampersand" "&amp;"} $code]
    set code [string map {"WSP" "&#160;"} $code]    
    set code [string map {"GREATER" "&gt;"} $code]        
    set code [string map {"LOWER" "&lt;"} $code]            
    append code "\n"
    return $code
}

proc ::tblocks::pargs {} {
    uplevel 1 {
        if {[lsearch $argv --mode*] > -1} {
            set idx [lsearch $argv --mode*]
            set mode [regsub {.+=} [lindex $argv $idx] ""]
            if {$mode ni [list table inout iblocks boxes sequence toc timeline linegraph]}  {
                puts "Error: unkown mode $mode!"
                ::tblocks::usage
                exit 0
            }
            set argv [lreplace $argv $idx $idx]
        } 
        if {[lsearch $argv --sans-font*] > -1} {
            set idx [lsearch $argv --sans-font*]
            set font [regsub {.+=} [lindex $argv $idx] ""]
            lset fonts 0 $font
            set argv [lreplace $argv $idx $idx]
        }
        if {[lsearch $argv --mono-font*] > -1} {
            set idx [lsearch $argv --mono-font*]
            set font [regsub {.+=} [lindex $argv $idx] ""]
            lset fonts 1 $font
            set argv [lreplace $argv $idx $idx]
        }
        while {[lsearch -regex $argv --color\[0-9\]=] > -1} {
            set idx [lsearch -regex $argv --color\[0-9\]]
            set col [regsub {.+=} [lindex $argv $idx] ""]
            set n [regsub {.+color([0-9])=.+} [lindex $argv $idx] "\\1"]
            lset colors $n $col
            set argv [lreplace $argv $idx $idx]
        }

        if {[lsearch -regex $argv {^--}] > -1} { 
            set idx [lsearch -regex $argv {^--}] 
            puts "Error: Wrong argument '[lindex $argv $idx]'!"
            puts "Valid arguments are --help, --mode=MODE, --mono-font=MONOFONT, --sans-font=SANSFONT!"
            exit 0
        }
    }
}

proc ::tblocks::icon-get {folder iconname cx cy color} {
    if {![file isdir $folder]} {
        file mkdir $folder
    }
    set iconfile [file join $folder ${iconname}.svg]
    if {![file exists $iconfile] } {
        if {[auto_execok wget] eq ""} {
            puts stderr "Error: wget is required!"
            exit 0
        } else {
            puts "wget -q https://raw.githubusercontent.com/Templarian/MaterialDesign/refs/heads/master/svg/${iconname}.svg -O $iconfile"
            exec wget -q https://raw.githubusercontent.com/Templarian/MaterialDesign/refs/heads/master/svg/${iconname}.svg -O [string tolower $iconfile]
        }
    }
    if [catch {open $iconfile r} infh] {
        puts stderr "Cannot open $iconfile: $infh"
        exit
    }
    set icontext [read $infh]
    close $infh
    set icontext [regsub {.+<path(.+)</svg>} $icontext "<path\\1"]
    set defs ""
    set uses ""
    append defs "<symbol id=\"$iconname\" viewBox=\"0 0 24 24\">\n"
    append defs "    $icontext\n</symbol>\n"
    append uses "<svg x=\"[expr {$cx+30}]\" y=\"[expr {$cy+30}]\" width=\"72\" height=\"72\" viewBox=\"0 0 72 72\" fill=\"$color\">\n"
    append uses "   <use href=\"#${iconname}\" />\n"
    append uses "</svg>\n"
    return [list $defs $uses]
}

## itable 
proc splitNN {s {max 40}} {
    set res [list]
    set cres ""
    set words [split [string trim $s] " "]
    foreach w $words {
        if {[string length "$cres $w"] > $max} {
            lappend res $cres
            set cres "$w"
        } else {
            append cres " $w"
        }
    }
    lappend res $cres
    return $res
}
proc ::tblocks::itable {fonts colors lines n m maxstl} {
    set width  [expr {200+(($n-1)*600)}]
    set boxh [expr {10+(1+$maxstl/45)*40}]
    set height [expr {100+($m-2)*(20+$boxh)}]
    set res ""
    append res [::tblocks::header $height $width -font $fonts -colors [lindex $colors 0]]
    set cn 0
    set cx 30
    set defs "\n<defs>\n"
    set uses ""

    foreach line $lines {
        if {[regexp {^##} $line]} {
            set cy 10
            set txt [regsub {^## +} $line ""]
            if {$cn > 0} {
                set cx [expr {200+(($cn-1)*600)}]
                set cy 10
                append res "<rect x=\"$cx\" y=\"$cy\" width=\"580\" height=\"80\" rx=\"20\" ry=\"20\"  stroke-width=\"2\" stroke=\"#888888\" fill=\"[lindex [lindex $colors [expr {$cn+1}]] 1]\"/>\n"
                append res "<text x=\"[expr {290+$cx}]\" y=\"60\" class=\"header\" text-anchor=\"middle\">$txt</text>\n"
            }
        
            incr cn
            incr cy 100
        } elseif {[regexp {^- (.+)$} $line -> txt]} {
            if {$cn > 1} {
                append res "<rect x=\"[expr {$cx+3}]\" y=\"$cy\" width=\"580\" height=\"${boxh}\" rx=\"20\" ry=\"20\"  stroke-width=\"2\" stroke=\"#888888\" fill=\"[lindex [lindex $colors [expr {$cn}]] 0]\"/>\n"
                set iconname ""
                set iind -20
                if {[regexp {icon:([-a-z0-9A-Z]+)} $txt]} {
                    set iconname [regsub {.+icon:([-a-z0-9A-Z]+).*} $txt "\\1"]
                    set txt [regsub {icon:.+} $txt ""]
                    set iind 30
                }
                set txts [splitNN $txt 45] 
                if {[llength $txts] == 1} {
                    append res "<text x=\"[expr {$cx+50+$iind}]\" y=\"[expr {$cy+$boxh/2+10}]\" class=\"large\" text-anchor=\"left\">[lindex $txts 0]</text>\n"
                } elseif {[llength $txts] == 2} {
                    append res "<text x=\"[expr {$cx+50+$iind}]\" y=\"[expr {$cy+$boxh/2-10}]\" class=\"large\" text-anchor=\"left\">[lindex $txts 0]</text>\n"
                    append res "<text x=\"[expr {$cx+50+$iind}]\" y=\"[expr {$cy+$boxh/2+20}]\" class=\"large\" text-anchor=\"left\">[lindex $txts 1]</text>\n"                    
                }
                if {$iconname eq "yes"} {
                    append res [tblocks::icon-yes [list [expr {$cx+18}] [expr {$cy+($boxh/2-24)}]]]
                } elseif {$iconname eq "no"} {
                    append res [tblocks::icon-no  [list [expr {$cx+18}] [expr {$cy+($boxh/2-24)}]]]
                } elseif {$iconname ne ""} {
                    set icode [::tblocks::icon-get "icons" ${iconname} $cx $cy [lindex [lindex $colors {$cn+1}] 2]]
                    append defs [lindex $icode 0]
                    append uses [lindex $icode 1]
                }
            } else {
                append res "<text x=\"[expr {$cx-10}]\" y=\"[expr {$cy+$boxh/2+10}]\" class=\"large\" text-anchor=\"left\">$txt</text>\n"
            }
            incr cy $boxh
            incr cy 20
        }
            
    }
    if {[string length $defs] > 20} {
        append res $defs
        append res "</defs>\n"
        append res $uses
    }
    append res [::tblocks::footer]
    return "$res"
}

proc ::tblocks::in-out-blocks {fonts colors lines n m} {
    if {$n == 4} {
        set height 600
        set width 1200
    } else {
        set height 300
        set width 1200
    }
    set res ""
    if {$m > 3} {
        set fontsize large
        set yi 28
    } else {
        set fontsize header
        set yi 40
    }
    append res [::tblocks::header $height $width -font $fonts -colors [lindex $colors 0]]
    set col1 [lindex [lindex $colors 1] 0]
    set col2 [lindex [lindex $colors 2] 1]
    set col3 [lindex [lindex $colors 3] 0]
    set code {
        <polygon points="380,130 430,130 430,115 455,150 430,185 430,170 380,170" fill="__col2__" stroke-width="2" stroke="#888888" />
        <polygon points="600,130 795,130 795,115 820,150 795,185 795,170 600,170" fill="__col2__" stroke-width="2" stroke="#888888" />
        <rect width="360" height="280" x="20" y="10" rx="20" ry="20" fill="__col1__" stroke-width="2" stroke="#888888" />
        <circle cx="600" cy="150" r="145" fill="__col1__" stroke-width="2" stroke="#888888" />
        <rect width="360" height="280" x="820" y="10" rx="20" ry="20" fill="__col1__" stroke-width="2" stroke="#888888" />
    }
    if {$n == 4} {
        append code {
            <rect width="660" height="180" x="270" y="370" rx="20" ry="20" fill="__col3__" stroke-width="2" stroke="#888888" />
        }
    }
    set code [regsub -all {__col1__} $code $col1]
    set code [regsub -all {__col2__} $code $col2]
    set code [regsub -all {__col3__} $code $col3]
    append res $code
    set cn 0
    set cm 0
    foreach line $lines {
        if {[regexp {^##} $line]} {
            set txt [regsub {^## +} $line ""] 
            if {$cn == 0} {
                append res "<text x=\"200\" y=\"70\" class=\"header\" text-anchor=\"middle\">$txt</text>"
                set cy 120
            } elseif {$cn == 1} {
                append res [tblocks::text 600 130 $txt header middle]
                set cy 150
            } elseif {$cn == 2} {
                append res [tblocks::text 1000 70 $txt header middle]
                set cy 120
            } elseif {$cn == 3} {
                set cy 450
                set cx 310
                append res [tblocks::text 600 410 $txt header middle]
            } 
            incr cn
            set cm 0
        } elseif {[regexp {[^\\s]} $line]} {
            set txt $line
            if {$cn == 1} {
                append res [tblocks::text 60 $cy $txt $fontsize left]
                incr cy $yi
            } elseif {$cn == 2} {
                append res [tblocks::text 600 $cy $txt header middle]
                incr cy 40
            } elseif {$cn == 3} {
                append res [tblocks::text 860 $cy $txt $fontsize left]
                incr cy $yi
            } elseif {$cn == 4} {
                if {$cm > 1} {
                    append res [tblocks::text $cx $cy $txt $fontsize left]
                } else {
                    append res [tblocks::text $cx $cy $txt $fontsize left]
                }
                incr cy $yi
                if {$cm == 1} {
                    set cy 450
                    set cx 600
                }
            } 
            incr cm
        } else {
            incr cy [expr {$yi/2}]
        }
    }
    append res [::tblocks::footer]
    return "$res"
}

## icon blocks
proc ::tblocks::iblocks {fonts colors lines n m} {
    set height 400
    set iheight [expr {($m - 6) * 40}]
    if {$n == 1} {
        set width 600
    } elseif {$n <= 4} {
        set width 1200
    } elseif {$n <= 6} {
        set width 1800
    }
    incr height $iheight
    if {$n > 2} {
        set height 800
        incr height $iheight
    }
    set res ""
    append res [::tblocks::header $height $width -font $fonts -colors [lindex $colors 0]]
    set cn 0
    set coords [list {} \
                {{10 10}} \
                {{10 10} {610 10}} \
                {{10 10} {610 10} {310 410}} \
                {{10 10} {610 10} {10  410} {610 410}} \
                {{10 10} {610 10} {1210  10} {310 410} {910 410}} \
                {{10 10} {610 10} {1210  10} {10  410} {610 410} {1210 410}}]
    set defs "\n<defs>\n"
    set uses ""
    foreach line $lines {
        if {[regexp {^##} $line]} {
            set txt [regsub {^## +} $line ""] 
            if {[regexp {icon:} $txt]} {
                set iconname [regsub {.+icon:([-a-z]+).*} $txt "\\1"]
                set txt [regsub {icon:.+} $txt ""]
                set cx [lindex [lindex [lindex $coords $n] $cn] 0]
                set cy [lindex [lindex [lindex $coords $n] $cn] 1]
                append res "<rect  x=\"$cx\" y=\"$cy\" width=\"580\" height=\"[expr {380+$iheight}]\" rx=\"20\" ry=\"20\"  stroke-width=\"2\" stroke=\"#888888\" fill=\"[lindex [lindex $colors {$cn+1}] 0]\"/>\n"
                if {$iconname eq "yes"} {
                    append res [tblocks::icon-yes [list [expr {$cx+266}] [expr {$cy+40}]]]
                } elseif {$iconname eq "no"} {
                    append res [tblocks::icon-no [list [expr {$cx+266}] [expr {$cy+40}]]]
                } else {
                    set icode [::tblocks::icon-get "icons" ${iconname} [expr {$cx+235}] $cy [lindex [lindex $colors {$cn+1}] 2]]
                    append defs [lindex $icode 0]
                    append uses [lindex $icode 1]
                }
                append res [tblocks::text [expr {$cx+290}] [expr {$cy+140}] $txt header middle]
                incr cy 180
            }
            incr cn
        } else {
            if {[regexp {[A-za-z0-9]+} $line]} {
                append res "<text x=\"[expr {$cx+290}]\" y=\"$cy\" class=\"header\" text-anchor=\"middle\">$line</text>\n"
                incr cy 40
            } else {
                incr cy 20
            }
            
        }
    }
    if {[string length $defs] > 20} {
        append res $defs
        append res "</defs>\n"
        append res $uses
    }
    append res [::tblocks::footer]
    return "$res"
}

proc ::tblocks::blocks {fonts colors lines n m} {
    set width 500
    set height 320
    if {$n > 1} {
        set width 1000
    } 
    if {$n > 4} {
        set width 1500
    }
    if {$n > 2} {
        set height 640
    }
    set coords [list [list 20 50]]
    if {$n == 2} {
        set coords [list [list 20 50] [list 520 50]]
    } elseif {$n == 3} {
        set coords [list [list 270 50] [list 20 370] [list 520 370]]
    } elseif {$n == 4} {
        set coords [list [list 20 50] [list 520 50] [list 20 370] [list 520 370]]
    } elseif {$n == 5} {
        set coords [list [list 20 50] [list 520 50] [list 1020 50] [list 270 370] [list 770 370]] 
    } elseif {$n == 6} {
        set coords [list [list 20 50] [list 520 50] [list 1020 50] [list 20 370] [list 520 370]  [list 1020 370]]  
    }
    
    set res ""
    append res [::tblocks::header $height $width -font $fonts -colors [lindex $colors 0]]
    set cn 0
    set cn 0
    set cm 0
    set cy 0
    set cx 0
    if {$m < 6} {
        set fontsize header
        set i 20
    } elseif {$m < 8} {
        set fontsize large
        set i 16
    } else {
        set fontsize normal
        set i 12
    }
    foreach line $lines {
        if {[regexp {^__} $line] || [regexp {^## } $line]} {
            append res [::tblocks::box [lindex $coords $cn] [lindex $colors [expr {$cn+1}]] $line]
            set xy [lindex $coords $cn]
            set x [lindex $xy 0]
            set y [lindex $xy 1]
            incr cn
            set cx [expr {$x+25}]
            set cy [expr {$y+55}]
            if {$fontsize eq "header"} {
                set cx [expr {$x+50}]
                set cy [expr {$y+80}]
            }

        } else {
            if {[regexp {[^\\s]} $line]} {
                if {[regexp {`.+`} $line]} {
                    append res [::tblocks::text $cx $cy [regsub -all {`} $line ""] mono left]
                } elseif {[regexp {.+:$} $line]} {
                    append res [::tblocks::text $cx $cy $line bold left]
                } else {
                    append res [::tblocks::text $cx $cy $line $fontsize left]
                }
                incr cy $i
            }
            incr cy $i ;# default for empty lines

        }
    }
    append res [::tblocks::footer]    
    return $res
    
}

proc ::tblocks::compare {fonts colors lines n nn m} {
    set width [expr {500*$n}] 
    set height [expr {100+$nn*130}]
    set boxh [expr {$m*30+10}]
    set res ""
    append res [::tblocks::header $height $width -font $fonts -colors [lindex $colors 0]]
    set cn 0
    set cy 20
    foreach line $lines {
        if {[regexp {^## } $line]} {
            set cy 20
            incr cn
            set txt [string trim [regsub {^## +} $line ""]]
            append res "<rect x=\"[expr {20+($cn-1)*500}]\" y=\"10\" width=\"460\" height=\"80\" fill=\"[lindex [lindex $colors [expr {$cn+1}]] 0]\" rx=\"20\" stroke-width=\"2\" stroke=\"#888888\" />\n"
            append res "<text x=\"[expr {($cn-1)*500+250}]\" y=\"60\" class=\"bold\" text-anchor=\"middle\">$txt</text>"
            incr cy 80
        } elseif {[regexp {^### } $line]} {
            set txt [string trim [regsub {^### +} $line ""]]
            append res "<rect x=\"[expr {20+($cn-1)*500}]\" y=\"$cy\" width=\"460\" height=\"100\" fill=\"white\" rx=\"2\" stroke-width=\"2\" stroke=\"#888888\" />\n"
            append res "<text x=\"[expr {($cn-1)*500+35}]\" y=\"[expr {$cy+30}]\" class=\"bold\">$txt</text>"
            append res "<line x1=\"[expr {($cn-1)*500+5}]\" y1=\"[expr {$cy-80}]\" x2=\"[expr {($cn-1)*500+5}]\" y2=\"[expr {$cy+50}]\" stroke-width=\"2\" stroke=\"#888888\" />\n"
            append res "<line x1=\"[expr {($cn-1)*500+5}]\" y1=\"[expr {$cy-80}]\" x2=\"[expr {($cn-1)*500+20}]\" y2=\"[expr {$cy-80}]\" stroke-width=\"2\" stroke=\"#888888\" />\n"            
            append res "<line x1=\"[expr {($cn-1)*500+5}]\" y1=\"[expr {$cy+50}]\" x2=\"[expr {($cn-1)*500+20}]\" y2=\"[expr {$cy+50}]\" stroke-width=\"2\" stroke=\"#888888\" />\n"                        
            incr cy 30
        } elseif {[regexp {[a-z]+} $line]} {
            append res "<text x=\"[expr {($cn-1)*500+35}]\" y=\"[expr {$cy+10}]\" class=\"normal\">$line</text>"
            incr cy 30
        } else {
            incr cy 20
        }
    }
    append res [::tblocks::footer]    
    return $res
}
proc ::tblocks::toc-blocks {fonts colors lines n m} {
    set width 200
    set height 200
    if {$n > 1} {
        set width 600
    } 
    if {$n > 2} {
        set width 900
        set height 400
    }
    set coords [list {20 20} {320 20} {620 20} {20 220} {320 220} {620 220}] 
    set res ""
    append res [::tblocks::header $height $width -font $fonts -colors [lindex $colors 0]]
    set cn 0
    set cm 0
    set cy 0
    set cx 0
    set i 15
    foreach line $lines {
        if {[regexp {^__} $line] || [regexp {^## } $line]} {
            set cx [lindex [lindex $coords $cn] 0]
            set cy [lindex [lindex $coords $cn] 1]
            append res "<rect x=\"[expr {$cx+5}]\" y=\"[expr {$cy+5}]\" rx=\"10\" ry=\"10\" fill=\"#999999\" width=\"260\" height=\"160\" stroke-width=\"0\" stroke=\"#999999\" />\n"
            append res "<rect x=\"$cx\" y=\"$cy\" rx=\"10\" ry=\"10\" fill=\"white\" width=\"260\" height=\"160\" stroke-width=\"3\" stroke=\"#999999\" />\n"
            append res "<circle cx=\"[expr {$cx+235}]\" cy=\"[expr {$cy+135}]\" r=\"10\" fill=\"[lindex [lindex $colors 1] 2]\" />\n"
            set txt [regsub {^[#_]+ +} $line ""]
            append res "<text x=\"[expr {$cx+20}]\" y=\"[expr {$cy+40}]\" style=\"fill: [lindex [lindex $colors 1] 2];font-size:28px;\">$txt</text>\n" 
            incr cy 45
            incr cn
        } else {
            if {[regexp {[^\\s]} $line]} {
                append res "<text x=\"[expr {$cx+20}]\" y=\"[expr {$cy+20}]\" style=\"fill: [lindex [lindex $colors 0] 2];font-size:24px;\">$line</text>\n" 
                incr cy $i
            }
            incr cy $i ;# default for empty lines

        }
    }
    append res [::tblocks::footer]    
    return $res
}

proc ::tblocks::linegraph {fonts colors lines n m} {
    set height [expr {190+($m-2)*30}]
    set width [expr {$n*200}]
    set res ""
    append res [::tblocks::header $height $width -font $fonts -colors [lindex $colors 0]]
    set cn 0
    foreach line $lines {
        if {[regexp {^##} $line]} {
            set txt [regsub {^## +} $line ""] 
            set cx [expr {100+$cn*200}]
            append res "<text x=\"$cx\" y=\"45\" class=\"normal\" text-anchor=\"middle\">$txt</text>\n"
            if {$cn < [expr {$n-1}]} {
                append res "<line x1=\"$cx\" y1=\"100\" x2=\"[expr {$cx+200}]\" y2=\"100\"  stroke-width=\"4\" stroke=\"#888888\" />\n"
            }
            append res  "<circle cx=\"$cx\" cy=\"100\" r=\"30\" fill=\"[lindex [lindex $colors [expr {$cn+1}]] 0]\" stroke-width=\"2\" stroke=\"#888888\" />\n"
            set cy 165
            incr cn
        } elseif {[regexp {^- } $line]} {
            set txt [regsub {^- +} $line ""] 
            if {$txt ne ""} {
                append res "<text x=\"$cx\" y=\"$cy\" class=\"normal\" text-anchor=\"middle\">$txt</text>\n"
                incr cy 30
            } else {
                incr cy 15
            }
        }
    }
    append res [::tblocks::footer]    
    return $res
}
## create hexagon icons
proc ::tblocks::hexicons {fonts colors lines n m} {
    set height 100
    set width 100
    set polygon {<polygon points="2,20 20,2 80,2 98,20 98,80 80,98 20,98 2,80" style="fill:__col__;stroke:#333333;stroke-width:0" />}
    set cn 0
    foreach line $lines {
        if {[regexp {^## } $line]} {
            set defs "\n<defs>\n"
            set uses ""
            set iconname ""
            set txt [regsub {^## +} $line ""]
            if {[regexp {icon:([-a-z0-9A-Z]+)} $txt]} {
                set res [::tblocks::header $height $width -font $fonts -colors [lindex $colors 0]]
                set iconname [regsub {.*icon:([-a-z0-9A-Z]+).*} $txt "\\1"]
                append res [regsub {__col__} $polygon [lindex [lindex $colors [expr {$cn+1}]] 0]]
                set txt [string trim [regsub {icon:[-a-zA-Z0-9]+} $txt ""]]
                set icode [::tblocks::icon-get "icons" ${iconname} -4 -14 [lindex [lindex $colors [expr {$cn+1}]] 2]]                
                append defs [lindex $icode 0]
                append uses [lindex $icode 1]
                append res [tblocks::text 50 80 $txt small middle]
                if {[string length $defs] > 20} {
                    append res $defs
                    append res "</defs>\n"
                    append res $uses
                }
                append res [::tblocks::footer]
                set out [open "hexicon-[string tolower [string trim $txt]].svg" w 0600]
                puts $out $res
                close $out
                incr cn
            }
        }
    }
}
    
proc ::tblocks::timeline {fonts colors lines n m} {
    set height [expr {210+($m*30)}]
    set width [expr {$n*400}]
    set boxh [expr {$m*30+10}]
    set res ""
    append res [::tblocks::header $height $width -font $fonts -colors [lindex $colors 0]]
    set n 0
    foreach line $lines {
        if {[regexp {^##} $line]} {
            append res "\n<polygon points=\"[expr {$n*400+2}],20 [expr {($n+1)*400-30}],20 [expr {($n+1)*400}],70 [expr {($n+1)*400-30}],120 [expr {$n*400+2}],120 [expr {$n*400+32}],70\" fill=\"[lindex [lindex $colors [expr {$n+1}]] 1]\" stroke-width=\"2\" stroke=\"#888888\" />\n"
            append res "<rect x=\"[expr {$n*400+10}]\" y=\"140\" width=\"352\" height=\"$boxh\" fill=\"[lindex [lindex $colors [expr {$n+1}]] 0]\" rx=\"20\" stroke-width=\"2\" stroke=\"#888888\" />\n"
            set cx [expr {$n*400+201}]
            if {[regexp {^## (.+): (.+)} $line -> l1 l2]} {
                append res "<text x=\"$cx\" y=\"60\" class=\"header\" text-anchor=\"middle\">$l1</text>\n"
                append res "<text x=\"$cx\" y=\"100\" class=\"normal\" text-anchor=\"middle\">$l2</text>\n"
            } elseif {[regexp {^## (.+)} $line -> l1]} {
                append res "<text x=\"$cx\" y=\"80\" class=\"header\" text-anchor=\"middle\">$l1</text>"
            }
            set cy 180
            set cx [expr {$n*400+20}]
            incr n
        } else {
            if {[string trim $line] ne ""} {
                if {[regexp {^ +} $line match]} {
                    set x [string length $match]
                    set r [string repeat "&#160;" [expr {$x*2}]]
                    set line [string trim $line]
                    set line "$r$line"
                }
                append res "<text x=\"$cx\" y=\"$cy\" class=\"normal\" text-anchor=\"left\">$line</text>\n"
            }
            incr cy 30
        }
    }
    append res [::tblocks::footer]
    return $res
    
}

proc ::tblocks::svg2pdf {svgfile pdffile} {
    if {[auto_execok "cairosvg"] ne ""} {
        exec cairosvg $svgfile -o $pdffile
    } elseif {[auto_execok "rsvg-convert"] ne ""} {
        exec rsvg-convert $svgfile -f pdf -o $pdffile
    } else {
        puts stderr "Error: Missing cairosvg or rsvg-convert for pdf creation!\nPlease install!"
    }
}
proc ::tblocks::main {argv} {
    set fonts [list Andika "Ubuntu Mono"]
    set mode boxes
    ## lightgreen lightmagenta lightblue lightred sand1 sand2
   # set colors [list {#D7F5EB #B8EBDF} {#EADEF6 #D6BEEE} {#DCEBFE #BCDAFB}  {#FCE1E8 #FAC5D5} \
   #             {#FDE8D5 #FCD3B5} {#FAD0D5 #F9C9B2}]
   set colors [list \
                {#000000 #333366 #000000} \
                {#FFCCCC #E68080 #B64040} \
                {#CCFFCC #80CC80 #40B640} \
                {#FFE5CC #E6B380 #B68040} \
                {#CCE5FF #80B3E6 #4080B6} \
                {#E5CCFF #B380E6 #8040B6} \
                {#CCFFFF #80CCCC #40B6B6} \
               ]
    ::tblocks::pargs
    set infile [lindex $argv 0]
    set outfile [lindex $argv 1]
    set pdffile ""
    if {[file extension $outfile] eq ".pdf"} {
        set pdffile $outfile
        set outfile [file rootname $outfile].svg
    }
    if {$infile eq "-"} {
        set infh stdin
            
    } elseif {![file exists $infile]} {
        puts "Error: File '$infile' does not exists!"
        exit 0
    } else {
        if [catch {open $infile r} infh] {
            puts stderr "Cannot open $infile: $infh"
            exit
        } 
    }
    set lines [list]
    set n 0
    set nn 0
    set maxnn 0
    set maxstl 0
    set max 0
    set lnr 0
    set yaml false
    while {[gets $infh line] >= 0} {
        incr lnr
        if {$lnr == 1 && [regexp {^---} $line]} {
            set yaml true
            continue
        } 
        if {$yaml && [regexp {^---} $line]} {
            set yaml false
            continue
        }
        if {$yaml} {
            regexp {^mode: "?([-a-zA-Z0-9]+)"?} $line -> mode
            if {[regexp {^sans-font: "?([-a-zA-Z0-9 ]+)"?} $line -> font]} {
                lset fonts 0 [string trim $font9
            } elseif {[regexp {^mono-font: "?([-a-zA-Z0-9 ]+)"?} $line -> font]} {
                lset fonts 1 [string trim $font ]
            } elseif {[regexp {^color([0-9]): "?([-#a-zA-Z0-9]+)"? "?([-#a-zA-Z0-9]+)"? "?([-#a-zA-Z0-9]+)"?}  $line -> x col1 col2 col3]} {
                lset colors $x [list [string trim $col1] [string trim $col2] [string trim $col3]]
            } elseif {[regexp {^color([0-9]): "?([-#a-zA-Z0-9]+)"? "?([-#a-zA-Z0-9]+)"?}  $line -> x col1 col2]} {
                lset colors $x [list [string trim $col1] [string trim $col2]]
            } 
            continue
        }
        if {[regexp {^__.+__} $line] || [regexp {^## } $line]} {
            incr n
            set m 0
            if {$nn > $maxnn} {
                set maxnn $nn
            }
            set nn 0
            lappend lines $line
        } elseif {[regexp {^### } $line]} {
            incr nn
            set m 0
            lappend lines $line
        } else {
            lappend lines $line
            set stl [string trim [string length $line]]
            if {$stl > $maxstl} {
                set maxstl $stl
            }
            incr m
            if {$m > $max} {
                set max $m
            }
        }
    }
    if {$infh ne "stdin"} {
        close $infh
    }
    if  {$mode in [list hexicon hexicons]} {
        ::tblocks::hexicons $fonts $colors $lines $n $max]
        return
    } 

    if {$outfile eq "-"} {
        set out stdout
    } else {
        set out [open $outfile w 0600]
    }
    if  {$mode eq "timeline"} {
        puts $out [::tblocks::timeline $fonts $colors $lines $n $max]
        if {$out ne "stdout"} {
            close $out
        }
        if {$pdffile ne ""} {
            ::tblocks::svg2pdf $outfile $pdffile
        }
        return
    } 
    if  {$mode eq "compare"} {
        puts $out [::tblocks::compare $fonts $colors $lines $n $maxnn $max]
        if {$out ne "stdout"} {
            close $out
        }
        if {$pdffile ne ""} {
            ::tblocks::svg2pdf $outfile $pdffile
        }
        return
    } 
    if {$mode eq "linegraph"} {
        puts $out [::tblocks::linegraph $fonts $colors $lines $n $max]
        if {$out ne "stdout"} {
            close $out
        }
        if {$pdffile ne ""} {
            ::tblocks::svg2pdf $outfile $pdffile
        }
        return
    } 
    if {$mode eq "iblocks"} {
        puts $out [::tblocks::iblocks $fonts $colors $lines $n $max]
        if {$out ne "stdout"} {
            close $out
        }
        if {$pdffile ne ""} {
            ::tblocks::svg2pdf $outfile $pdffile
        }
        return
    } 
    if {$mode eq "itable"} {
        puts $out [::tblocks::itable $fonts $colors $lines $n $max $maxstl]
        if {$out ne "stdout"} {
            close $out
        }
        if {$pdffile ne ""} {
            ::tblocks::svg2pdf $outfile $pdffile
        }
        return
    } 
    if {$mode in [list boxes blocks]} {

        puts $out [::tblocks::blocks $fonts $colors $lines $n $max]
        if {$out ne "stdout"} {
            close $out
        }
        if {$pdffile ne ""} {
            ::tblocks::svg2pdf $outfile $pdffile
        }
        return 
    }
    if {$mode in [list inout-block]} {
        puts $out [::tblocks::in-out-blocks $fonts $colors $lines $n $max]
        if {$out ne "stdout"} {
            close $out
        }
        if {$pdffile ne ""} {
            ::tblocks::svg2pdf $outfile $pdffile
        }
        return 
    }

    if {$mode in [list toc]} {
        puts $out [::tblocks::toc-blocks $fonts $colors $lines $n $max]
        if {$out ne "stdout"} {
            close $out
        }
        if {$pdffile ne ""} {
            ::tblocks::svg2pdf $outfile $pdffile
        }
        return 
    }
    if {$mode eq "table"} {
        set width 500
        set height 620
        if {$n > 1} {
            set width 1000
        }
    } elseif {$mode eq "sequence"} {
        set width [expr {300*$n}]
        set height 400
    } elseif {$mode eq "inout"} {
        set width 900
        set height 400
    } else {
        puts stderr "Error: Unkown mode '$mode'!"
        exit
    }
    set coords [list [list 20 50]]
    if {$mode eq "sequence"} {
        set coords [list [list 30 20] [list 330 20] [list 630 20] [list 930 20] [list 1230 20]]
    } elseif {$mode eq "inout"} {
        set coords [list [list 150 30] [list 450 30] [list 750 30]]
    } elseif {$mode eq "table"} {
        set coords [list [list 20 20] [list 520 20]]
    } 
    puts $out [::tblocks::header $height $width -font $fonts -colors [lindex $colors 0]]
    set n 0
    set m 0
    set cy 0
    set cx 0
    foreach line $lines {
        if {[regexp {^__} $line] || [regexp {^## } $line]} {
            if {$mode eq "inout"} {
                if {$n == 0} {
                    puts $out [::tblocks::in-out [list [lindex [lindex $colors 1] 0] [lindex [lindex $colors 1] 1]]]
                }
                puts $out [::tblocks::text [lindex [lindex $coords $n] 0] [lindex [lindex $coords $n] 1] [regsub {^[#_]+ } $line ""] header middle]
                set cy 160
                set cx [lindex [lindex $coords $n] 0]
                incr n
            } else {
                if {$mode eq "table"} {
                    puts $out [::tblocks::table [lindex $coords $n] [lindex $colors [expr {$n+1}]] $line]
                } elseif {$mode eq "sequence"} {
                    if {$n > 0} {
                        puts $out [::tblocks::arrow-right [lindex $coords $n] [lindex $colors [expr {$n}]]]
                    }
                    puts $out [::tblocks::sequence [lindex $coords $n] [lindex $colors [expr {$n+1}]] $line]
                } 
                set xy [lindex $coords $n]
                set x [lindex $xy 0]
                set y [lindex $xy 1]
                incr n
                set cx [expr {$x+15}]
                set cy [expr {$y+55}]
                if {$mode in [list "table" "sequence"]} {
                    incr cy 20
                }
            }
        } else {
            if {$mode eq "inout"} {
                if {[regexp {^[^\\s]} $line]} {
                    if {$cy == 160} {
                        puts $out [tblocks::text $cx $cy $line header middle]
                        set cy 275
                    } else {
                        puts $out [tblocks::text $cx $cy $line bold middle]
                        incr cy 30
                    }
                } else {
                    # empty lines in the bottom text
                    if {$cy > 270} {
                        incr cy 15
                    }
                }
            } else {
                if {[regexp {[^\\s]} $line]} {
                    if {[regexp {`.+`} $line]} {
                        puts $out [::tblocks::text $cx $cy [regsub -all {`} $line ""] mono left]
                    } elseif {[regexp {.+:$} $line]} {
                        puts $out [::tblocks::text $cx $cy $line bold left]
                    } else {
                        puts $out [::tblocks::text $cx $cy $line normal left]
                    }
                    incr cy 12
                }
                incr cy 12 ;# default for empty lines
            }
        }
    }
    puts $out [::tblocks::footer]
    if {$out ne "stdout"} {
        close $out
    }
    if {$pdffile ne ""} {
        ::tblocks::svg2pdf $outfile $pdffile
    }
}
package provide tblocks 0.0.9
if {[info exists argv0] && $argv0 eq [info script]} {
    if {[lsearch -regex $argv {(-h|--help)}] > -1} {
        ::tblocks::help $argv0 $argv
    } elseif {[lsearch -regex $argv {(-v|--version)}] > -1} {
        puts [package present tblocks]
    } elseif {[llength $argv] == 1} {
        if {[lindex $argv 0] eq "-"} {
            lappend argv "-"
        } elseif {![file exists [lindex $argv 0]]} {
            puts stderr "Error: File '[lindex $argv 0]' does not exists!"
            ::tblocks::usage $argv0
        } else {
            lappend argv [file rootname [lindex $argv 0]].svg
        }
        tblocks::main $argv
        
    } else {
        ::tblocks::main $argv
    }
}



