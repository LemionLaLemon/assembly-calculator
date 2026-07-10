# Calculator
Severely braindead simple calculator in handwritten x86 assembly.

This calculator is probably useless for anything outside decompilation or chucking it in an AI to measure how well it can decompile.
It reads the terminal for user input, takes in two digits and an operator (either + - * or /), and then print the results.
The calculator does not support decimal numbers. Inputs are treated as integers and outputs are 32 bit signed integers.

~~If compiled and stripped, the final executable will be 8600 bytes (8.6kb) and if compiled using `make` the final executable will be 9880 bytes (9.88kb).~~

When compiled using `make`, `ld` has been configured to not separate .data and .text, and to strip all symbols. The final executable is now 5312 bytes (5.3kb).

When ran, 16 kilobytes of memory on the stack is used, and 0 bytes of memory on the heap (it's a calculator, why would you possibly need the heap?)

## Typical operation of the calculator:
<img width="187" height="160" alt="image" src="https://github.com/user-attachments/assets/e5ee8555-86a0-4f0f-90d9-7c62c6709b7d" />

## Building from source
Requirements:

  `nasm` assembler 
  
  `ld` GNU linker
  
A Makefile was already provided so you can just run
```
make
```
`make` will automatically run the calculator as well.

To run the calculator manually, navigate to the bin/ folder and run `./calculator`

Note: if contributing, please run `make clean` to get rid of the temporary `obj/` folder containing compiled binaries.

## Other features (or bugs)
This calculator isnt written fantastically and has a few quirks, eh hem "Features" and here's a list of them.

### "No operator was found"
<img width="296" height="157" alt="image" src="https://github.com/user-attachments/assets/b655de44-fa27-4e45-9521-a6966fc393d8" />
<img width="299" height="155" alt="image" src="https://github.com/user-attachments/assets/becbb9b3-7fb2-449c-832b-3a53ce7b9883" />

If an operator couldn't be found, or an operator isnt part of the 4 supported operations, "No operator was found" would be printed rather than a result, and it would return with exit code 0.

### Nonstandard atoi (Ascii to Integer) negative number handling
<img width="190" height="156" alt="image" src="https://github.com/user-attachments/assets/f37ecbe7-d7b1-4523-91ae-492905c35ec0" />

atoi will switch the sign of the number every time a "-" is encountered in the string.


for example:

`--2` would return `2`

`---4` would return `-4`


This behavior is inconsistent with the C library's implementation of atoi.

### Nonstandard atoi space character handling

atoi will just continue on reading when a space (0x20) is spotted rather than stopping.


for example:

`123 456` would return `123456`

intended: `123`


This behavior is inconsistent with the C library's implementation of atoi.

However, this is more of a feature than a bug, since you can separate long numbers using spaces.
`3 141 592 653` and so on.

### Lacking division by 0 handling
<img width="1025" height="157" alt="image" src="https://github.com/user-attachments/assets/5322a89c-5c0b-4773-8e40-be505b3e4789" />

Attempting to divide by 0 will directly run `div, 0` with no checks. 

This will result in SIGFPE (Floating point exception) and a crash with exit code 136.

### Fixed input and result buffer size
<img width="356" height="83" alt="image" src="https://github.com/user-attachments/assets/19af941c-ad8b-4c03-9311-4ece341f9c17" />

The input buffer is fixed to 64 bytes, so any data entered past that will be truncated.

The result buffer, called "working" for some reason (probably as a result of many versions) is fixed to 12 bytes (one register, or quadword).

Note: image indicates working has 8 bytes reserved, but that has been changed. Image will be updated  later.

### Input desync
If an input over 64 bytes is entered into any field, it'll overflow into the next stdin read.

This results in data from the prevous read being put in the new read, possibly resulting in a wrong calculation.

 ## objdump -d
 ```
0000000000400080 <.text>:
  400080:	8b 04 25 ac 13 40 00 	mov    0x4013ac,%eax
  400087:	8b 1c 25 b0 13 40 00 	mov    0x4013b0,%ebx
  40008e:	48 01 d8             	add    %rbx,%rax
  400091:	e8 43 00 00 00       	call   0x4000d9
  400096:	8b 04 25 ac 13 40 00 	mov    0x4013ac,%eax
  40009d:	8b 1c 25 b0 13 40 00 	mov    0x4013b0,%ebx
  4000a4:	29 d8                	sub    %ebx,%eax
  4000a6:	e8 2e 00 00 00       	call   0x4000d9
  4000ab:	8b 04 25 ac 13 40 00 	mov    0x4013ac,%eax
  4000b2:	8b 1c 25 b0 13 40 00 	mov    0x4013b0,%ebx
  4000b9:	f7 e3                	mul    %ebx
  4000bb:	e8 19 00 00 00       	call   0x4000d9
  4000c0:	48 63 04 25 ac 13 40 	movslq 0x4013ac,%rax
  4000c7:	00 
  4000c8:	48 99                	cqto
  4000ca:	48 63 1c 25 b0 13 40 	movslq 0x4013b0,%rbx
  4000d1:	00 
  4000d2:	f7 fb                	idiv   %ebx
  4000d4:	e8 00 00 00 00       	call   0x4000d9
  4000d9:	48 bf a0 13 40 00 00 	movabs $0x4013a0,%rdi
  4000e0:	00 00 00 
  4000e3:	e8 98 01 00 00       	call   0x400280
  4000e8:	49 89 c4             	mov    %rax,%r12
  4000eb:	b8 01 00 00 00       	mov    $0x1,%eax
  4000f0:	bf 01 00 00 00       	mov    $0x1,%edi
  4000f5:	48 be 40 13 40 00 00 	movabs $0x401340,%rsi
  4000fc:	00 00 00 
  4000ff:	ba 08 00 00 00       	mov    $0x8,%edx
  400104:	0f 05                	syscall
  400106:	b8 01 00 00 00       	mov    $0x1,%eax
  40010b:	bf 01 00 00 00       	mov    $0x1,%edi
  400110:	48 be a0 13 40 00 00 	movabs $0x4013a0,%rsi
  400117:	00 00 00 
  40011a:	4c 89 e2             	mov    %r12,%rdx
  40011d:	0f 05                	syscall
  40011f:	b8 01 00 00 00       	mov    $0x1,%eax
  400124:	bf 01 00 00 00       	mov    $0x1,%edi
  400129:	48 be 5e 13 40 00 00 	movabs $0x40135e,%rsi
  400130:	00 00 00 
  400133:	ba 01 00 00 00       	mov    $0x1,%edx
  400138:	0f 05                	syscall
  40013a:	e9 28 01 00 00       	jmp    0x400267
  40013f:	b8 01 00 00 00       	mov    $0x1,%eax
  400144:	bf 01 00 00 00       	mov    $0x1,%edi
  400149:	48 be 24 13 40 00 00 	movabs $0x401324,%rsi
  400150:	00 00 00 
  400153:	ba 09 00 00 00       	mov    $0x9,%edx
  400158:	0f 05                	syscall
  40015a:	b8 00 00 00 00       	mov    $0x0,%eax
  40015f:	bf 00 00 00 00       	mov    $0x0,%edi
  400164:	48 be 60 13 40 00 00 	movabs $0x401360,%rsi
  40016b:	00 00 00 
  40016e:	ba 40 00 00 00       	mov    $0x40,%edx
  400173:	0f 05                	syscall
  400175:	48 b8 60 13 40 00 00 	movabs $0x401360,%rax
  40017c:	00 00 00 
  40017f:	e8 37 01 00 00       	call   0x4002bb
  400184:	89 04 25 ac 13 40 00 	mov    %eax,0x4013ac
  40018b:	b8 01 00 00 00       	mov    $0x1,%eax
  400190:	bf 01 00 00 00       	mov    $0x1,%edi
  400195:	48 be 2d 13 40 00 00 	movabs $0x40132d,%rsi
  40019c:	00 00 00 
  40019f:	ba 0a 00 00 00       	mov    $0xa,%edx
  4001a4:	0f 05                	syscall
  4001a6:	b8 00 00 00 00       	mov    $0x0,%eax
  4001ab:	bf 00 00 00 00       	mov    $0x0,%edi
  4001b0:	48 be 60 13 40 00 00 	movabs $0x401360,%rsi
  4001b7:	00 00 00 
  4001ba:	ba 40 00 00 00       	mov    $0x40,%edx
  4001bf:	0f 05                	syscall
  4001c1:	8a 04 25 60 13 40 00 	mov    0x401360,%al
  4001c8:	88 04 25 b4 13 40 00 	mov    %al,0x4013b4
  4001cf:	b8 01 00 00 00       	mov    $0x1,%eax
  4001d4:	bf 01 00 00 00       	mov    $0x1,%edi
  4001d9:	48 be 37 13 40 00 00 	movabs $0x401337,%rsi
  4001e0:	00 00 00 
  4001e3:	ba 09 00 00 00       	mov    $0x9,%edx
  4001e8:	0f 05                	syscall
  4001ea:	b8 00 00 00 00       	mov    $0x0,%eax
  4001ef:	bf 00 00 00 00       	mov    $0x0,%edi
  4001f4:	48 be 60 13 40 00 00 	movabs $0x401360,%rsi
  4001fb:	00 00 00 
  4001fe:	ba 40 00 00 00       	mov    $0x40,%edx
  400203:	0f 05                	syscall
  400205:	48 b8 60 13 40 00 00 	movabs $0x401360,%rax
  40020c:	00 00 00 
  40020f:	e8 a7 00 00 00       	call   0x4002bb
  400214:	89 04 25 b0 13 40 00 	mov    %eax,0x4013b0
  40021b:	48 0f b6 04 25 b4 13 	movzbq 0x4013b4,%rax
  400222:	40 00 
  400224:	48 83 f8 2b          	cmp    $0x2b,%rax
  400228:	0f 84 52 fe ff ff    	je     0x400080
  40022e:	48 83 f8 2d          	cmp    $0x2d,%rax
  400232:	0f 84 5e fe ff ff    	je     0x400096
  400238:	48 83 f8 2a          	cmp    $0x2a,%rax
  40023c:	0f 84 69 fe ff ff    	je     0x4000ab
  400242:	48 83 f8 2f          	cmp    $0x2f,%rax
  400246:	0f 84 74 fe ff ff    	je     0x4000c0
  40024c:	b8 01 00 00 00       	mov    $0x1,%eax
  400251:	bf 01 00 00 00       	mov    $0x1,%edi
  400256:	48 be 48 13 40 00 00 	movabs $0x401348,%rsi
  40025d:	00 00 00 
  400260:	ba 16 00 00 00       	mov    $0x16,%edx
  400265:	0f 05                	syscall
  400267:	b8 3c 00 00 00       	mov    $0x3c,%eax
  40026c:	48 31 ff             	xor    %rdi,%rdi
  40026f:	0f 05                	syscall
  400271:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  400278:	00 00 00 
  40027b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  400280:	49 89 f8             	mov    %rdi,%r8
  400283:	85 c0                	test   %eax,%eax
  400285:	79 09                	jns    0x400290
  400287:	f7 d8                	neg    %eax
  400289:	41 c6 00 2d          	movb   $0x2d,(%r8)
  40028d:	49 ff c0             	inc    %r8
  400290:	bb 0a 00 00 00       	mov    $0xa,%ebx
  400295:	48 31 c9             	xor    %rcx,%rcx
  400298:	31 d2                	xor    %edx,%edx
  40029a:	f7 f3                	div    %ebx
  40029c:	80 c2 30             	add    $0x30,%dl
  40029f:	52                   	push   %rdx
  4002a0:	48 ff c1             	inc    %rcx
  4002a3:	85 c0                	test   %eax,%eax
  4002a5:	75 f1                	jne    0x400298
  4002a7:	58                   	pop    %rax
  4002a8:	41 88 00             	mov    %al,(%r8)
  4002ab:	49 ff c0             	inc    %r8
  4002ae:	e2 f7                	loop   0x4002a7
  4002b0:	41 c6 00 00          	movb   $0x0,(%r8)
  4002b4:	4c 89 c0             	mov    %r8,%rax
  4002b7:	48 29 f8             	sub    %rdi,%rax
  4002ba:	c3                   	ret
  4002bb:	53                   	push   %rbx
  4002bc:	41 50                	push   %r8
  4002be:	41 51                	push   %r9
  4002c0:	48 31 c9             	xor    %rcx,%rcx
  4002c3:	ba 01 00 00 00       	mov    $0x1,%edx
  4002c8:	4d 31 c0             	xor    %r8,%r8
  4002cb:	4d 31 c9             	xor    %r9,%r9
  4002ce:	8a 1c 08             	mov    (%rax,%rcx,1),%bl
  4002d1:	80 fb 00             	cmp    $0x0,%bl
  4002d4:	74 3f                	je     0x400315
  4002d6:	80 fb 2d             	cmp    $0x2d,%bl
  4002d9:	74 2d                	je     0x400308
  4002db:	80 fb 2b             	cmp    $0x2b,%bl
  4002de:	74 23                	je     0x400303
  4002e0:	80 fb 20             	cmp    $0x20,%bl
  4002e3:	74 1e                	je     0x400303
  4002e5:	80 fb 30             	cmp    $0x30,%bl
  4002e8:	7c 2b                	jl     0x400315
  4002ea:	80 fb 39             	cmp    $0x39,%bl
  4002ed:	7f 26                	jg     0x400315
  4002ef:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  4002f5:	80 eb 30             	sub    $0x30,%bl
  4002f8:	48 0f b6 db          	movzbq %bl,%rbx
  4002fc:	4d 6b c0 0a          	imul   $0xa,%r8,%r8
  400300:	49 01 d8             	add    %rbx,%r8
  400303:	48 ff c1             	inc    %rcx
  400306:	eb c6                	jmp    0x4002ce
  400308:	49 83 f9 01          	cmp    $0x1,%r9
  40030c:	74 07                	je     0x400315
  40030e:	f7 da                	neg    %edx
  400310:	48 ff c1             	inc    %rcx
  400313:	eb b9                	jmp    0x4002ce
  400315:	4c 0f af c2          	imul   %rdx,%r8
  400319:	44 89 c0             	mov    %r8d,%eax
  40031c:	5b                   	pop    %rbx
  40031d:	41 58                	pop    %r8
  40031f:	41 59                	pop    %r9
  400321:	c3                   	ret
```

## objdump -s
```
Contents of section .text:
  400080 8b0425ac 1340008b 1c25b013 40004801  ..%..@...%..@.H.
  400090 d8e84300 00008b04 25ac1340 008b1c25  ..C.....%..@...%
  4000a0 b0134000 29d8e82e 0000008b 0425ac13  ..@.)........%..
  4000b0 40008b1c 25b01340 00f7e3e8 19000000  @...%..@........
  4000c0 48630425 ac134000 48994863 1c25b013  Hc.%..@.H.Hc.%..
  4000d0 4000f7fb e8000000 0048bfa0 13400000  @........H...@..
  4000e0 000000e8 98010000 4989c4b8 01000000  ........I.......
  4000f0 bf010000 0048be40 13400000 000000ba  .....H.@.@......
  400100 08000000 0f05b801 000000bf 01000000  ................
  400110 48bea013 40000000 00004c89 e20f05b8  H...@.....L.....
  400120 01000000 bf010000 0048be5e 13400000  .........H.^.@..
  400130 000000ba 01000000 0f05e928 010000b8  ...........(....
  400140 01000000 bf010000 0048be24 13400000  .........H.$.@..
  400150 000000ba 09000000 0f05b800 000000bf  ................
  400160 00000000 48be6013 40000000 0000ba40  ....H.`.@......@
  400170 0000000f 0548b860 13400000 000000e8  .....H.`.@......
  400180 37010000 890425ac 134000b8 01000000  7.....%..@......
  400190 bf010000 0048be2d 13400000 000000ba  .....H.-.@......
  4001a0 0a000000 0f05b800 000000bf 00000000  ................
  4001b0 48be6013 40000000 0000ba40 0000000f  H.`.@......@....
  4001c0 058a0425 60134000 880425b4 134000b8  ...%`.@...%..@..
  4001d0 01000000 bf010000 0048be37 13400000  .........H.7.@..
  4001e0 000000ba 09000000 0f05b800 000000bf  ................
  4001f0 00000000 48be6013 40000000 0000ba40  ....H.`.@......@
  400200 0000000f 0548b860 13400000 000000e8  .....H.`.@......
  400210 a7000000 890425b0 13400048 0fb60425  ......%..@.H...%
  400220 b4134000 4883f82b 0f8452fe ffff4883  ..@.H..+..R...H.
  400230 f82d0f84 5efeffff 4883f82a 0f8469fe  .-..^...H..*..i.
  400240 ffff4883 f82f0f84 74feffff b8010000  ..H../..t.......
  400250 00bf0100 000048be 48134000 00000000  ......H.H.@.....
  400260 ba160000 000f05b8 3c000000 4831ff0f  ........<...H1..
  400270 05662e0f 1f840000 0000000f 1f440000  .f...........D..
  400280 4989f885 c07909f7 d841c600 2d49ffc0  I....y...A..-I..
  400290 bb0a0000 004831c9 31d2f7f3 80c23052  .....H1.1.....0R
  4002a0 48ffc185 c075f158 41880049 ffc0e2f7  H....u.XA..I....
  4002b0 41c60000 4c89c048 29f8c353 41504151  A...L..H)..SAPAQ
  4002c0 4831c9ba 01000000 4d31c04d 31c98a1c  H1......M1.M1...
  4002d0 0880fb00 743f80fb 2d742d80 fb2b7423  ....t?..-t-..+t#
  4002e0 80fb2074 1e80fb30 7c2b80fb 397f2641  .. t...0|+..9.&A
  4002f0 b9010000 0080eb30 480fb6db 4d6bc00a  .......0H...Mk..
  400300 4901d848 ffc1ebc6 4983f901 7407f7da  I..H....I...t...
  400310 48ffc1eb b94c0faf c24489c0 5b415841  H....L...D..[AXA
  400320 59c3                                 Y.              
  Contents of section .data:
  401324 44696769 7420313e 204f7065 7261746f  Digit 1> Operato
  401334 723e2044 69676974 20323e20 52657375  r> Digit 2> Resu
  401344 6c743e20 4e6f206f 70657261 746f7220  lt> No operator 
  401354 77617320 666f756e 640a0a             was found..     
```
