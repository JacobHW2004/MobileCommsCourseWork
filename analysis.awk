#
#  This AWK script calulates various network peformance metrics by analyzing the output 
#  of a trace file. It accepts four arguments:
#  	Connection Type 				$T
#  	Protocol Name 					$R
#  	Node Number					$N
#  	Connections Number				$C
#  	Miximum Speed 					$S
#	Pause Time					$P
#  	Iteration Number				$F
#
#  The command format is:
#
#  awk -f analysis.awk '$R-$N-$A-$C-$M-$P-$F-$T.tr' >> $R-$N-$C-$M-$P.txt
#
#  The script prints the following values respectively: 
#
# *	Simulation Start Time				start_time
# *  	Simulation End Time				stop_time
# *  	Number of Sent Packets				send_pkts
# *  	Number of Received Packets			recv_pkts
# *  	Packet Delivery Ratio				PDR
# *	Throughput [Kbps]				Thru
# *	End-to-End Delay [ms]				Delay
# *	Normalized Routing Load				NRL
# *	Routing Overhead				rt_pkts
#
#  The code is created by Mohamed Abdelshafy
#
#  Copyright (c) 2014 by the Heriot-Watt University
#  All rights reserved.
# 

BEGIN {

    send_pkts = 0;	# sent data packets
    recv_pkts = 0;	# received data packets

    rt_pkts = 0;	# total control packets 
    rt_size = 0;	# total control packets size
    
    start_time = 600;	# simulation start sending time
    stop_time = 0;	# simulation end receiving time
    recv_delay = 0;	# total transmission time

} 

{    
   
 # New trace format parameters

    event = $1;     	# event which is s,r,f or d
    time = $3;      	# time which is the value after -t
    pkt_type= $35;  	# packet type which is the value after -It  
    packet_id = $41;	# packet id which is the value after -Ii
    pkt_size = $37; 	# packet size which is the value after -Il 
    level = $19;	# trace level which is the value after -Nl (AGT, RTR, MAC)
    node_id = $9;  	# node id which is the value after -Ni  

#=============================== Start of Calculations Initialization ====================================


#================================== Start of Routing Calculations ======================================

  # Calculate numbers of different contol packets
  if ((event == "s" || event == "f") && level == "RTR" && (pkt_type == "AODV" || pkt_type == "DSR" || pkt_type == "message"))
  {
      rt_pkts++;
      rt_size += pkt_size;
  }
 
#==================================== End of Routing Calculations ======================================

#==================================== Start of Data Calculations =======================================

  # Calculate send time and receive time for each packet 
  if (event == "s" && level == "AGT" && (pkt_type == "cbr" || pkt_type == "tcp")) 
      send_time[packet_id] = time;

  if (event == "r" && level == "AGT" && (pkt_type == "cbr" || pkt_type == "tcp")) 
      recv_time[packet_id] = time;

  # Calculate sent data packets and size
  if (event == "s" && level == "AGT" && (pkt_type == "cbr" || pkt_type == "tcp"))
  {
    send_pkts++;

    # Claculate the first send time in the simulation
    if (time < start_time) {
      start_time = time;
      }
  }

  # Calculate received data packets and size
  if (event == "r" && level == "AGT" && (pkt_type == "cbr" || pkt_type == "tcp"))
  {

    # Claculate the last receive time in the simulation
    if (time > stop_time) 
      stop_time = time;

      recv_pkts++;
      recv_size += pkt_size;
  }

      
#===================================== End of Data Calculations ========================================


#================================ End of Calculations Initialization =====================================

}
   
END {
 
#================================ Start of Dely Calculations =================================

  for (i in recv_time)
  {
    if (drop_time[packet_id] == 0) 
    {
      delay_time[i] = recv_time[i] - send_time[i];

      if (delay_time[i] > 0)  
      {    
	recv_delay += delay_time[i];
	recv_num++; 
      }
    }
  } 


#================================== End of Dely Calculations  ================================

    simulation_time = stop_time - start_time;
    if (simulation_time == 0)
      simulation_time = tt; 					# to avoid division by Zero

    if (send_pkts == 0)
      send_pkts++; 						# to avoid division by Zero

    if (recv_pkts == 0) 
      RCV = recv_pkts + 1;					# to avoid division by Zero
    else
      RCV = recv_pkts;

    if (recv_num == 0)
      recv_num++; 						# to avoid division by Zero

    if (request_num == 0)
      request_num++; 						# to avoid division by Zero

     PDR = (recv_pkts/send_pkts)*100;
     Thru = (recv_size/simulation_time)*(8/1000);		# measured in Kbps
     Delay = (recv_delay/recv_num)*1000;			# measured in ms
     NRL = (rt_pkts/RCV)*100;
  
  printf("\t%.1f", start_time); 
  printf("\t%.1f", stop_time); 
  printf("\t%d", send_pkts);	 
  printf("\t%d", recv_pkts);	 
  printf("\t%.2f", PDR);             
  printf("\t%.2f", Thru);             
  printf("\t%.2f", Delay);      
  printf("\t%.2f", NRL);             
  printf("\t%d", rt_pkts);	 
  printf("\t%d\n", rt_size);	 
    
}     
