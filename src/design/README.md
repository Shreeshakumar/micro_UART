## Design Modules

### uart.v 
	-> top_module
	-> NO logic

### u_xmit.v 
	-> asynchronous transmitter
	-> a state machine serializer

### u_rec.v 
	-> asynchronous reciever
	-> dual rank synchronizer
	-> state machine
	
### baud.v 
	-> baudrate generator
	-> 1/16 of clock

### inc.h
	-> configuration file	(header file)
	-> baudrate	default 2400
	-> data_length 8
