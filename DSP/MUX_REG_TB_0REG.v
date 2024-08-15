module MUX_REG_TB_0REG();
    //signal declaration
    reg En,clk,rst;
    reg [17:0]D,X;
    wire [17:0] OUt;
    integer i;
    //DUT instantiation
    MUX_REG #(.Reg(0))DUt(En,clk,rst,D,X,OUt);
    //clock genertation
    initial begin
        clk=0;
        forever begin
        #1 clk=~clk;
        end
    end
    //Test the Stimulus
    initial begin
        rst=1;
        En=0;
        D=0;
        X=0;
        @(negedge clk);
        rst=0;
        En=1;
        for (i =0 ;i<10 ;i=i+1 ) begin
            D=$random;
            X=$random;
            @(negedge clk);
        end
        En=0;
        for (i =0 ;i<10 ;i=i+1 ) begin
            D=$random;
            X=$random;
            @(negedge clk);
        end
        $stop;
    end
    //monitors the inputs and outputs
    initial begin
        $monitor("D=%b X=%b  En=%b out=%b ",D,X,En,OUt);
    end
endmodule