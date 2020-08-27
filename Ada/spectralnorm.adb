pragma Source_Reference (000001, "spectralnorm.adb");
-- The Computer Language Benchmarks Game
-- https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
--
-- Contributed by Jim Rogers
-- Modified by Jonathan Parker (Oct 2009)
-- Updated by Jonathan Parker and Georg Bauhaus (May 2012)

with Ada.Text_IO;
with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Command_Line; use Ada.Command_Line;
with Spectral_Utils, Spectral_Utils.Dist;
with Division;

procedure SpectralNorm is

   No_of_Cores_to_Use : constant := 4;

   subtype Real is Division.SSE_Real;
   use type Real;

   package Real_IO is new Ada.Text_IO.Float_IO (Real);
   package Real_Funcs is new Ada.Numerics.Generic_Elementary_Functions (Real);
   use Real_Funcs;

   N : Positive := 100;
   Vbv, Vv : Real := 0.0;
begin
   if Argument_Count = 1 then
      N := Positive'Value (Argument(1));
   else
      raise Program_Error;
   end if;

   declare
      package Spectrum is new Spectral_Utils
        (Matrix_Order => N);
      package Calc is new Spectrum.Dist
        (Number_Of_Tasks => No_of_Cores_to_Use);
      use Spectrum, Calc;
      Calculator : constant Matrix_Computation'Class := Make_Calculator;
      U : Matrix := (others => 1.0);
      V : Matrix := (others => 0.0);
   begin
      for I in 1 .. 10 loop
         Eval_Ata_Times_U (Calculator, U, V);
         Eval_Ata_Times_U (Calculator, V, U);
      end loop;
      for I in V'Range loop
         Vbv := Vbv + U(I) * V(I);
         Vv  := Vv  + V(I) * V(I);
      end loop;
   end;
   Real_IO.Put(Item => Sqrt(Vbv/Vv), Fore => 1, Aft => 9, Exp => 0);
   Ada.Text_Io.New_Line;
end SpectralNorm;
