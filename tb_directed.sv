`timescale 1ns/1ps
module tb_directed;
    logic       clk;
    logic       rst_n;
    logic       in_valid;
    logic [7:0] a;
    logic [7:0] b;
    logic       cin;
    logic [3:0] opcode;

    logic       out_valid;
    logic [15:0] result;
    logic       cout;
    logic       zero;
    logic       neg;
    logic       ovf;
    logic       err;
	
    localparam logic [3:0] ADD  = 4'h0;
    localparam logic [3:0] ADDC = 4'h1;
    localparam logic [3:0] SUB  = 4'h2;
    localparam logic [3:0] SUBB = 4'h3;
    localparam logic [3:0] AND_ = 4'h4;
    localparam logic [3:0] OR_  = 4'h5;
    localparam logic [3:0] XOR_ = 4'h6;
    localparam logic [3:0] NOT_ = 4'h7;
    localparam logic [3:0] SHL  = 4'h8;
    localparam logic [3:0] SHR  = 4'h9;
    localparam logic [3:0] ROL  = 4'hA;
    localparam logic [3:0] ROR  = 4'hB;
    localparam logic [3:0] MUL  = 4'hC;
    localparam logic [3:0] CMP  = 4'hD;

    alu dut(
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (in_valid),
        .a         (a),
        .b         (b),
        .cin       (cin),
        .opcode    (opcode),
        .out_valid (out_valid),
        .result    (result),
        .cout      (cout),
        .zero      (zero),
        .neg       (neg),
        .ovf       (ovf),
        .err       (err)
	);


    initial begin
	clk=1'b0;
	forever #5 clk=~clk;
    end	
    

    integer pass_count = 0;
    integer fail_count = 0;


    task automatic reset_dut;
        begin
            rst_n    = 1'b0;
            in_valid = 1'b0;
            a        = 8'h00;
            b        = 8'h00;
            cin      = 1'b0;
            opcode   = ADD;

            #2;

            rst_n = 1'b1;

            @(posedge clk);
        end
    endtask

   
    task automatic check_case (
        input string       name,
        input logic [7:0]  a_i,
        input logic [7:0]  b_i,
        input logic        cin_i,
        input logic [3:0]  opcode_i,

        input logic [15:0] expected_result,
        input logic        expected_cout,
        input logic        expected_zero,
        input logic        expected_neg,
        input logic        expected_ovf,
        input logic        expected_err
    );

        begin
           
            @(negedge clk);
            a        = a_i;
            b        = b_i;
            cin      = cin_i;
            opcode   = opcode_i;
            in_valid = 1'b1;

            @(posedge clk);     // ??? DUT ????? ??? inputs

            @(negedge clk);     // ??? ?? cycle: ??????? ?????
            in_valid = 1'b0;

            

            if (
                out_valid === 1'b1 &&
                result    === expected_result &&
                cout      === expected_cout   &&
                zero      === expected_zero   &&
                neg       === expected_neg    &&
                ovf       === expected_ovf     &&
                err       === expected_err
            ) begin

                $display(
                    "PASS: %-35s result=%h cout=%b zero=%b neg=%b ovf=%b err=%b",
                    name,
                    result,
                    cout,
                    zero,
                    neg,
                    ovf,
                    err
                );

                pass_count++;

            end else begin

               $display("%0t FAIL: %-35s", $time, name);

                $display(
                    "      Expected: valid=1 result=%h cout=%b zero=%b neg=%b ovf=%b err=%b",
                    expected_result,
                    expected_cout,
                    expected_zero,
                    expected_neg,
                    expected_ovf,
                    expected_err

                );

                $display(
                    "      Actual:   valid=%b result=%h cout=%b zero=%b neg=%b ovf=%b err=%b",
                    out_valid,
                    result,
                    cout,
                    zero,
                    neg,
                    ovf,
                    err
                );

                fail_count++;
            end
        end

    endtask

    initial begin

     

     
        rst_n    = 1'b0;
        in_valid = 1'b0;
        a        = 8'h00;
        b        = 8'h00;
        cin      = 1'b0;
        opcode   = ADD;

       
        reset_dut();

        check_case(
            "1. ADD 5 + 3 = 8",
            8'd5,
            8'd3,
            1'b0,
            ADD,
            16'h0008,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0
        );


        check_case(
            "2. ADD 200 + 100",
            8'd200,
            8'd100,
            1'b0,
            ADD,
            16'h002C,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0
        );


        check_case(
            "3. ADD 7F + 01 overflow",
            8'h7F,
            8'h01,
            1'b0,
            ADD,
            16'h0080,
            1'b0,
            1'b0,
            1'b1,
            1'b1,
            1'b0
        );


        check_case(
            "4. SUB 10 - 10",
            8'd10,
            8'd10,
            1'b0,
            SUB,
            16'h0000,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b0
        );


        check_case(
            "5. SUB 3 - 5 borrow",
            8'd3,
            8'd5,
            1'b0,
            SUB,
            16'h00FE,
            1'b1,
            1'b0,
            1'b1,
            1'b0,
            1'b0
        );


        check_case(
            "6. CMP 5 - 5",
            8'd5,
            8'd5,
            1'b0,
            CMP,
            16'h0000,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b0
        );


        check_case(
            "7. AND F0 & 0F",
            8'hF0,
            8'h0F,
            1'b0,
            AND_,
            16'h0000,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b0
        );


        check_case(
            "8. SHL 81 << 1",
            8'h81,
            8'h01,
            1'b0,
            SHL,
            16'h0002,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0
        );

     
        check_case(
            "9. MUL 255 * 255",
            8'hFF,
            8'hFF,
            1'b0,
            MUL,
            16'hFE01,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0
        );


        check_case(
            "10. Reserved opcode E",
            8'h55,
            8'hAA,
            1'b0,
            4'hE,
            16'h0000,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b1
        );


        $display("");
        $display("Testing asynchronous reset during transaction...");

        @(negedge clk);

        a        = 8'h55;
        b        = 8'hAA;
        opcode   = ADD;
        cin      = 1'b0;
        in_valid = 1'b1;

        @(posedge clk);

       
        #2;

        rst_n = 1'b0;

        #1;

        if (
            out_valid === 1'b0 &&
            result    === 16'h0000 &&
            cout      === 1'b0 &&
            zero      === 1'b0 &&
            neg       === 1'b0 &&
            ovf       === 1'b0 &&
            err       === 1'b0
        ) begin

            $display("PASS: Reset clears all outputs asynchronously");
            pass_count++;

        end else begin

            $display("FAIL: Reset did not clear outputs");
            $display(
                "      Actual: valid=%b result=%h cout=%b zero=%b neg=%b ovf=%b err=%b",
                out_valid,
                result,
                cout,
                zero,
                neg,
                ovf,
                err
            );

            fail_count++;
        end

        
        in_valid = 1'b0;
        rst_n    = 1'b1;

        @(posedge clk);


        $display("");
        $display("==============================================");
        $display("TEST SUMMARY");
        $display("==============================================");
        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);
        $display("==============================================");

        if (fail_count != 0)
            $display("OVERALL RESULT: FAIL");
        else
            $display("OVERALL RESULT: PASS");

        $finish;
    end

endmodule
