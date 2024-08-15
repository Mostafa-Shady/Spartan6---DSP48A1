module MUX_REG(En,CLK,rst,D,X,OUT,SEL);
    //parameters
    parameter N_MUX=18;
    parameter N_REG=18;
    parameter RSTTYPE="SYNC";
     //Registers 
    input En,CLK,rst;
    input [N_REG-1:0] D;
    //MUX
    input [N_MUX-1:0] X;
    output reg [N_MUX-1:0] OUT;
    input SEL;
    reg [N_REG-1:0]Q;
generate
        //synchronous register
        if (RSTTYPE=="SYNC") begin
            always @(posedge CLK) begin
            if (rst) begin
                Q<=0;
            end
            else begin
            if (En) begin
                Q<=D;
            end
                else Q<=Q;
            end
        end 
    end
    //Asynchronous 
        if (RSTTYPE=="ASYNC") begin
            always @(posedge CLK or posedge rst) begin
            if (rst) begin
                Q<=0;
            end
            else begin
            if (En) begin
                Q<=D;
            end
            else Q<=Q;
           end
        end
    end
endgenerate
//assign output MUX
   always @(*)begin
        if(SEL)
            OUT=Q;
        else OUT=X;
   end 
endmodule