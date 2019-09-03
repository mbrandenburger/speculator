[BITS 64]
    %define SYS_EXIT 60
    %define SYS_WRITE 1
    %define SYS_OPEN 2
    %define SYS_CLOSE 3
    %define SYS_LSEEK 8
    %define SYS_GETCPU 309
    %define SYS_PREAD64 17
    %define SYS_PWRITE64 18
    %define CHILD_PROCESS 0
    %define ATTACK_PROCESS 4

    %define BASE 0x10000000

    %include "common.inc"
    %include "intel.inc"

    section .data

    dev_file: db '/dev/cpu/',VICTIM_PROCESS_STR,'/msr',0
    fd: dq 0
    val: dq 0
    len: equ $-val
    array: resb 2048
    secret: db 0
    addr: dq 0
    align 1024
    addr2: dq 0
    counter: dq 0
    align 1024
    ;##### DATA STARTS HERE ########

    ;##### DATA ENDS HERE ########

    section .text
    global perf_test_entry:function
    global snippet:function
    global gadget:function
    global poison:function

perf_test_entry:
    push rbp
    mov rbp, rsp
    sub rsp, 0

    check_pinning VICTIM_PROCESS ;# ATTACK_PROCESS
    msr_open
    msr_seek

    reset_counter

    call filler2

    start_counter

    call victim
    mov DWORD[array], eax
    mov DWORD[array+4], edx
    movq xmm0, QWORD[array]
    lfence

align 1024
victim:
    ;call myexit
    call filler
    push myexit
    clflush [rsp]
    lfence
    ret

filler:
    ;##### SNIPPET STARTS HERE ######

    ;##### SNIPPET ENDS HERE ######
    ret

align 1024
filler2:
    callnext
    callnext
    callnext
    callnext
    callnext
    callnext
    callnext
    callnext
    callnext
    callnext
    callnext
    callnext
    callnext
    callnext
    callnext
    callnext
    ret

align 1024
myexit:
    stop_counter
    msr_close
    exit 0

dummy:
    ret

