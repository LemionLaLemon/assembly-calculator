# Calculator
Severely braindead simple calculator in handwritten x86 assembly.

This calculator is probably useless for anything outside decompilation or chucking it in an AI to measure how well it can decompile.
It reads the terminal for user input, takes in two digits and an operator (either + - * or /), and then print the results.
The calculator does not support decimal numbers. Inputs are treated as integers and outputs are 32 bit signed integers.

If compiled and stripped, the final executable will be 8600 bytes (8.6kb) and if compiled using `make` the final executable will be 9880 bytes (9.88kb).
When ran, it'll use 16 kilobytes of memory on the stack, and 0 bytes of memory on the heap (it's a calculator, why would you possibly need the heap?)

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
0000000000401000 <.text>:
  401000:	8b 04 25 88 20 40 00 	mov    0x402088,%eax
  401007:	8b 1c 25 8c 20 40 00 	mov    0x40208c,%ebx
  40100e:	48 01 d8             	add    %rbx,%rax
  401011:	e8 43 00 00 00       	call   0x401059
  401016:	8b 04 25 88 20 40 00 	mov    0x402088,%eax
  40101d:	8b 1c 25 8c 20 40 00 	mov    0x40208c,%ebx
  401024:	29 d8                	sub    %ebx,%eax
  401026:	e8 2e 00 00 00       	call   0x401059
  40102b:	8b 04 25 88 20 40 00 	mov    0x402088,%eax
  401032:	8b 1c 25 8c 20 40 00 	mov    0x40208c,%ebx
  401039:	f7 e3                	mul    %ebx
  40103b:	e8 19 00 00 00       	call   0x401059
  401040:	48 63 04 25 88 20 40 	movslq 0x402088,%rax
  401047:	00 
  401048:	48 99                	cqto
  40104a:	48 63 1c 25 8c 20 40 	movslq 0x40208c,%rbx
  401051:	00 
  401052:	f7 fb                	idiv   %ebx
  401054:	e8 00 00 00 00       	call   0x401059
  401059:	48 bf 7c 20 40 00 00 	movabs $0x40207c,%rdi
  401060:	00 00 00 
  401063:	e8 98 01 00 00       	call   0x401200
  401068:	49 89 c4             	mov    %rax,%r12
  40106b:	b8 01 00 00 00       	mov    $0x1,%eax
  401070:	bf 01 00 00 00       	mov    $0x1,%edi
  401075:	48 be 1c 20 40 00 00 	movabs $0x40201c,%rsi
  40107c:	00 00 00 
  40107f:	ba 08 00 00 00       	mov    $0x8,%edx
  401084:	0f 05                	syscall
  401086:	b8 01 00 00 00       	mov    $0x1,%eax
  40108b:	bf 01 00 00 00       	mov    $0x1,%edi
  401090:	48 be 7c 20 40 00 00 	movabs $0x40207c,%rsi
  401097:	00 00 00 
  40109a:	4c 89 e2             	mov    %r12,%rdx
  40109d:	0f 05                	syscall
  40109f:	b8 01 00 00 00       	mov    $0x1,%eax
  4010a4:	bf 01 00 00 00       	mov    $0x1,%edi
  4010a9:	48 be 3a 20 40 00 00 	movabs $0x40203a,%rsi
  4010b0:	00 00 00 
  4010b3:	ba 01 00 00 00       	mov    $0x1,%edx
  4010b8:	0f 05                	syscall
  4010ba:	e9 28 01 00 00       	jmp    0x4011e7
  4010bf:	b8 01 00 00 00       	mov    $0x1,%eax
  4010c4:	bf 01 00 00 00       	mov    $0x1,%edi
  4010c9:	48 be 00 20 40 00 00 	movabs $0x402000,%rsi
  4010d0:	00 00 00 
  4010d3:	ba 09 00 00 00       	mov    $0x9,%edx
  4010d8:	0f 05                	syscall
  4010da:	b8 00 00 00 00       	mov    $0x0,%eax
  4010df:	bf 00 00 00 00       	mov    $0x0,%edi
  4010e4:	48 be 3c 20 40 00 00 	movabs $0x40203c,%rsi
  4010eb:	00 00 00 
  4010ee:	ba 40 00 00 00       	mov    $0x40,%edx
  4010f3:	0f 05                	syscall
  4010f5:	48 b8 3c 20 40 00 00 	movabs $0x40203c,%rax
  4010fc:	00 00 00 
  4010ff:	e8 37 01 00 00       	call   0x40123b
  401104:	89 04 25 88 20 40 00 	mov    %eax,0x402088
  40110b:	b8 01 00 00 00       	mov    $0x1,%eax
  401110:	bf 01 00 00 00       	mov    $0x1,%edi
  401115:	48 be 09 20 40 00 00 	movabs $0x402009,%rsi
  40111c:	00 00 00 
  40111f:	ba 0a 00 00 00       	mov    $0xa,%edx
  401124:	0f 05                	syscall
  401126:	b8 00 00 00 00       	mov    $0x0,%eax
  40112b:	bf 00 00 00 00       	mov    $0x0,%edi
  401130:	48 be 3c 20 40 00 00 	movabs $0x40203c,%rsi
  401137:	00 00 00 
  40113a:	ba 40 00 00 00       	mov    $0x40,%edx
  40113f:	0f 05                	syscall
  401141:	8a 04 25 3c 20 40 00 	mov    0x40203c,%al
  401148:	88 04 25 90 20 40 00 	mov    %al,0x402090
  40114f:	b8 01 00 00 00       	mov    $0x1,%eax
  401154:	bf 01 00 00 00       	mov    $0x1,%edi
  401159:	48 be 13 20 40 00 00 	movabs $0x402013,%rsi
  401160:	00 00 00 
  401163:	ba 09 00 00 00       	mov    $0x9,%edx
  401168:	0f 05                	syscall
  40116a:	b8 00 00 00 00       	mov    $0x0,%eax
  40116f:	bf 00 00 00 00       	mov    $0x0,%edi
  401174:	48 be 3c 20 40 00 00 	movabs $0x40203c,%rsi
  40117b:	00 00 00 
  40117e:	ba 40 00 00 00       	mov    $0x40,%edx
  401183:	0f 05                	syscall
  401185:	48 b8 3c 20 40 00 00 	movabs $0x40203c,%rax
  40118c:	00 00 00 
  40118f:	e8 a7 00 00 00       	call   0x40123b
  401194:	89 04 25 8c 20 40 00 	mov    %eax,0x40208c
  40119b:	48 0f b6 04 25 90 20 	movzbq 0x402090,%rax
  4011a2:	40 00 
  4011a4:	48 83 f8 2b          	cmp    $0x2b,%rax
  4011a8:	0f 84 52 fe ff ff    	je     0x401000
  4011ae:	48 83 f8 2d          	cmp    $0x2d,%rax
  4011b2:	0f 84 5e fe ff ff    	je     0x401016
  4011b8:	48 83 f8 2a          	cmp    $0x2a,%rax
  4011bc:	0f 84 69 fe ff ff    	je     0x40102b
  4011c2:	48 83 f8 2f          	cmp    $0x2f,%rax
  4011c6:	0f 84 74 fe ff ff    	je     0x401040
  4011cc:	b8 01 00 00 00       	mov    $0x1,%eax
  4011d1:	bf 01 00 00 00       	mov    $0x1,%edi
  4011d6:	48 be 24 20 40 00 00 	movabs $0x402024,%rsi
  4011dd:	00 00 00 
  4011e0:	ba 16 00 00 00       	mov    $0x16,%edx
  4011e5:	0f 05                	syscall
  4011e7:	b8 3c 00 00 00       	mov    $0x3c,%eax
  4011ec:	48 31 ff             	xor    %rdi,%rdi
  4011ef:	0f 05                	syscall
  4011f1:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  4011f8:	00 00 00 
  4011fb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  401200:	49 89 f8             	mov    %rdi,%r8
  401203:	85 c0                	test   %eax,%eax
  401205:	79 09                	jns    0x401210
  401207:	f7 d8                	neg    %eax
  401209:	41 c6 00 2d          	movb   $0x2d,(%r8)
  40120d:	49 ff c0             	inc    %r8
  401210:	bb 0a 00 00 00       	mov    $0xa,%ebx
  401215:	48 31 c9             	xor    %rcx,%rcx
  401218:	31 d2                	xor    %edx,%edx
  40121a:	f7 f3                	div    %ebx
  40121c:	80 c2 30             	add    $0x30,%dl
  40121f:	52                   	push   %rdx
  401220:	48 ff c1             	inc    %rcx
  401223:	85 c0                	test   %eax,%eax
  401225:	75 f1                	jne    0x401218
  401227:	58                   	pop    %rax
  401228:	41 88 00             	mov    %al,(%r8)
  40122b:	49 ff c0             	inc    %r8
  40122e:	e2 f7                	loop   0x401227
  401230:	41 c6 00 00          	movb   $0x0,(%r8)
  401234:	4c 89 c0             	mov    %r8,%rax
  401237:	48 29 f8             	sub    %rdi,%rax
  40123a:	c3                   	ret
  40123b:	53                   	push   %rbx
  40123c:	41 50                	push   %r8
  40123e:	41 51                	push   %r9
  401240:	48 31 c9             	xor    %rcx,%rcx
  401243:	ba 01 00 00 00       	mov    $0x1,%edx
  401248:	4d 31 c0             	xor    %r8,%r8
  40124b:	4d 31 c9             	xor    %r9,%r9
  40124e:	8a 1c 08             	mov    (%rax,%rcx,1),%bl
  401251:	80 fb 00             	cmp    $0x0,%bl
  401254:	74 3f                	je     0x401295
  401256:	80 fb 2d             	cmp    $0x2d,%bl
  401259:	74 2d                	je     0x401288
  40125b:	80 fb 2b             	cmp    $0x2b,%bl
  40125e:	74 23                	je     0x401283
  401260:	80 fb 20             	cmp    $0x20,%bl
  401263:	74 1e                	je     0x401283
  401265:	80 fb 30             	cmp    $0x30,%bl
  401268:	7c 2b                	jl     0x401295
  40126a:	80 fb 39             	cmp    $0x39,%bl
  40126d:	7f 26                	jg     0x401295
  40126f:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  401275:	80 eb 30             	sub    $0x30,%bl
  401278:	48 0f b6 db          	movzbq %bl,%rbx
  40127c:	4d 6b c0 0a          	imul   $0xa,%r8,%r8
  401280:	49 01 d8             	add    %rbx,%r8
  401283:	48 ff c1             	inc    %rcx
  401286:	eb c6                	jmp    0x40124e
  401288:	49 83 f9 01          	cmp    $0x1,%r9
  40128c:	74 07                	je     0x401295
  40128e:	f7 da                	neg    %edx
  401290:	48 ff c1             	inc    %rcx
  401293:	eb b9                	jmp    0x40124e
  401295:	4c 0f af c2          	imul   %rdx,%r8
  401299:	44 89 c0             	mov    %r8d,%eax
  40129c:	5b                   	pop    %rbx
  40129d:	41 58                	pop    %r8
  40129f:	41 59                	pop    %r9
  4012a1:	c3                   	ret
```

## objdump -s
```
Contents of section .text:
 401000 8b042588 2040008b 1c258c20 40004801  ..%. @...%. @.H.
 401010 d8e84300 00008b04 25882040 008b1c25  ..C.....%. @...%
 401020 8c204000 29d8e82e 0000008b 04258820  . @.)........%. 
 401030 40008b1c 258c2040 00f7e3e8 19000000  @...%. @........
 401040 48630425 88204000 48994863 1c258c20  Hc.%. @.H.Hc.%. 
 401050 4000f7fb e8000000 0048bf7c 20400000  @........H.| @..
 401060 000000e8 98010000 4989c4b8 01000000  ........I.......
 401070 bf010000 0048be1c 20400000 000000ba  .....H.. @......
 401080 08000000 0f05b801 000000bf 01000000  ................
 401090 48be7c20 40000000 00004c89 e20f05b8  H.| @.....L.....
 4010a0 01000000 bf010000 0048be3a 20400000  .........H.: @..
 4010b0 000000ba 01000000 0f05e928 010000b8  ...........(....
 4010c0 01000000 bf010000 0048be00 20400000  .........H.. @..
 4010d0 000000ba 09000000 0f05b800 000000bf  ................
 4010e0 00000000 48be3c20 40000000 0000ba40  ....H.< @......@
 4010f0 0000000f 0548b83c 20400000 000000e8  .....H.< @......
 401100 37010000 89042588 204000b8 01000000  7.....%. @......
 401110 bf010000 0048be09 20400000 000000ba  .....H.. @......
 401120 0a000000 0f05b800 000000bf 00000000  ................
 401130 48be3c20 40000000 0000ba40 0000000f  H.< @......@....
 401140 058a0425 3c204000 88042590 204000b8  ...%< @...%. @..
 401150 01000000 bf010000 0048be13 20400000  .........H.. @..
 401160 000000ba 09000000 0f05b800 000000bf  ................
 401170 00000000 48be3c20 40000000 0000ba40  ....H.< @......@
 401180 0000000f 0548b83c 20400000 000000e8  .....H.< @......
 401190 a7000000 8904258c 20400048 0fb60425  ......%. @.H...%
 4011a0 90204000 4883f82b 0f8452fe ffff4883  . @.H..+..R...H.
 4011b0 f82d0f84 5efeffff 4883f82a 0f8469fe  .-..^...H..*..i.
 4011c0 ffff4883 f82f0f84 74feffff b8010000  ..H../..t.......
 4011d0 00bf0100 000048be 24204000 00000000  ......H.$ @.....
 4011e0 ba160000 000f05b8 3c000000 4831ff0f  ........<...H1..
 4011f0 05662e0f 1f840000 0000000f 1f440000  .f...........D..
 401200 4989f885 c07909f7 d841c600 2d49ffc0  I....y...A..-I..
 401210 bb0a0000 004831c9 31d2f7f3 80c23052  .....H1.1.....0R
 401220 48ffc185 c075f158 41880049 ffc0e2f7  H....u.XA..I....
 401230 41c60000 4c89c048 29f8c353 41504151  A...L..H)..SAPAQ
 401240 4831c9ba 01000000 4d31c04d 31c98a1c  H1......M1.M1...
 401250 0880fb00 743f80fb 2d742d80 fb2b7423  ....t?..-t-..+t#
 401260 80fb2074 1e80fb30 7c2b80fb 397f2641  .. t...0|+..9.&A
 401270 b9010000 0080eb30 480fb6db 4d6bc00a  .......0H...Mk..
 401280 4901d848 ffc1ebc6 4983f901 7407f7da  I..H....I...t...
 401290 48ffc1eb b94c0faf c24489c0 5b415841  H....L...D..[AXA
 4012a0 59c3                                 Y.              
Contents of section .data:
 402000 44696769 7420313e 204f7065 7261746f  Digit 1> Operato
 402010 723e2044 69676974 20323e20 52657375  r> Digit 2> Resu
 402020 6c743e20 4e6f206f 70657261 746f7220  lt> No operator 
 402030 77617320 666f756e 640a0a             was found..     
```
