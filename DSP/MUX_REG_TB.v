module MUX_REG_TB();
    //signal declaration
    reg En,clk,rst,SEL;
    reg [17:0]D,X;
    wire [17:0] OUt;
    integer i;
    //DUT instantiation
    MUX_REG DUt(En,clk,rst,D,X,OUt,SEL);
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
        En=1;
        SEL=1;
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
        En=0;
        SEL=0;
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