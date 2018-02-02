# Project1

### Group:
Meghana Madineni (91978425) & Amrutha Chowdary Alaparthy (66905246)


## Optimal work unit size
With the workload of 10000 strings of length 15, a CPU utilization of consistent 65% on client side is attained. On the other hand, with the workload of 20000, the CPU utilization increased to 70% but was not consistent due to the network bottleneck. So the optimal workload might exist in the range of 10000 to 20000. This observation was noted down with the k value of 4 and with the server and client on different machines over the network. 

## Result for ./project1 4
  ```
  ./project1 4 
  "meghaname@192.168.0.101"
  {:ok, #PID<0.80.0>}
  true
  :yes
  Server started
  amrutha94;JRqpvI3pOdipHcA       0000593FC8CBFADBA0FB1328FED0010612A010D696093C3C9AF28C165EC38B66
  amrutha94;nF81nc6jGrlAWq-       00003A708B6D9B6F29F0EF3EAAA5383726A2A89A2F5F96AA645D6AF84D0D1C43
  amrutha94;XOyTdgXJYRwDQcm       0000842BE0C626D423BCD8FA9591FA19FE641108B915668340421B6A733C4848
  amrutha94;vdFjqTPqaJeE3En       00000C653D387B6A6A0ABB5581F6739919FEA376357AC3474A1476ADAFB672EC
  amrutha94;H9v1U1uWUSLBpvF       0000B3FB8659A5C4434DCCAFDA7565B31CFE1171A99867408C8419FD6D978A64
  amrutha94;6kTHJ6HerMcJuBE       000054B205633C6E21A913729F55CFEF16BBB7101389253BFC0A0C823AE57DAF
  amrutha94;rjd-2HGVGqSAEN0       0000DB9685B2926693BAB5853DA8B00215A09A316D2C0EF15427B710584135EB
  amrutha94;DDnYoRCXbNCrwdm       0000AD08540BAD5843BB48A270176CF9550CB72513C7EDE593946640E6763098
```


```
real    0m3.095s
user    0m10.549s
sys     0m0.031s
```

## Running Time
  ### for ./project1 4
  ```
  real    0m3.095s
  user    0m10.549s
  sys     0m0.031s
```
  ### for ./project1 5
  ```
  real    0m19.144s
  user    1m6.694s
  sys     0m0.015s
```
  ### CPU time to REAL time
  CPU time/Real time = 3.476

## Coin with most zeros we managed to find
```
escript ./project1 7
"meghaname@192.168.0.101"
{:ok, #PID<0.476.0>}
true
:yes
Server started
amrutha94;MZjRg 0000000B56A24B75CBD9F0F1EA8B4AA10A75C05880669448B46642AF022E9DDA
```
We managed to find a coin with 7 leading zeros.
  

## Number of working machines that we tried to connect
  We tested our code by connecting to 4 other individual machines including the storm server running 3 nodes on each machine. 

