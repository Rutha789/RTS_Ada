--Process commnication: Ada lab part 4

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
use Ada.Calendar;
use Ada.Text_IO;

procedure comm2 is
   Message: constant String := "Protected Object";
   Buffer_Size : constant Integer := 10;
   type BufferArray is array (0..9) of Integer;

   -- protected object declaration
   protected buffer is
        -- add entries of protected object entries
        entry Add (Num : in Integer);
        entry Remove (Num : out Integer);
        -- add local variable declarations
        private
             Buffer     : BufferArray;
             Inpos: integer := 0;
             Outpos: integer := 0;
             Amount: integer := 0;
           
   end buffer;

     task producer is
    -- add task entries
        entry Term;
    end producer;

    task consumer is
    -- add task entries
    end consumer;

   protected body buffer is 
      -- add definitions of protected object entries here
		entry Add(Num : in Integer) when Amount < Buffer_Size is
		begin
			Buffer (Inpos) := Num;
			Inpos          := (Inpos + 1) mod Buffer_Size;
         Amount     := Amount + 1;
		end Add;

		entry Remove(Num : out Integer) when Amount > 0 is
		begin
			Num     := Buffer (Outpos);
			Outpos   := (Outpos + 1) mod Buffer_Size;
          Amount := Amount - 1;
		end Remove;
   end buffer;

   task body producer is 
      Message: constant String := "Producer executing";
      type Rand is range 0 .. 20;
      package Rand_Int is new Ada.Numerics.Discrete_Random(Rand);
      use Rand_Int;
      Gen : Rand_Int.Generator;
      Next_Num : Integer;

    begin
      Put_Line(Message);
      Reset(Gen);
      -- add your task code inside this loop 
      loop
         select
            accept Term;
            Put_Line("Producer terminating");
            exit;
         else
            Next_Num := Integer (Random (Gen));
            buffer.Add(Next_Num);
               
               Put_Line("Item Added: " & Integer'Image (Next_Num));
               
               delay 0.005; -- 'add number to buffer' frequency
       end select;
    end loop;
   end producer;

   task body consumer is 
      Message: constant String := "consumer executing";
	-- add local declrations of task here
      type Rand is range 0 .. 10;
      package Rand_Int is new Ada.Numerics.Discrete_Random (Rand);
      use Rand_Int;
      Gen      : Rand_Int.Generator;
      Sum: Integer := 0;
      Get: Integer := 0;
   begin
      Put_Line(Message);
      Reset(Gen);
      loop
	-- add your task code inside this loop 
         buffer.Remove(Get);
         
         Sum := Sum + Get;
         Put_Line("Item Removed:" & Integer'Image(Get) & " (Sum:" & Integer'Image(Sum) & " )");
         
         if Sum > 100 then
            exit;
         end if;
         
         delay 0.0005; -- 'remove number from buffer' frequency
      end loop;
      delay 0.1; --Above 2.0 creates deadlock
      producer.Term;
      Put_Line("Consumer terminating");
   end consumer;
   
begin
   Put_Line(Message);
end comm2;
