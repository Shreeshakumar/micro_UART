# Micro UART Design

### baudrate 1200 2400 9600 19200
### default 2400

### data length 6-8bits
### default 8

## tx = xmit
## rx = REC

### remote -> other reciever

## input	
		sys_clk			1b	main sys clock
		sys_rst_l		1b	main sys reset
		xmitH			1b	active high -> uart clock with baudrate pulse starts the trasmit process
		xmit_dataH 		8b	data to m=be sent, This data is sample when xmith high
		uart_REC_dataH	1b	asynchromous input data

## output	
		uart_XMIT_dataH	1b	ouput asynchronous transmitter
		xmit_doneH		1b	when active high thhis indictes that the xmit_dataH has been fully transmitted
		rec_readyH		8b	de-serialized recieved from the remote
		rec_dataH		1b	when high indicates fresh data is available on rec_dataH
		rec_busy		1b	indicates if the transmitter is actively transmitting a data
		xmit_active		1b	indicatedd if the receiver is currently busy
		
## data packet

start bit	0
data bit	8b
parity bit	p
stop bit	1				
	
internal clock 16x than baud rate =>   1/16 granularity in baud rate period

incoming data is not sampled by reciever

its done through synchronizer
clock domain (tx) => recievers

bit cell center -> rx sample data bit

	
	
	
	
	
	
