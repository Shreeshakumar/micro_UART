`default_nettype none

module u_rec #(
    parameter DATA_LEN = 8
)(
    input  wire                     sys_clk,
    input  wire                     sys_rst_l,
    input  wire                     xmitH,
    input  wire                     baud_rec,
    input  wire                     uart_REC_dataH,

    output wire                     rec_readyH,
    output wire                     rec_busy,
    output reg [DATA_LEN-1:0]       rec_dataH
);
		
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam REC   = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] CS, NS;
    reg [3:0] sample_cnt;
    reg [$clog2(DATA_LEN):0] bit_cnt;
    reg [DATA_LEN-1:0] temp_register;

    always @(posedge sys_clk or negedge sys_rst_l)
    begin
        if (!sys_rst_l)
            CS <= IDLE;
        else
            CS <= NS;
    end

    always @(*)
    begin
        NS = CS;

        case (CS)

            IDLE:
            begin
                if (~xmitH && uart_REC_dataH == 1'b0)
                    NS = START;
            end

            START:
            begin
                if (baud_rec && sample_cnt == 4'd15)
                    NS = REC;
            end

            REC:
            begin
                if (baud_rec && bit_cnt == (DATA_LEN - 1) && sample_cnt == 4'd15)
                    NS = STOP;
            end

            STOP:
            begin
                if (baud_rec && sample_cnt == 4'd15)
                    NS = IDLE;
            end

            default:
                NS = IDLE;

        endcase
    end
    
    always @(posedge sys_clk or negedge sys_rst_l)
    begin
        if (!sys_rst_l)
        begin
            sample_cnt    <= 0;
            bit_cnt       <= 0;
            temp_register <= 0;
            rec_dataH     <= 0;
        end

        else if (baud_rec)
        begin
            case (CS)
                IDLE:
                begin
                    sample_cnt <= 0;
                    bit_cnt    <= 0;
                end

                START:
                begin
                    sample_cnt <= sample_cnt + 1'b1;

                    if (sample_cnt == 4'd15)
                        sample_cnt <= 0;
                end

                REC:
                begin
                    sample_cnt <= sample_cnt + 1'b1;

                    // sample at middle of baud
                    if (sample_cnt == 4'd8)
                    begin
                        temp_register[bit_cnt] <= uart_REC_dataH;
                        bit_cnt <= bit_cnt + 1'b1;
                    end

                    if (sample_cnt == 4'd15)
                        sample_cnt <= 0;
                end

                STOP:
                begin
                    sample_cnt <= sample_cnt + 1'b1;

                    if (sample_cnt == 4'd15)
                    begin
                        rec_dataH  <= temp_register;
                        sample_cnt <= 0;
                    end
                end

            endcase
        end
    end

    assign rec_readyH = (CS == IDLE);
    assign rec_busy   = (CS != IDLE);

endmodule
