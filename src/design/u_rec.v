`default_nettype none

module u_rec #(
    parameter DATA_LEN = 8,
    parameter sampling = 16
)(
    input  wire                     sys_clk,
    input  wire                     sys_rst_l,
    input  wire                     xmit_active,
    input  wire                     baud_rec,
    input  wire                     uart_REC_dataH,

    output wire                     rec_readyH,
    output wire                     rec_busy,
    output reg  [DATA_LEN-1:0]      rec_dataH      
);

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam REC   = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] CS, NS;

    reg [$clog2(sampling)-1:0]   sample_cnt;
    reg [$clog2(DATA_LEN)-1:0]   bit_cnt;
    reg [DATA_LEN-1:0]           temp;

    always @(posedge sys_clk or posedge sys_rst_l)
    begin
        if (sys_rst_l)
            CS <= IDLE;
        else
            CS <= NS;
    end

    always @(posedge sys_clk or posedge sys_rst_l)
    begin
        if (sys_rst_l) begin
            sample_cnt <= 'd0;
            bit_cnt    <= 'd0;
            temp       <= 'd0;
            rec_dataH  <= 'd0;
        end
        else begin
            case (CS)

                IDLE: begin
                    if (xmit_active && uart_REC_dataH == 1'b0) begin
                        sample_cnt <= 'd0;
                    end
                end

                START: begin
                    if (baud_rec) begin
                        if (sample_cnt == sampling - 1) begin
                            sample_cnt <= 'd0;
                            bit_cnt    <= 'd0;
                        end else begin
                            sample_cnt <= sample_cnt + 'd1;
                        end
                    end
                end

                REC: begin
                    if (baud_rec) begin
                        if (sample_cnt == sampling - 1) begin
                            temp[bit_cnt] <= uart_REC_dataH;
                            bit_cnt       <= bit_cnt + 1'b1;
                            sample_cnt    <= 'd0;
                            if (bit_cnt == DATA_LEN - 1) begin
                                rec_dataH <= {uart_REC_dataH, temp[DATA_LEN-2:0]};
                            end
                        end else begin
                            sample_cnt <= sample_cnt + 'd1;
                        end
                    end
                end

                STOP: begin
                    if (baud_rec) begin
                        if (sample_cnt == sampling - 1) begin
                            sample_cnt <= 'd0;
                        end else begin
                            sample_cnt <= sample_cnt + 'd1;
                        end
                    end
                end

            endcase
        end
    end

    always @(*)
    begin
        NS = CS; 
        case (CS)

            IDLE: begin
                if (xmit_active && uart_REC_dataH == 1'b0)
                    NS = START;
            end

            START: begin
                if (baud_rec && sample_cnt == sampling - 1)
                    NS = REC;
            end

            REC: begin
                if (baud_rec && sample_cnt == sampling - 1 && bit_cnt == DATA_LEN - 1)
                    NS = STOP;
            end

            STOP: begin
                if (baud_rec && sample_cnt == sampling - 1 && uart_REC_dataH == 1'b1)
                    NS = IDLE;
            end

            default:
                NS = IDLE;

        endcase
    end

    assign rec_readyH = (CS == IDLE);
    assign rec_busy   = (CS != IDLE);

endmodule
