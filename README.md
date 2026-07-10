# Calculator
Severely braindead simple calculator in handwritten x86 assembly.

This calculator is probably useless for anything outside decompilation or chucking it in an AI to measure how well it can decompile.
It reads the terminal for user input, takes in two digits and an operator (either + - * or /), and then print the results.
The calculator does not support decimal numbers. Inputs are treated as integers and outputs are 32 bit signed integers.

If compiled and stripped, the final executable will be 8600 bytes (8.6kb) and if compiled using `make` the final executable will be 9880 bytes (9.88kb).
When ran, it'll use 16 kilobytes of memory on the stack, and 0 bytes of memory on the heap (it's a calculator, why would you possibly need the heap)

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

To run the calculator manually, navigate to the bin/ folder and run ./calculator

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

`---4` woudl return `-4`

This behavior is inconsistent with the C library's implementation of atoi.

### Lacking division by 0 handling
<img width="1025" height="157" alt="image" src="https://github.com/user-attachments/assets/5322a89c-5c0b-4773-8e40-be505b3e4789" />

Attempting to divide by 0 will directly run `div, 0` with no checks. 

This will result in SIGFPE (Floating point exception) and a crash with exit code 136.

### Fixed input and result buffer size
<img width="356" height="83" alt="image" src="https://github.com/user-attachments/assets/19af941c-ad8b-4c03-9311-4ece341f9c17" />

The input buffer is fixed to 64 bytes, so any data entered past that will be truncated.

The result buffer, called "working" for some reason (probably as a result of many versions) is fixed to 8 bytes (one register, or quadword).

 ## objdump -d
 ```
 0000000000401000 <addition>:
  401000:	8b 04 25 84 20 40 00 	mov    0x402084,%eax
  401007:	8b 1c 25 88 20 40 00 	mov    0x402088,%ebx
  40100e:	48 01 d8             	add    %rbx,%rax
  401011:	e8 41 00 00 00       	call   401057 <finish>

0000000000401016 <subtraction>:
  401016:	8b 04 25 84 20 40 00 	mov    0x402084,%eax
  40101d:	8b 1c 25 88 20 40 00 	mov    0x402088,%ebx
  401024:	29 d8                	sub    %ebx,%eax
  401026:	e8 2c 00 00 00       	call   401057 <finish>

000000000040102b <multiplication>:
  40102b:	8b 04 25 84 20 40 00 	mov    0x402084,%eax
  401032:	8b 1c 25 88 20 40 00 	mov    0x402088,%ebx
  401039:	f7 e3                	mul    %ebx
  40103b:	e8 17 00 00 00       	call   401057 <finish>

0000000000401040 <division>:
  401040:	8b 04 25 84 20 40 00 	mov    0x402084,%eax
  401047:	8b 1c 25 88 20 40 00 	mov    0x402088,%ebx
  40104e:	31 d2                	xor    %edx,%edx
  401050:	f7 f3                	div    %ebx
  401052:	e8 00 00 00 00       	call   401057 <finish>

0000000000401057 <finish>:
  401057:	48 bf 7c 20 40 00 00 	movabs $0x40207c,%rdi
  40105e:	00 00 00 
  401061:	e8 8a 01 00 00       	call   4011f0 <itoa>
  401066:	49 89 c4             	mov    %rax,%r12
  401069:	b8 01 00 00 00       	mov    $0x1,%eax
  40106e:	bf 01 00 00 00       	mov    $0x1,%edi
  401073:	48 be 1c 20 40 00 00 	movabs $0x40201c,%rsi
  40107a:	00 00 00 
  40107d:	ba 08 00 00 00       	mov    $0x8,%edx
  401082:	0f 05                	syscall
  401084:	b8 01 00 00 00       	mov    $0x1,%eax
  401089:	bf 01 00 00 00       	mov    $0x1,%edi
  40108e:	48 be 7c 20 40 00 00 	movabs $0x40207c,%rsi
  401095:	00 00 00 
  401098:	4c 89 e2             	mov    %r12,%rdx
  40109b:	0f 05                	syscall
  40109d:	b8 01 00 00 00       	mov    $0x1,%eax
  4010a2:	bf 01 00 00 00       	mov    $0x1,%edi
  4010a7:	48 be 3a 20 40 00 00 	movabs $0x40203a,%rsi
  4010ae:	00 00 00 
  4010b1:	ba 01 00 00 00       	mov    $0x1,%edx
  4010b6:	0f 05                	syscall
  4010b8:	e9 28 01 00 00       	jmp    4011e5 <exit>

00000000004010bd <_start>:
  4010bd:	b8 01 00 00 00       	mov    $0x1,%eax
  4010c2:	bf 01 00 00 00       	mov    $0x1,%edi
  4010c7:	48 be 00 20 40 00 00 	movabs $0x402000,%rsi
  4010ce:	00 00 00 
  4010d1:	ba 09 00 00 00       	mov    $0x9,%edx
  4010d6:	0f 05                	syscall
  4010d8:	b8 00 00 00 00       	mov    $0x0,%eax
  4010dd:	bf 00 00 00 00       	mov    $0x0,%edi
  4010e2:	48 be 3c 20 40 00 00 	movabs $0x40203c,%rsi
  4010e9:	00 00 00 
  4010ec:	ba 40 00 00 00       	mov    $0x40,%edx
  4010f1:	0f 05                	syscall
  4010f3:	48 b8 3c 20 40 00 00 	movabs $0x40203c,%rax
  4010fa:	00 00 00 
  4010fd:	e8 29 01 00 00       	call   40122b <atoi>
  401102:	89 04 25 84 20 40 00 	mov    %eax,0x402084
  401109:	b8 01 00 00 00       	mov    $0x1,%eax
  40110e:	bf 01 00 00 00       	mov    $0x1,%edi
  401113:	48 be 09 20 40 00 00 	movabs $0x402009,%rsi
  40111a:	00 00 00 
  40111d:	ba 0a 00 00 00       	mov    $0xa,%edx
  401122:	0f 05                	syscall
  401124:	b8 00 00 00 00       	mov    $0x0,%eax
  401129:	bf 00 00 00 00       	mov    $0x0,%edi
  40112e:	48 be 3c 20 40 00 00 	movabs $0x40203c,%rsi
  401135:	00 00 00 
  401138:	ba 40 00 00 00       	mov    $0x40,%edx
  40113d:	0f 05                	syscall
  40113f:	8a 04 25 3c 20 40 00 	mov    0x40203c,%al
  401146:	88 04 25 8c 20 40 00 	mov    %al,0x40208c
  40114d:	b8 01 00 00 00       	mov    $0x1,%eax
  401152:	bf 01 00 00 00       	mov    $0x1,%edi
  401157:	48 be 13 20 40 00 00 	movabs $0x402013,%rsi
  40115e:	00 00 00 
  401161:	ba 09 00 00 00       	mov    $0x9,%edx
  401166:	0f 05                	syscall
  401168:	b8 00 00 00 00       	mov    $0x0,%eax
  40116d:	bf 00 00 00 00       	mov    $0x0,%edi
  401172:	48 be 3c 20 40 00 00 	movabs $0x40203c,%rsi
  401179:	00 00 00 
  40117c:	ba 40 00 00 00       	mov    $0x40,%edx
  401181:	0f 05                	syscall
  401183:	48 b8 3c 20 40 00 00 	movabs $0x40203c,%rax
  40118a:	00 00 00 
  40118d:	e8 99 00 00 00       	call   40122b <atoi>
  401192:	89 04 25 88 20 40 00 	mov    %eax,0x402088
  401199:	48 0f b6 04 25 8c 20 	movzbq 0x40208c,%rax
  4011a0:	40 00 
  4011a2:	48 83 f8 2b          	cmp    $0x2b,%rax
  4011a6:	0f 84 54 fe ff ff    	je     401000 <addition>
  4011ac:	48 83 f8 2d          	cmp    $0x2d,%rax
  4011b0:	0f 84 60 fe ff ff    	je     401016 <subtraction>
  4011b6:	48 83 f8 2a          	cmp    $0x2a,%rax
  4011ba:	0f 84 6b fe ff ff    	je     40102b <multiplication>
  4011c0:	48 83 f8 2f          	cmp    $0x2f,%rax
  4011c4:	0f 84 76 fe ff ff    	je     401040 <division>
  4011ca:	b8 01 00 00 00       	mov    $0x1,%eax
  4011cf:	bf 01 00 00 00       	mov    $0x1,%edi
  4011d4:	48 be 24 20 40 00 00 	movabs $0x402024,%rsi
  4011db:	00 00 00 
  4011de:	ba 16 00 00 00       	mov    $0x16,%edx
  4011e3:	0f 05                	syscall

00000000004011e5 <exit>:
  4011e5:	b8 3c 00 00 00       	mov    $0x3c,%eax
  4011ea:	48 31 ff             	xor    %rdi,%rdi
  4011ed:	0f 05                	syscall
  4011ef:	90                   	nop

00000000004011f0 <itoa>:
  4011f0:	49 89 f8             	mov    %rdi,%r8
  4011f3:	85 c0                	test   %eax,%eax
  4011f5:	79 09                	jns    401200 <itoa.convert>
  4011f7:	f7 d8                	neg    %eax
  4011f9:	41 c6 00 2d          	movb   $0x2d,(%r8)
  4011fd:	49 ff c0             	inc    %r8

0000000000401200 <itoa.convert>:
  401200:	bb 0a 00 00 00       	mov    $0xa,%ebx
  401205:	48 31 c9             	xor    %rcx,%rcx

0000000000401208 <itoa.loop_div>:
  401208:	31 d2                	xor    %edx,%edx
  40120a:	f7 f3                	div    %ebx
  40120c:	80 c2 30             	add    $0x30,%dl
  40120f:	52                   	push   %rdx
  401210:	48 ff c1             	inc    %rcx
  401213:	85 c0                	test   %eax,%eax
  401215:	75 f1                	jne    401208 <itoa.loop_div>

0000000000401217 <itoa.pop_digits>:
  401217:	58                   	pop    %rax
  401218:	41 88 00             	mov    %al,(%r8)
  40121b:	49 ff c0             	inc    %r8
  40121e:	e2 f7                	loop   401217 <itoa.pop_digits>
  401220:	41 c6 00 00          	movb   $0x0,(%r8)
  401224:	4c 89 c0             	mov    %r8,%rax
  401227:	48 29 f8             	sub    %rdi,%rax
  40122a:	c3                   	ret

000000000040122b <atoi>:
  40122b:	53                   	push   %rbx
  40122c:	41 50                	push   %r8
  40122e:	41 51                	push   %r9
  401230:	48 31 c9             	xor    %rcx,%rcx
  401233:	ba 01 00 00 00       	mov    $0x1,%edx
  401238:	4d 31 c0             	xor    %r8,%r8
  40123b:	4d 31 c9             	xor    %r9,%r9

000000000040123e <atoi.forEachNumber>:
  40123e:	8a 1c 08             	mov    (%rax,%rcx,1),%bl
  401241:	80 fb 00             	cmp    $0x0,%bl
  401244:	74 3a                	je     401280 <atoi.done>
  401246:	80 fb 2d             	cmp    $0x2d,%bl
  401249:	74 28                	je     401273 <atoi.negative>
  40124b:	80 fb 20             	cmp    $0x20,%bl
  40124e:	74 1e                	je     40126e <atoi.skip>
  401250:	80 fb 30             	cmp    $0x30,%bl
  401253:	7c 2b                	jl     401280 <atoi.done>
  401255:	80 fb 39             	cmp    $0x39,%bl
  401258:	7f 26                	jg     401280 <atoi.done>
  40125a:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  401260:	80 eb 30             	sub    $0x30,%bl
  401263:	48 0f b6 db          	movzbq %bl,%rbx
  401267:	4d 6b c0 0a          	imul   $0xa,%r8,%r8
  40126b:	49 01 d8             	add    %rbx,%r8

000000000040126e <atoi.skip>:
  40126e:	48 ff c1             	inc    %rcx
  401271:	eb cb                	jmp    40123e <atoi.forEachNumber>

0000000000401273 <atoi.negative>:
  401273:	49 83 f9 01          	cmp    $0x1,%r9
  401277:	74 07                	je     401280 <atoi.done>
  401279:	f7 da                	neg    %edx
  40127b:	48 ff c1             	inc    %rcx
  40127e:	eb be                	jmp    40123e <atoi.forEachNumber>

0000000000401280 <atoi.done>:
  401280:	4c 0f af c2          	imul   %rdx,%r8
  401284:	44 89 c0             	mov    %r8d,%eax
  401287:	5b                   	pop    %rbx
  401288:	41 58                	pop    %r8
  40128a:	41 59                	pop    %r9
  40128c:	c3                   	ret
```

## objdump -s
```
Contents of section .text:
 401000 8b042584 2040008b 1c258820 40004801  ..%. @...%. @.H.
 401010 d8e84100 00008b04 25842040 008b1c25  ..A.....%. @...%
 401020 88204000 29d8e82c 0000008b 04258420  . @.)..,.....%. 
 401030 40008b1c 25882040 00f7e3e8 17000000  @...%. @........
 401040 8b042584 2040008b 1c258820 400031d2  ..%. @...%. @.1.
 401050 f7f3e800 00000048 bf7c2040 00000000  .......H.| @....
 401060 00e88a01 00004989 c4b80100 0000bf01  ......I.........
 401070 00000048 be1c2040 00000000 00ba0800  ...H.. @........
 401080 00000f05 b8010000 00bf0100 000048be  ..............H.
 401090 7c204000 00000000 4c89e20f 05b80100  | @.....L.......
 4010a0 0000bf01 00000048 be3a2040 00000000  .......H.: @....
 4010b0 00ba0100 00000f05 e9280100 00b80100  .........(......
 4010c0 0000bf01 00000048 be002040 00000000  .......H.. @....
 4010d0 00ba0900 00000f05 b8000000 00bf0000  ................
 4010e0 000048be 3c204000 00000000 ba400000  ..H.< @......@..
 4010f0 000f0548 b83c2040 00000000 00e82901  ...H.< @......).
 401100 00008904 25842040 00b80100 0000bf01  ....%. @........
 401110 00000048 be092040 00000000 00ba0a00  ...H.. @........
 401120 00000f05 b8000000 00bf0000 000048be  ..............H.
 401130 3c204000 00000000 ba400000 000f058a  < @......@......
 401140 04253c20 40008804 258c2040 00b80100  .%< @...%. @....
 401150 0000bf01 00000048 be132040 00000000  .......H.. @....
 401160 00ba0900 00000f05 b8000000 00bf0000  ................
 401170 000048be 3c204000 00000000 ba400000  ..H.< @......@..
 401180 000f0548 b83c2040 00000000 00e89900  ...H.< @........
 401190 00008904 25882040 00480fb6 04258c20  ....%. @.H...%. 
 4011a0 40004883 f82b0f84 54feffff 4883f82d  @.H..+..T...H..-
 4011b0 0f8460fe ffff4883 f82a0f84 6bfeffff  ..`...H..*..k...
 4011c0 4883f82f 0f8476fe ffffb801 000000bf  H../..v.........
 4011d0 01000000 48be2420 40000000 0000ba16  ....H.$ @.......
 4011e0 0000000f 05b83c00 00004831 ff0f0590  ......<...H1....
 4011f0 4989f885 c07909f7 d841c600 2d49ffc0  I....y...A..-I..
 401200 bb0a0000 004831c9 31d2f7f3 80c23052  .....H1.1.....0R
 401210 48ffc185 c075f158 41880049 ffc0e2f7  H....u.XA..I....
 401220 41c60000 4c89c048 29f8c353 41504151  A...L..H)..SAPAQ
 401230 4831c9ba 01000000 4d31c04d 31c98a1c  H1......M1.M1...
 401240 0880fb00 743a80fb 2d742880 fb20741e  ....t:..-t(.. t.
 401250 80fb307c 2b80fb39 7f2641b9 01000000  ..0|+..9.&A.....
 401260 80eb3048 0fb6db4d 6bc00a49 01d848ff  ..0H...Mk..I..H.
 401270 c1ebcb49 83f90174 07f7da48 ffc1ebbe  ...I...t...H....
 401280 4c0fafc2 4489c05b 41584159 c3        L...D..[AXAY.   
Contents of section .data:
 402000 44696769 7420313e 204f7065 7261746f  Digit 1> Operato
 402010 723e2044 69676974 20323e20 52657375  r> Digit 2> Resu
 402020 6c743e20 4e6f206f 70657261 746f7220  lt> No operator 
 402030 77617320 666f756e 640a0a             was found..
```
