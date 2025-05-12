`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.05.2025 02:54:51
// Design Name: 
// Module Name: imageControl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// This is where the control logic for writing to the buffers and setting up the multiplexers is written
//////////////////////////////////////////////////////////////////////////////////


module imageControl(
input               i_clk,
input               i_rst,
input   [7:0]       i_pixel_data,
input               i_pixel_data_valid, // we are going to use this to know what line buffer to write to
output  reg [71:0]  o_pixel_data,       // there are 3 multiplexers so 3 8 bit pixels will be coming out at a given time
output              o_pixel_data_valid,
output  reg         o_intr
    );

reg [8:0] pixelCounter; // 9 bits because we need to reach 512
reg [1:0] currentWrLineBuffer;
reg [3:0] lineBufferDataValid; //need 4 bits for active and inactive nature of linebuffer
reg [3:0] lineBuffRdData;
reg [1:0] currentRdLineBuffer; // we need a signal to know which line buffers to read from
wire [23:0] lb0data;
wire [23:0] lb1data;
wire [23:0] lb2data;
wire [23:0] lb3data;
reg [8:0] rdCounter;
reg rd_line_buffer; // we need to read from line buffers but only when 3 are full (512 * 3 pixels total passed through)
reg [11:0] totalPixelCounter; // we need to store 4 line buffers so 512 * 4 = 2048 which requires 12 bits
reg rdState;

localparam IDLE = 'b0, // here we are making params for the states in our state machine which controls rd_line_buffer
    RD_BUFFER = 'b1;
    
assign o_pixel_data_valid = rd_line_buffer; // due to control logic with prefetching whenever rd_line_buffer is high we have valid data

// heres the control logic
//  we will use a counter (see above)to count out the width of the image (512), once it hits 512 we'll switch the next line buffer valid on and 
//  the previous one off    

//---------------------------------------------Count pixels---------------------------------------------//

always @(posedge i_clk)
begin
    if(i_rst)
        totalPixelCounter <= 0;
    else
    begin
        if(i_pixel_data_valid & !rd_line_buffer)        // if we have data but we are not reading from the line buffers
            totalPixelCounter <= totalPixelCounter + 1;
        else if (!i_pixel_data_valid & rd_line_buffer)  // if we dont have data but we are reading from the line buffers
            totalPixelCounter <= totalPixelCounter + 1;
    end
end

always @(posedge i_clk)
begin
    if(i_rst)
    begin
        rdState <= IDLE;   
        rd_line_buffer <= 1'b0;
        o_intr <= 1'b0;
    end
    else
    begin
        case(rdState)
            IDLE: begin
                o_intr <= 1'b0;
                if(totalPixelCounter > 1536) // if we fill all the line buffers we can actually read
                begin
                    rd_line_buffer <= 1'b1;
                    rdState <= RD_BUFFER;
                end
            end    
            RD_BUFFER: begin
                if (rdCounter == 511) // remember that read counter only starts counting when rd_line_buffer is active 
                begin                 // in the next clock this will kick in when we are reading the final pixel
                    rdState <= IDLE;  // go back to idle and check whether sufficient data is in the line buffers after reading a line
                    rd_line_buffer <= 1'b0;
                    o_intr <= 1'b1;
                end
            end
        endcase    
    end
end
//---------------------------------------------Count pixels---------------------------------------------//

//----------------------------------------------Write to correct line buffer code------------------------//
always@(posedge i_clk)
begin
    if(i_rst)
        pixelCounter <= 0;
    else
    begin
        if(i_pixel_data_valid)
            pixelCounter <= pixelCounter + 1;
    end
end

always@(posedge i_clk)
begin
    if(i_rst)
        currentWrLineBuffer <= 0;
    else
    begin
        if ((pixelCounter == 511) & i_pixel_data_valid) // this statement will trigger whilst pixel 512 is coming through
            currentWrLineBuffer <= currentWrLineBuffer + 1; // this logic will overflow so it will do what we want
    end

end

always@(*)
begin
    lineBufferDataValid = 4'h0; // all of them are 0
    lineBufferDataValid[currentWrLineBuffer] = i_pixel_data_valid; // except current write line buffer, use clever trick with data valid signal so that we wont store when not valid 
end

//----------------------------------------------Write to correct line buffer code------------------------//

//----------------------------------------------Read from correct line code------------------------------//

always@(*)
begin
// we will use currentRdBuffer signal to index what combo of lines we read from
// with a switch case we can know when to read a from each line buffer
    case(currentRdLineBuffer) // currentRdLineBuffer will overflow to reset the case appropriately
        0:begin
            o_pixel_data = {lb2data,lb1data,lb0data};
        end
        1:begin
            o_pixel_data = {lb3data,lb2data,lb1data};
        end
        2:begin
            o_pixel_data = {lb0data,lb3data,lb2data};
        end
        3:begin
            o_pixel_data = {lb1data,lb0data,lb3data};
        end
    endcase
end

always@(*)
begin
    case(currentRdLineBuffer)
    0:begin
        lineBuffRdData[0] = rd_line_buffer; // again a smart trick, we are using the rd_line_buffer signal (a read data valid signal) to set the appropriate bit of the reg to 1  
        lineBuffRdData[1] = rd_line_buffer;
        lineBuffRdData[2] = rd_line_buffer;
        lineBuffRdData[3] = 1'b0;
    end
    1:begin
        lineBuffRdData[0] = 1'b0;
        lineBuffRdData[1] = rd_line_buffer;
        lineBuffRdData[2] = rd_line_buffer;
        lineBuffRdData[3] = rd_line_buffer;
    end
    2:begin
        lineBuffRdData[0] = rd_line_buffer;
        lineBuffRdData[1] = 1'b0;
        lineBuffRdData[2] = rd_line_buffer;
        lineBuffRdData[3] = rd_line_buffer;
    end
    3:begin
        lineBuffRdData[0] = rd_line_buffer; 
        lineBuffRdData[1] = rd_line_buffer;
        lineBuffRdData[2] = 1'b0;
        lineBuffRdData[3] = rd_line_buffer;
    end
    endcase
end

always@(posedge i_clk)
begin
    if(i_rst)
        rdCounter <= 0;
    else
    begin
        if (rd_line_buffer)
            rdCounter <= rdCounter +1;
    end
end

always@(posedge i_clk)
// need code to control currentRdLineBuffer
begin
    if(i_rst)
    begin
        currentRdLineBuffer <= 0;
    end
    else
    begin
        if(rdCounter == 511 & rd_line_buffer)
            currentRdLineBuffer <= currentRdLineBuffer +1;
    end
end

//----------------------------------------------Read from correct line code------------------------------//

lineBuffer lbB0(                    // here we instantiate line buffer 0 (lB0) using our previously written code
    .i_clk(i_clk),          
    .i_rst(i_rst),          
    .i_data(i_pixel_data),   
    .i_data_valid(lineBufferDataValid[0]),   
    .o_data(lb0data),  
    .i_rd_data(lineBuffRdData[0])          
    );    

lineBuffer lbB1(                    // here we instantiate line buffer 0 (lB0) using our previously written code
    .i_clk(i_clk),          
    .i_rst(i_rst),          
    .i_data(i_pixel_data),   
    .i_data_valid(lineBufferDataValid[1]),   
    .o_data(lb1data),  
    .i_rd_data(lineBuffRdData[1])          
    );   
    
lineBuffer lbB2(                    // here we instantiate line buffer 0 (lB0) using our previously written code
    .i_clk(i_clk),          
    .i_rst(i_rst),          
    .i_data(i_pixel_data),   
    .i_data_valid(lineBufferDataValid[2]),   
    .o_data(lb2data),  
    .i_rd_data(lineBuffRdData[2])          
    );   
    
lineBuffer lbB3(                    // here we instantiate line buffer 0 (lB0) using our previously written code
    .i_clk(i_clk),          
    .i_rst(i_rst),          
    .i_data(i_pixel_data),   
    .i_data_valid(lineBufferDataValid[3]),   
    .o_data(lb3data),  
    .i_rd_data(lineBuffRdData[3])          
    );   
    
endmodule
