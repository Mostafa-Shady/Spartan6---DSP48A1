module DSP #(
    parameter  A0REG=0,
    parameter  A1REG=1,
    parameter  B0REG=0,
    parameter  B1REG=1,
    parameter   CREG=1,
    parameter   DREG=1,
    parameter   MREG=1,
    parameter   PREG=1,
    parameter   CARRYINREG=1,
    parameter   CARRYOUTREG=1,
    parameter   OPMODEREG=1,   
    parameter   CARRYINSEL="OPMODE5",
    parameter   B_INPUT="DIRECT",
    parameter   RSTTYPE="SYNC"
) (
    //DATA PORST
    input [17:0] A,B,D,
    input  [47:0]C,
    output [35:0] M,
    input [17:0]BCIN,
    input CARRYIN,
    output [47:0] P,
    output CARRYOUT,CARRYOUTF,
    //CLOCK ENABLE INPUT PORTS
    input CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP,
    //RESET INPUT PORTS
    input RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP,
    //CASCADE PORTS
    output [17:0]BCOUT,
    output [47:0]PCOUT,
    input [47:0]PCIN,
    //CONTROL INPUT PORTS
    input CLK,
    input [7:0] OPMODE
);
    //////////////////////////////////////////////////////
    //OPMODE Port Logic
    ////////////////////////////////////////////////////////
    wire [7:0] OPMODE_out;
    MUX_REG #(.N_MUX(8),.N_REG(8),.RSTTYPE(RSTTYPE)) Opmode_Reg(CEOPMODE,CLK,RSTOPMODE,OPMODE,OPMODE,OPMODE_out,OPMODEREG);
    //////////////////////////////////////////////////////
    // B and D input logic
    //////////////////////////////////////////////////////
    wire [17:0] out_B_MUX,B0_out,B1_out,D_mux_out,out_mux_INB1,pre_adder_sub_out;
    MUX_REG #(.RSTTYPE(RSTTYPE)) D_in(CED,CLK,RSTD,D,D,D_mux_out,DREG);//D_reg
    assign out_B_MUX=(B_INPUT=="DIRECT")?B:(B_INPUT=="CASCADE")?BCIN:0;//choose Between B and BCIN 
    MUX_REG #(.RSTTYPE(RSTTYPE)) B0_in(CEB,CLK,RSTB,out_B_MUX,out_B_MUX,B0_out,B0REG);// B0 input
    assign pre_adder_sub_out=(OPMODE_out[6]==1'b1)?(D_mux_out-B0_out):(D_mux_out+B0_out);//PREAdder_SUB
    assign out_mux_INB1=(OPMODE_out[4]==1'b1)?pre_adder_sub_out:B0_out;//Choose between Adder_sub and Binput
    MUX_REG #(.RSTTYPE(RSTTYPE)) B1_in(CEB,CLK,RSTB,out_mux_INB1,out_mux_INB1,B1_out,B1REG);//B1 Register
    assign BCOUT=B1_out;//assign Caryyout B
    //////////////////////////////////////////////////////
    // A input logic
    //////////////////////////////////////////////////////
    wire [17:0] A0_mux_out,A1_mux_out;
    MUX_REG #(.RSTTYPE(RSTTYPE)) A0(CEA,CLK,RSTA,A,A,A0_mux_out,A0REG);
    MUX_REG #(.RSTTYPE(RSTTYPE)) A1(CEA,CLK,RSTA,A0_mux_out,A0_mux_out,A1_mux_out,A1REG);
    //////////////////////////////////////////////////////
    // C input logic    
    //////////////////////////////////////////////////////
    wire [47:0] C_mux_out;
    MUX_REG #(.N_MUX(48),.N_REG(48),.RSTTYPE(RSTTYPE)) C_Reg(CEC,CLK,RSTC,C,C,C_mux_out,CREG);  
    //////////////////////////////////////////////////////
    //Multiplier Followed by Optional M REG
    //////////////////////////////////////////////////////
    wire [35:0] MUL_OUT;
    wire [35:0] M_INREG_X;
    assign MUL_OUT=B1_out*A1_mux_out;
    MUX_REG  #(.N_MUX(36),.N_REG(36),.RSTTYPE(RSTTYPE))M_Reg(CEM,CLK,RSTM,MUL_OUT,MUL_OUT,M_INREG_X,MREG);
    assign M=M_INREG_X;
    //assign M_INREG_X={12'b000000000000,M};
    ///////////////////////////////////////////////////////
    //Carry Input Logic Feeding the Post-Adder/Subtracter
    //////////////////////////////////////////////////////
    wire Carryin_Mux_out,CarryinReg_Mux_out;
    assign Carryin_Mux_out=(CARRYINSEL=="OPMODE5")?OPMODE_out[5]:(CARRYINSEL=="CARRYIN")?CARRYIN:0;
    MUX_REG #(.RSTTYPE(RSTTYPE),.N_MUX(1),.N_REG(1)) CYI(CECARRYIN,CLK,RSTCARRYIN,Carryin_Mux_out,Carryin_Mux_out,CarryinReg_Mux_out,CARRYINREG);
    //////////////////////////////////////////////////////
    //Simplified DSP48A1 Slice Model
    //////////////////////////////////////////////////////
    //X_mux
    wire [47:0] Con; 
    reg [47:0] X_mux_out;
    assign Con={{D_mux_out[11:0]},A1_mux_out,B1_out};
    always @(*) begin
        case (OPMODE_out[1:0])
            0:X_mux_out=0;
            1:X_mux_out={12'b0,M_INREG_X};
            2:X_mux_out=P;
            3:X_mux_out=Con;
            default: X_mux_out=0;
        endcase
    end
    //Z_mux
    reg [47:0] Z_mux_out;
    always @(*) begin
        case (OPMODE_out[3:2])
            0:Z_mux_out=0;
            1:Z_mux_out=PCIN;
            2:Z_mux_out=P;
            3:Z_mux_out=C_mux_out;
            default: Z_mux_out=0;
        endcase
    end
    //Post_Adder_Sub
    wire [47:0] Post_Adder_Sub_out;
    wire CarryOut_IN_Reg;
    assign {CarryOut_IN_Reg,Post_Adder_Sub_out}=(OPMODE_out[7]==0)?(Z_mux_out+(X_mux_out+CarryinReg_Mux_out)):(Z_mux_out-(X_mux_out+CarryinReg_Mux_out));
    //Carryout_REG
    MUX_REG #(.N_MUX(1),.N_REG(1),.RSTTYPE(RSTTYPE))CYO(CECARRYIN,CLK,RSTCARRYIN,CarryOut_IN_Reg,CarryOut_IN_Reg,CARRYOUT,CARRYOUTREG);
    assign  CARRYOUTF=CARRYOUT;
    //P Output Logic
    MUX_REG #(.N_MUX(48),.N_REG(48),.RSTTYPE(RSTTYPE)) P_Reg(CEP,CLK,RSTP,Post_Adder_Sub_out,Post_Adder_Sub_out,P,PREG);
    assign PCOUT=P;
endmodule