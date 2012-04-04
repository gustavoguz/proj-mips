
module lru (
	input intfull_0,
	input intfull_1,
	input last,
	output reg next
	);
always @* begin
	case ({intfull_0,intfull_1,last})
	3'b000:	next = 1;
	3'b001:	next = 0;
	
	3'b010:	next = 0;
	3'b011:	next = 0;
	
	3'b100:	next = 1;
	3'b101:	next = 1;

	3'b110:	next = 1;
	3'b111:	next = 1;
	default:
		next = 0;
	endcase
end

endmodule 
