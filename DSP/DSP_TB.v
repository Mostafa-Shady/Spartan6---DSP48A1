module DSP_TB ();
    //DATA PORST
    reg [17:0] A,B,D;
    reg [47:0]C;
    wire [35:0] M;
    reg [17:0]BCIN;
    reg CARRYIN;
    wire [47:0] P;
    wire CARRYOUT,CARRYOUTF;
    //CLOCK ENABLE INPUT PORTS
    reg CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP;
    //RESET INPUT PORTS
    reg RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP;
    //CASCADE PORTS
    wire [17:0]BCOUT;
    wire [47:0]PCOUT;
    reg [47:0]PCIN;
    //CONTROL INPUT PORTS
    reg CLK;
    reg [7:0] OPMODE;
    integer k;
    //DUT isntantiation
    DSP DUT(A,B,D,C,M,BCIN,CARRYIN,P,CARRYOUT,CARRYOUTF,CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP,RSTA,RSTB,RSTC
    ,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP,BCOUT,PCOUT,PCIN,CLK,OPMODE);
    //Clock generation
    initial begin
        CLK=0;
        forever begin
            #1 CLK=~CLK;
        end
    end    
    //Test The Stimulus
    initial begin
            RSTA=1;
            RSTB=1;
            RSTC=1;
            RSTCARRYIN=1;
            RSTD=1;
            RSTM=1;
            RSTOPMODE=1;
            RSTP=1;
            CEA=1;
            CEB=1;
            CEC=1;
            CECARRYIN=1;
            CED=1;
            CEM=1;
            CEOPMODE=1;
            CEP=1;
            BCIN=0;
            @(negedge CLK);
            RSTA=0;
            RSTB=0;
            RSTC=0;
            RSTCARRYIN=0;
            RSTD=0;
            RSTM=0;
            RSTOPMODE=0;
            RSTP=0;
            CARRYIN=0; 
            BCIN=0;    
            //Test The Pre/Adder_Sub(Addition)
            D=10; B=10; OPMODE[6]=0; OPMODE[4]=1;
            repeat(2)@(negedge CLK);
            //Test The Pre/Adder_Sub(Sub)
            D=30; B=20; OPMODE[6]=1; OPMODE[4]=1;
            repeat(2)@(negedge CLK);
            //Bypass The B to Mull
            D=10; B=5; OPMODE[6]=0; OPMODE[4]=0;
            repeat(3)@(negedge CLK);
            //Try The mul From The Bypass B
            D=10; B=5; A=10; OPMODE[6]=0; OPMODE[4]=0;
            repeat(1)@(negedge CLK);
            //Try The mul after the pre adder
            D=10; B=5; A=10; OPMODE[6]=0; OPMODE[4]=1;
            repeat(4)@(negedge CLK);
            //Try The Post Adder
            D=10; B=5; A=10; PCIN=100; OPMODE[6]=0; OPMODE[4]=1; OPMODE[3:2]=2'b01;OPMODE[1:0]=2'b01; OPMODE[7]=0; OPMODE[5]=0;
            repeat(2)@(negedge CLK);
            //Try The Post Adder With Carry in=1 and pcin P=250
            D=10; B=5; A=10; PCIN=100; OPMODE[6]=0; OPMODE[4]=1; OPMODE[3:2]=2'b01;OPMODE[1:0]=2'b01; OPMODE[7]=0; OPMODE[5]=1;
            repeat(4)@(negedge CLK);
            //Try The Post Adder With Carry in=0 and c=2 P
            D=10; B=5;  A=10; PCIN=100; C=2; OPMODE[6]=0; OPMODE[4]=1; OPMODE[3:2]=2'b11; OPMODE[1:0]=2'b01; OPMODE[7]=0; OPMODE[5]=0;
            repeat(4)@(negedge CLK);
            //Try The Post SUB
            D=10; B=5;  A=10; PCIN=4; C=200; OPMODE[6]=0; OPMODE[4]=1; OPMODE[3:2]=3;OPMODE[1:0]=1; OPMODE[7]=1; OPMODE[5]=0;
            repeat(5)@(negedge CLK);
            //Try The Post SUB
            D=10; B=5;  A=10; PCIN=500; C=5; OPMODE[6]=0; OPMODE[4]=1; OPMODE[3:2]=1;OPMODE[1:0]=1; OPMODE[7]=1; OPMODE[5]=0;
            repeat(5)@(negedge CLK);
            //Random
            for (k =0 ;k<10 ;k=k+1 ) begin
                OPMODE=$random;
                A=500;
                B=200;
                C=600;
                D=1000;
                PCIN=3000;
                repeat(6)@(negedge CLK);
            end
            $stop;
    end
endmodule