open Ast
open Yojson.Basic

type registers = {
  mutable eax : int;
  mutable ebx : int;
  mutable ecx : int;
  mutable edx : int;
  mutable esp : int;
}

type flags = {
  mutable zero : bool;
  mutable sign : bool;
  mutable overflow : bool;
}

type cpu_state = {
  regs : registers;
  flags : flags;
  mutable pc : int;
  memory : int array;
}

let init_cpu_state () =
  let regs = { eax = 0; ebx = 0; ecx = 0; edx = 0; esp = 9499 } in
  let flags = { zero = false; sign = false; overflow = false } in
  let pc = 0 in
  let memory = Array.make 9500 0 in
  { regs; flags; pc; memory }

let get_register cpu reg = 
  match reg with 
  |"%eax" -> cpu.regs.eax
  |"%ebx" -> cpu.regs.ebx
  |"%ecx" -> cpu.regs.ecx
  |"%edx" -> cpu.regs.edx
  |"%esp" -> cpu.regs.esp
  | _ -> failwith "unknown register"

let get_argument cpu arg =
  match arg with
  |Reg1(reg) -> get_register cpu reg
  |Reg2(reg) -> cpu.memory.(get_register cpu reg)
  |Reg3(offset, reg) -> cpu.memory.(offset + get_register cpu reg)
  |Reg4(offset, base, index, scale) -> cpu.memory.(offset + (get_register cpu index) * scale + (get_register cpu base))
  |Imm(s) -> 
    if s = "$_GLOBAL_OFFSET_TABLE_" then 
      0
    else 
      int_of_string (String.sub s 1 (String.length s - 1))
  |_ -> failwith "invalid argument"

let set_register cpu reg value = 
  match reg with 
  |"%eax" -> cpu.regs.eax <- value
  |"%ebx" -> cpu.regs.ebx <- value
  |"%ecx" -> cpu.regs.ecx <- value
  |"%edx" -> cpu.regs.edx <- value
  |"%esp" -> cpu.regs.esp <- value
  | _ -> failwith "unknown register"

let set_argument cpu arg value = 
  match arg with
  |Reg1(reg) -> set_register cpu reg value
  |Reg2(reg) -> cpu.memory.(get_register cpu reg) <- value
  |Reg3(offset, reg) -> cpu.memory.(offset + get_register cpu reg) <- value
  |Reg4(offset, base, index, scale) -> cpu.memory.(offset + (get_register cpu index) * scale + (get_register cpu base)) <- value
  |_ -> failwith "invalid argument"

let update_flags cpu result =
  cpu.flags.zero <- (result = 0);
  cpu.flags.sign <- (result < 0)

let jump cpu target label_references = 
  (match target with
  | Id(label) ->
    cpu.pc <- (Hashtbl.find label_references label)
  | _ -> cpu.pc <- get_argument cpu target)

let argregister reg = 
  match reg with 
  |"%eax" -> 9500
  |"%ebx" -> 9501
  |"%ecx" -> 9502
  |"%edx" -> 9503
  |"%esp" -> 9504
  | _ -> failwith "unknown register"

let argargument cpu arg = 
  match arg with
  |Reg1(reg) -> argregister reg
  |Reg2(reg) -> get_register cpu reg
  |Reg3(offset, reg) -> offset + get_register cpu reg
  |Reg4(offset, base, index, scale) -> offset + (get_register cpu index) * scale + (get_register cpu base)
  |Imm(s) -> 
    if s = "$_GLOBAL_OFFSET_TABLE_" then 
      0
    else 
      int_of_string (String.sub s 1 (String.length s - 1))
  |_ -> failwith "invalid argument"

let execute code label_references main_ret_index = 
  let cpu = init_cpu_state () in 
  let r = ref [] in
  while cpu.pc <> main_ret_index do
    match code.(cpu.pc) with
    |Addl(src, dst) ->
      r := ("addl", argargument cpu src, argargument cpu dst) :: !r;
      let src_val = get_argument cpu src in
      let dst_val = get_argument cpu dst in
      let result = dst_val + src_val in
      set_argument cpu dst result;
      update_flags cpu result;
      cpu.flags.overflow <- ((dst_val >= 0 && src_val >= 0 && result < 0) || (dst_val < 0 && src_val < 0 && result >= 0));
      cpu.pc <- cpu.pc + 1
    
    |Subl(src, dst) ->
      r := ("subl", argargument cpu src, argargument cpu dst) :: !r;
      let src_val = get_argument cpu src in
      let dst_val = get_argument cpu dst in
      let result = dst_val - src_val in
      set_argument cpu dst result;
      update_flags cpu result;
      cpu.flags.overflow <- ((dst_val >= 0 && src_val < 0 && result < 0) || (dst_val < 0 && src_val >= 0 && result >= 0));
      cpu.pc <- cpu.pc + 1

    |Cmpb(src, dst) |Cmpl(src, dst) ->
      r := ("cmpb", argargument cpu src, argargument cpu dst) :: !r;
      let src_val = get_argument cpu src in
      let dst_val = get_argument cpu dst in
      let result = dst_val - src_val in
      update_flags cpu result;
      cpu.flags.overflow <- ((dst_val >= 0 && src_val < 0 && result < 0) || (dst_val < 0 && src_val >= 0 && result >= 0));
      cpu.pc <- cpu.pc + 1

    |Testl(op1, op2) ->
      r := ("testl", argargument cpu op1, argargument cpu op2) :: !r;
      let result = (get_argument cpu op1) land (get_argument cpu op2) in
      update_flags cpu result;
      cpu.flags.overflow <- false;
      cpu.pc <- cpu.pc + 1

    |Andl(src, dst) ->
      r := ("andl", argargument cpu src, argargument cpu dst) :: !r;
      let src_val = get_argument cpu src in
      let dst_val = get_argument cpu dst in
      let result = dst_val land src_val in
      set_argument cpu dst result;
      update_flags cpu result;
      cpu.flags.overflow <- false;
      cpu.pc <- cpu.pc + 1;

    |Xorl(src, dst) ->
      r := ("xorl", argargument cpu src, argargument cpu dst) :: !r;
      let src_val = get_argument cpu src in
      let dst_val = get_argument cpu dst in
      let result = dst_val lxor src_val in
      set_argument cpu dst result;
      update_flags cpu result;
      cpu.flags.overflow <- false;
      cpu.pc <- cpu.pc + 1
      
    |Idivl(op) ->
      let divisor = get_argument cpu op in
      if divisor = 0 then 
        failwith "Division by zero" 
      else
        r := ("idivl", argargument cpu op, 0) :: !r;
        let quotient = cpu.regs.eax / divisor in
        let remainder = cpu.regs.eax mod divisor in
        cpu.regs.eax <- quotient;
        cpu.regs.edx <- remainder;
        cpu.pc <- cpu.pc + 1

    |Cltd ->
      cpu.pc <- cpu.pc + 1

    |Movl(src, dst) |Movb(src, dst) ->
      r := ("movl", argargument cpu src, argargument cpu dst) :: !r;
      let value = get_argument cpu src in
      set_argument cpu dst value;
      cpu.pc <- cpu.pc + 1
  
    |Jmp(target) -> jump cpu target label_references

    |Jl(target) ->
      if cpu.flags.sign <> cpu.flags.overflow then
        jump cpu target label_references
      else cpu.pc <- cpu.pc + 1

    |Jle(target) ->
      if cpu.flags.zero || (cpu.flags.sign <> cpu.flags.overflow) then
        jump cpu target label_references
      else cpu.pc <- cpu.pc + 1

    |Je(target) ->
      if cpu.flags.zero then
        jump cpu target label_references
      else cpu.pc <- cpu.pc + 1

    |Jne(target) ->
      if not cpu.flags.zero then
        jump cpu target label_references
      else cpu.pc <- cpu.pc + 1

    |Call(target) ->
      cpu.regs.esp <- cpu.regs.esp - 1;
      cpu.memory.(cpu.regs.esp) <- cpu.pc + 1;
      jump cpu target label_references

    |Ret ->
      let ret_addr = cpu.memory.(cpu.regs.esp) in
      cpu.regs.esp <- cpu.regs.esp + 1;
      cpu.pc <- ret_addr

    |_ -> failwith "impossible"
  done;
  r := ("stop", 0, 0) :: !r;
  List.rev !r

let rec mlabelsf labels label_references program_counter code main_ret_index =
  match labels with
  |[] -> ()
  |Label(name, statements)::[] ->
    Hashtbl.add label_references (String.sub name 0 (String.length name - 1)) !program_counter;
    program_counter := !program_counter + List.length statements;
    code := Array.of_list statements :: !code;
    main_ret_index := !program_counter - 1
  |Label(name, statements)::t ->
    Hashtbl.add label_references (String.sub name 0 (String.length name - 1)) !program_counter;
    program_counter := !program_counter + List.length statements;
    code := Array.of_list statements :: !code;
    mlabelsf t label_references program_counter code main_ret_index

let rec labelsf labels label_references program_counter code =
  match labels with
  |[] -> ()
  |Label(name, statements)::t ->
    Hashtbl.add label_references (String.sub name 0 (String.length name - 1)) !program_counter;
    program_counter := !program_counter + List.length statements;
    code := Array.of_list statements :: !code;
    labelsf t label_references program_counter code

let rec functionsf functions label_references program_counter code main_ret_index=
  match functions with 
  |[] -> ()
  |Function(name, labels)::t ->
    if name = "main:" then 
      begin
      mlabelsf labels label_references program_counter code main_ret_index;
      functionsf t label_references program_counter code main_ret_index;
      end
    else 
      begin
      functionsf t label_references program_counter code main_ret_index;
      labelsf labels label_references program_counter code;
      end

let programf (Program(functions)) = 
  let code = ref [] in
  let program_counter = ref 0 in 
  let label_references = Hashtbl.create 0 in
  let main_ret_index = ref 0 in 
  functionsf functions label_references program_counter code main_ret_index;
  !code, label_references, !main_ret_index 

let encode_trace trace =
  let mapping = Hashtbl.create 100 in
  let next_code = ref 1 in
  let encoded_trace = List.map (fun instr ->
      if Hashtbl.mem mapping instr then
        Hashtbl.find mapping instr
      else
        let code = !next_code in
        Hashtbl.add mapping instr code;
        next_code := !next_code + 1;
        code
    ) trace in
  let unique_instructions = Array.make !next_code ("", 0, 0) in
  Hashtbl.iter (fun instr code ->
    unique_instructions.(code) <- instr
  ) mapping;
  (encoded_trace, unique_instructions)

let write_json filename json =
  let oc = open_out filename in
  pretty_to_channel oc json;
  close_out oc

let () =
  let filename = "main.s" in
  let channel = open_in filename in
  let lexbuf = Lexing.from_channel channel in
  let ast = Parser.program Lexer.token lexbuf in
  close_in channel;
  let code, label_references, main_ret_index = programf ast in
  let trace = execute (Array.concat (List.rev code)) label_references main_ret_index in
  let (encoded_trace, unique_instructions) = encode_trace trace in
  let json_encoded_trace =
    `List (List.map (fun i -> `Int i) encoded_trace)
  in
  let json_unique_instructions =
    `List (
      Array.to_list unique_instructions |> List.map (fun (name, arg1, arg2) ->
        `List [ `String name; `Int arg1; `Int arg2 ]
      )
    )
  in
  write_json "encoded_trace.json" json_encoded_trace;
  write_json "unique_instructions.json" json_unique_instructions
