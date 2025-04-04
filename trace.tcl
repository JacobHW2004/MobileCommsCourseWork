# ========================================================================================
# This is the main script.tcl file, receives from the SCEN_Gen the following 
# parameters:
# ========================================================================================
# Setting the arugments that passed From SCEN_Gen
# ========================================================================================
set arg0 [lindex $argv 0] 				    ;# Protocol name [$R]
set arg1 [lindex $argv 1] 				    ;# Connection Type [$TYPE]
set arg2 [lindex $argv 2] 				    ;# number of Nodes [$N]
set arg3 [lindex $argv 3] 				    ;# Number of connections [$C]
set arg4 [lindex $argv 4] 				    ;# Speed value [$S]
set arg5 [lindex $argv 5] 				    ;# Pause time value [$P]
set arg6 [lindex $argv 6] 				    ;# X [$X]
set arg7 [lindex $argv 7] 				    ;# Y [$Y]
set arg8 [lindex $argv 8] 				    ;# T [$T]
set arg9 [lindex $argv 9] 				    ;# Connection scenario file
set arg10 [lindex $argv 10] 				;# Movement scenario file
set arg11 [lindex $argv 11] 				;# Output trace file name

# =======================================================================================
# Printing Messages
# =======================================================================================
puts "================================================================="
puts [format "Protocol = %s\tConnection Type = %s" $arg0 $arg1] 
puts [format "Nodes = %d\tConnections = %d" $arg2 $arg3] ;
puts [format "Speed = %d\tPause Time = %d" $arg4 $arg5] ;#Print These Argments
puts "Please Wait.....!" 				
puts " " 	
puts " " 

# =======================================================================================
# Define Simulation Options
# =======================================================================================
set opt(chan)         Channel/WirelessChannel  		;# channel type
set opt(prop)         Propagation/TwoRayGround 		;# radio-propagation model
set opt(ant)          Antenna/OmniAntenna      		;# Antenna type
set opt(ll)           LL                       		;# link layer type
set opt(ifqlen)       150                       	;# max packet in ifq
set opt(netif)        Phy/WirelessPhy          		;# network interface type
set opt(mac)          Mac/802_11               		;# MAC type
set opt(rp)           $arg0              		;# routing protocol 
set opt(nn)           $arg2                      	;# number of nodes
set opt(x)            $arg6                      	;# x coordinates
set opt(y)            $arg7                      	;# y coordinates
set opt(stop)	      $arg8		       		;# simulation time
set opt(cs)           $arg9             		;# connection scenario
set opt(ms)           $arg10             		;# movement scenario 
set opt(tr)           $arg11              		;# Output trace file 
if { $opt(rp) == "DSR"} {
    set opt(ifq) CMUPriQueue;				;# interface queue type
} else {
    set opt(ifq) Queue/DropTail/PriQueue;		;# interface queue type
}
# ==============================================================================

set ns_    [new Simulator]

#Trace in new format 
$ns_ use-newtrace

set tracefd     [open $opt(tr) w]
$ns_ trace-all $tracefd           

set wtopo	[new Topography]
$wtopo load_flatgrid $opt(x) $opt(x)

set god_ [create-god $opt(nn)]

set chan_1_ [new $opt(chan)]

# Configure nodes
$ns_ node-config -adhocRouting $opt(rp) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 -topoInstance $wtopo \
                 -channel $chan_1_ \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace OFF \
                 -movementTrace OFF


# =======================================================================================
# Initialize nodes
# =======================================================================================
for {set i 0} {$i <= $opt(nn) } {incr i} {
    set node_($i) [$ns_ node]
    $node_($i) random-motion 0
}

# =======================================================================================
# Loading connection scenario
# =======================================================================================
puts "Loading connection scenario..."
source $opt(cs)

# =======================================================================================
# Loading movement scenario
# =======================================================================================
puts "Loading movement scenario..."
source $opt(ms)



# =======================================================================================
# Tell nodes when the simulation ends
# =======================================================================================
for {set i 0} {$i <= $opt(nn) } {incr i} {
    $ns_ at $opt(stop) "$node_($i) reset";
}

$ns_ at $opt(stop).0001 "stop"
$ns_ at $opt(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
    global ns_ tracefd
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run
