

 typedef enum logic [3:0] {
    OP_ADD   = 4'h0,
    OP_ADDC  = 4'h1,
    OP_SUB   = 4'h2,
    OP_SUBB  = 4'h3,
    OP_AND   = 4'h4,
    OP_OR    = 4'h5,
    OP_XOR   = 4'h6,
    OP_NOT   = 4'h7,
    OP_SHL   = 4'h8,
    OP_SHR   = 4'h9,
    OP_ROL   = 4'hA,
    OP_ROR   = 4'hB,
    OP_MUL   = 4'hC,
    OP_CMP   = 4'hD,
    OP_RSV_E = 4'hE,
    OP_RSV_F = 4'hF
  } opcode_e;


typedef struct packed{

  logic [15:0] result;
  logic cout;
  logic zero;
  logic neg;
  logic ovf;
  logic err;
  
}alu_out; 



module alu (
  input  logic        clk,
  input  logic        rst_n,     
  input  logic        in_valid,
  input  logic [7:0]  a,
  input  logic [7:0]  b,
  input  logic        cin,
  input  logic [3:0]  opcode,
  output logic        out_valid,
  output logic [15:0] result,
  output logic        cout,
  output logic        zero,
  output logic        neg,
  output logic        ovf,
  output logic        err
  
);

opcode_e op;  

alu_out out_n;
alu_out out_q;

logic [8:0]   a9, b9, amt9, res9;
logic [7:0]   res8;
logic [15:0]  wide;
logic [15:0]  prod16;
logic [2:0]   sh;
logic         cin_eff;
logic         cout_l, ovf_l;
logic         is_mul, is_cmp, is_rsv;
  
assign op =opcode_e'(opcode);
  
  
  
always_comb begin
    out_n   = '0;
    res9    = '0;
    res8    = '0;
    wide    = '0;
    prod16  = '0;
    cout_l  = 1'b0;
    ovf_l   = 1'b0;
    is_mul  = 1'b0;
    is_cmp  = 1'b0;
    is_rsv  = 1'b0;
    a9={1'b0,a};
    b9={1'b0,b};
    sh=b[2:0];
    cin_eff=((op==OP_ADDC)||(op==OP_SUBB))?cin:1'b0;
    amt9=b9+{8'h00,cin_eff};
  	case (op)
        OP_ADD,OP_ADDC:  begin
          res9=a9+b9+{8'h00,cin_eff};
          res8=res9[7:0];
          cout_l=res9[8];
          ovf_l=(a[7]==b[7])&&(res8[7]!=a[7]);
          
        end
    
      
        OP_SUB,OP_SUBB,OP_CMP:  begin
          res9=a9-amt9;
          res8=res9[7:0];
          cout_l=(a9<amt9);
          ovf_l=(a[7]!=b[7])&&(res8[7]!=a[7]);
          is_cmp=(op==OP_CMP);
        end 
       
        OP_AND:  begin
          res8=a&b;
          
        end
        OP_OR:   begin
          res8=a|b;
          
        end
        OP_XOR:  begin
          res8=a^b;
          
        end
        OP_NOT:  begin
          res8=~a;
          
        end 
        OP_SHL:  begin
          wide={8'h00,a}<<sh;
          res8=wide[7:0];
          cout_l=wide[8];
          
        end
        OP_SHR: begin
          wide={a,8'h00}>>sh;
          res8=wide[15:8];
          cout_l=wide[7];
          
          
        end  
        OP_ROL: begin
          wide={a,a}<<sh;
          res8=wide[15:8];
          
          
        end   
        OP_ROR: begin
          wide={a,a}>>sh;
          res8=wide[7:0];
          
        end  
      
        OP_MUL: begin
          prod16= {8'h00,a}*{8'h00,b};
          is_mul=1'b1;
          
        end  
       
        OP_RSV_E, OP_RSV_F: 
          is_rsv = 1'b1;
        default:
          is_rsv = 1'b1;
    endcase
  
    if (is_rsv) begin
		out_n='0;
		out_n.err=1'b1;



    end
  	
    else if(is_mul) begin
      	out_n.result=prod16;
        out_n.zero  =(prod16==16'h0000);




    end
  	else begin 
        out_n.result=is_cmp?16'h0000:{8'h00,res8};
      out_n.zero=(res8==8'h00);
      out_n.neg=res8[7];
      out_n.cout=cout_l;
      out_n.ovf=ovf_l;
      
      
      
    end  
  
end
   
always_ff @(posedge clk or negedge rst_n) begin
    
  if(!rst_n) begin
    out_valid<=1'b0;
    out_q<='0;
    
    
  end
  
  else begin 
    out_valid<=in_valid;
    out_q    <=in_valid?out_n:'0;
    
  end

end
  assign result = out_q.result;
  assign cout   = out_q.cout;
  assign zero   = out_q.zero;
  assign neg    = out_q.neg;
  assign ovf    = out_q.ovf;
  assign err    = out_q.err;

endmodule : alu    
 
  
  
  