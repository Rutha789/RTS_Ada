--Process commnication: Ada lab part 3

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
use Ada.Calendar;
use Ada.Text_IO;

procedure comm1 is
   Message: constant String := "Process communication";
   task buffer is
      entry Add(Num:in Integer);
      entry Remove(Num:out Integer);
      entry Term;
   end buffer;

   task producer is
      entry Term;
   end producer;

   task consumer is
      -- add your task entries for communication 
   end consumer;

   task body buffer is 
      type Buffer_Pos is range 0..9;
      type Buffer_Size is range 0..10;
      Message: constant String := "buffer executing";
      Buffer: array(Buffer_Pos) of Integer;
      Inpos: Buffer_Pos := 0;
      Outpos: Buffer_Pos := 0;
      Amount: Buffer_Size := 0;
   begin
      Put_Line(Message);
      loop
         select
            when Amount < 10 =>
               accept Add(Num:in Integer) do
                  Put_Line("added:" & Integer'Image(Num));
                  Buffer(Inpos) := Num;
                  Inpos := (Inpos + 1) mod 10;
                  Amount := Amount + 1;
               end Add;
         or
            when Amount > 0 =>
               accept Remove(Num:out Integer) do
                  Num := Buffer(Outpos);
                  Outpos := (Outpos + 1) mod 10;
                  Amount := Amount - 1;
               end Remove;
         or
            accept Term;
            Put_Line("terminating buffer");
            exit;
         end select;
      end loop;
   end buffer;

   task body producer is 
      Message: constant String := "producer executing";
      subtype Rand is Integer range 0..20;
      package Rand_Int is new Ada.Numerics.Discrete_Random(Rand);
      use Rand_Int;
      Gen: Generator;
      Next_Num: Integer;
   begin
      Put_Line(Message);
      Reset(Gen);
      Next_Num := Random(Gen);
      loop
         select
            accept Term;
            Put_Line("terminating producer");
            exit;
         else
            buffer.Add(Next_Num);
            Next_Num := Random(Gen);
            delay 0.5; -- 'add number to buffer' frequency
         end select;
      end loop;
   end producer;

   task body consumer is 
      Message: constant String := "consumer executing";
      Sum: Integer := 0;
      Get: Integer := 0;
   begin
      Put_Line(Message);
      loop
         buffer.Remove(Get);
         Sum := Sum + Get;
         Put_Line("removed:" & Integer'Image(Get) & "(" & Integer'Image(Sum) & ")");
         if Sum > 100 then
            exit;
         end if;
         delay 1.0; -- 'remove number from buffer' frequency
      end loop;
      delay 3.0;
      producer.Term;
      buffer.Term;
      Put_Line("terminating consumer");
   exception
      when TASKING_ERROR =>
         Put_Line("Buffer finished before producer");
         Put_Line("Ending the consumer");
   end consumer;
   
begin
   Put_Line(Message);
end comm1;
