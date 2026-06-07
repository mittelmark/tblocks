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
    puts "Usage $app \[-h,--help|--boxes|--table|--sequence\] INFILE.md OUTFILE.svg"
}
proc ::tblocks::help {app argv} {
    puts help
}
proc ::tblocks::header {height width {fonts {Andika "Ubuntu Mono"}}} {
    set sans [lindex $fonts 0]
    set mono [lindex $fonts 1]
    set code {<?xml version="1.0" encoding="ISO-8859-1"?>
 <svg width="__width__" height="__height__" xmlns="http://www.w3.org/2000/svg">
  <style>
  @import url(https://fonts.bunny.net/css?family=__sans-font__:400,400i,700,700i|__mono-font__:400,400i,700,700i);
  .header {
      font-family: '__Sans-Font__', sans-serif;
      font-size: 28px;
  }
  .normal {
      font-family: '__Sans-Font__', sans-serif;
      font-size: 22px;
  }
  .mono {
      font-family: '__Mono-Font_', monospaced;
      font-size: 22px;
  }
  .bold {
      font-family: '__Sans-Font__', sans-serif;
      font-weight: bold;
      font-size: 20px;
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
    set code [regsub -all __col1__ $code [lindex $colors 0]]
    set code [regsub -all __col2__ $code [lindex $colors 1]]
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
}

proc ::tblocks::pargs {} {
    uplevel 1 {
        if {[lsearch $argv --table] > -1} {
            set mode table
            set idx [lsearch $argv --table]
            set argv [lreplace $argv $idx $idx]
        } 
        if {[lsearch $argv --inout] > -1} {
            set mode inout
            set idx [lsearch $argv --inout]
            set argv [lreplace $argv $idx $idx]
        } 
        if {[lsearch $argv --boxes] > -1} {
            set mode boxes
            set idx [lsearch $argv --boxes]
            set argv [lreplace $argv $idx $idx]
        } 
        if {[lsearch $argv --sequence] > -1} {
            set mode sequence
            set idx [lsearch $argv --sequence]
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

    }
}
proc ::tblocks::main {argv} {
    set fonts [list Andika "Ubuntu Mono"]
    set mode boxes
    ::tblocks::pargs
    set infile [lindex $argv 0]
    set outfile [lindex $argv 1]
    ## lightgreen lightmagenta lightblue lightred sand1 sand2
    set colors [list {#D7F5EB #B8EBDF} {#EADEF6 #D6BEEE} {#DCEBFE #BCDAFB}  {#FCE1E8 #FAC5D5} \
                {#FDE8D5 #FCD3B5} {#FAD0D5 #F9C9B2}]
    if [catch {open $infile r} infh] {
        puts stderr "Cannot open $infile: $infh"
        exit
    } else {
        set lines [list]
        set n 0
        set max 0
        while {[gets $infh line] >= 0} {
            if {[regexp {^__.+__} $line] || [regexp {^## } $line]} {
                incr n
                set m 0
                lappend lines $line
            } else {
                lappend lines $line
                incr m
                if {$m > $max} {
                    set max $m
                }
            }
        }
        close $infh
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

    }
    set coords [list [list 20 50]]
    if {$mode eq "sequence"} {
        set coords [list [list 30 20] [list 330 20] [list 630 20] [list 930 20] [list 1230 20]]
    } elseif {$mode eq "inout"} {
        set coords [list [list 150 30] [list 450 30] [list 750 30]]
    } elseif {$mode eq "table"} {
        set coords [list [list 20 20] [list 520 20]]
    } else {
        if {$n == 2} {
            set coords [list [list 20 50] [list 520 50]]
        } elseif {$n == 3} {
            set coords [list [list 270 50] [list 20 370] [list 520 370]]
        } elseif {$n == 4} {
            set coords [list [list 20 50] [list 520 50] [list 20 370] [list 520 370]]
        }
    }
    set out [open $outfile w 0600]
    
    puts $out [::tblocks::header $height $width $fonts]
    set n 0
    set m 0
    set cy 0
    set cx 0
    foreach line $lines {
        if {[regexp {^__} $line] || [regexp {^## } $line]} {
            if {$mode eq "inout"} {
                if {$n == 0} {
                    puts $out [::tblocks::in-out [list [lindex [lindex $colors 0] 0] [lindex [lindex $colors 3] 1]]]
                }
                puts $out [::tblocks::text [lindex [lindex $coords $n] 0] [lindex [lindex $coords $n] 1] [regsub {^[#_]+ } $line ""] header middle]
                set cy 160
                set cx [lindex [lindex $coords $n] 0]
                incr n
            } else {
                if {$mode eq "table"} {
                    puts $out [::tblocks::table [lindex $coords $n] [lindex $colors $n] $line]
                } elseif {$mode eq "sequence"} {
                    if {$n > 0} {
                        puts $out [::tblocks::arrow-right [lindex $coords $n] [lindex $colors [expr {$n-1}]]]
                    }
                    puts $out [::tblocks::sequence [lindex $coords $n] [lindex $colors $n] $line]
                } else {
                    puts $out [::tblocks::box [lindex $coords $n] [lindex $colors $n] $line]
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
                        puts $out [::tblocks::text $cx $cy $line left]
                    }
                    incr cy 12
                }
                incr cy 12 ;# default for empty lines
            }
        }
    }
    puts $out [::tblocks::footer]
    close $out
}
package provide tblocks 0.0.1
if {[info exists argv0] && $argv0 eq [info script]} {
    if {[lsearch -regex $argv {(-h|--help)}] > -1} {
        ::tblocks::help $argv0 $argv
    } elseif {[llength $argv] <2} {
        ::tblocks::usage $argv0
    } else {
        ::tblocks::main $argv
    }
}



