 function queueMoreData(src,~)
 % Callback function to reload the trigger signals.
 
 global SignalDAQ
 
 src.queueOutputData(SignalDAQ);