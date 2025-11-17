<p align="center">
  <h1 align="center">Xilinx FPGA, Huskylens, GUI를 활용한 RC카✨</h1>
  <p align="center">
    <img width="20%" alt="시연 Gif" src="https://github.com/user-attachments/assets/125cc014-25e3-4e1c-aeda-743a71c58d50" />
  </p>
</p>

## Index ⭐️
- [1. Spec](#1-spec)
- [2. Block Diagram](#2-block-diagram)
- [3. Additional Functions with Two Sensors](#3-additional-functions-with-two-sensors)
- [4. GUI (MIT APP INVENTOR) with Bluetooth](#4-gui--mit-app-inventor--with-bluetooth)
- [5. Driving Algorithm with Huskylens](#5-driving-algorithm-with-huskylens)
- [6. Demonstration Video](#6-demonstration-video)

## 1. Spec
### Fastest RC Car with Sensor (Sensor Party!)
- Black Tape path를 따라가도록 구현
- Lap-time (Max 48pt) 1st - 48pt, 24th - 24pt
- Etc functions
  - Huskylens를 활용한 자율주행 + 15pt (랩 타임에 포함되는 Point)
  - 센서 사용 갯수 (각각 +1pt, 5개까지)
  - 무선 통신 구현 (+5pt) / GUI (+5pt)
- Presentation (35pt)
  - Block Diagram (5pt)
  - Presentation Skill (5pt)
  - Function (5pt 까지, 각각 5pt)
- 가장 도움을 많이 주는 두 개의 조는 각각 +5pt, +2pt 제공
- 키트나 센서를 파괴할 시, -5pt

## 2. Block Diagram
<table>
  <tr>
    <td align="center"><img width="100%" alt="Block Diagram" src="https://github.com/user-attachments/assets/2e7d7f98-7f2d-429b-824f-cdb8d816c211" /></td>
    <td align="center"><img width="100%" alt="RC Car" src="https://github.com/user-attachments/assets/e3650760-bdee-46af-aafb-3c858c573c0d" />
</td>
  </tr>
  <td align="center">Block Diagram</td>
  <td align="center">최종 RC카 외관 모습</td>
</table>

## 3. Additional Functions with Two Sensors
### Photoresistor for Headlight

<table>
  <tr>
    <td align="center"><img width="100%" alt="Photoresistor Test" src="https://github.com/user-attachments/assets/30231c39-1cc1-4a73-867a-5118dff0735f" /></td>
    <td align="center"><img width="70%" alt="Photoresistor Track Test" src="https://github.com/user-attachments/assets/80e12e4f-f827-4510-83aa-5fce6241013f" /></td>  
  </tr>
  <tr>
    <td align="center">조도센서 테스트</td>
    <td align="center">주행 시 조도센서 테스트</td>
  </tr>
</table>

- Xilinx XADC 모듈을 사용하여 아날로그 Input 처리
- XADC 모듈에서 DO Port 및 DRP(Dynamic Reconfiguration Port) Interface를 통해 Value를 받음
- AMD's UG480 Documentation 참고 ([AMD's UG480 Documentation📄](https://docs.amd.com/r/en-US/ug480_7Series_XADC))

<table align="center">
  <tr>
    <td align="center"><img width="100%" alt="do_out[15:4] value 1" src="https://github.com/user-attachments/assets/dcf13b76-2462-4bdb-a343-71d86b6b9f1e" /></td>
    <td align="center"><img width="100%" alt="do_out[15:4] value 2" src="https://github.com/user-attachments/assets/e922fbbb-fdcd-42b3-b44c-9eb0e5c4dbb6" /></td>
  </tr>
  <tr>
    <td align="center" colspan="2">Uart를 통해 시리얼 모니터로 do_out[15:4]값의 범위 확인</td>
  </tr>
</table>

### Ultrasonic for Distance-based Beeping Step Output

``` verilog
//...
   // Update beep period every time distance is updated
   always @(posedge clk) begin
      if (rst) begin
         beep_period <= 0;
      end else if (valid) begin
         if (distance < 10)
           beep_period <= 100000;   // very fast beep (~8ms)
         else if (distance < 15)
           beep_period <= 300000;   // ~25ms
         else if (distance < 20)
           beep_period <= 600000;   // 50ms
         else if (distance < 25)
           beep_period <= 1200000;  // 100ms
         else if (distance < 30)
           beep_period <= 2400000;  // 200ms
         else
           beep_period <= 32'hFFFFFFFF; // disable
      end
   end
//...
```

&nbsp;차량 전방에 장애물 등장시의 초음파센서를 통한 비프음 속도 조정 <br/>
- Distance < 30, Beep Period == 200ms
- Distance < 25, Beep Period == 100ms
- Distance < 20, Beep Period == 50ms
- Distance < 15, Beep Period == ~25ms
- Distance < 10, Beep Period == ~8ms (Very Fast!!!)

``` verilog
//...
   // Beep ON/OFF timing control
   always @(posedge clk) begin
      if (rst) begin
         beep_cnt <= 0;
         tone_en <= 0;
      end else if (beep_period == 32'hFFFFFFFF) begin
         tone_en <= 0;               // no sound
         beep_cnt <= 0;
      end else begin
         beep_cnt <= beep_cnt + 1;
         if (beep_cnt >= beep_period) begin
            beep_cnt <= 0;
            tone_en <= ~tone_en;    // toggle ON/OFF
         end
      end
   end

   // 800Hz tone generation
   always @(posedge clk) begin
      if (rst) begin
         tone_cnt <= 0;
         buzzer <= 0;
      end else if (!tone_en) begin
         tone_cnt <= 0;
         buzzer <= 0;
      end else begin
         tone_cnt <= tone_cnt + 1;
         if (tone_cnt < tone_period / 2)
           buzzer <= 1;
         else if (tone_cnt < tone_period)
           buzzer <= 0;
         else
           tone_cnt <= 0;
      end
   end
endmodule
//...
```

&nbsp; Cmod-s7의 12Mhz Clock을 이용해 800Hz Tone Generation <br/>
`beep_period`가 커질수록 토글 간격이 길어짐 <br/>

## 4. GUI(MIT APP INVENTOR) with Bluetooth
### GUI Interface

<table>
  <tr>
    <td align="center" colspan="2"><img width="70%" alt="Kartrider Rush Plus Image" src="https://github.com/user-attachments/assets/da615d76-5465-42f5-9c41-406ee90c0de8" /></td>
  </tr>
  <tr>
    <td align="center"><img width="100%" alt="MIT APP INVENTOR 1" src="https://github.com/user-attachments/assets/669568bd-82d4-4f4d-b769-73fca9d5e152" /></td>
    <td align="center"><img width="100%" alt="MIT APP INVENTOR 2" src="https://github.com/user-attachments/assets/8e99db48-79e0-435f-ad3e-87d4d30c4905" /></td>
  </tr>
</table>

- Motive : Kartrider Rush Plus
- 수동조작모드와 허스키렌즈를 통한 라인트래킹 자율주행 모드 구현
- 실시간으로 허스키렌즈의 화살표 벡터 값을 모니터링 할 수 있도록 구현
- 수동조작모드에서도 화살표 벡터 값 확인 가능

## 5. Driving Algorithm with Huskylens
### Driving Algorithm

<table>
  <tr>
    <td align="center"><img width="80%" alt="Huskylens Algorithm" src="https://github.com/user-attachments/assets/b242f461-aa9e-4232-8071-232e76f1908b" /></td>
  </tr>
  <tr>
    <td aligne="center">화살표 x, y 좌표만 사용</td>
  </tr>
</table>

``` verilog
//...
   wire signed [16:0] 			   dx = $signed(target_x) - $signed(origin_x);
   wire signed [16:0] 			   dy = $signed(target_y) - $signed(origin_y);

   wire 				   forward_enable  = (target_x > 16'd100 && target_x < 16'd200 && target_y <= 16'd130);
   wire 				   backward_enable = (target_x > 16'd100 && target_x < 16'd200 && target_y > 16'd130 && target_y < 16'd200);
   wire 				   left_enable     = (target_x < 16'd101);
   wire 				   right_enable    = (target_x > 16'd199 || suspicious_corner);
   wire 				   suspicious_corner = ((target_y > 16'd200 && target_y < 16'd240) || (dx > -30 && dx < 0 && dy > -30 && dy < 0));

   reg 					   turn_phase;
   reg [22:0] 				   cnt;
//...
```

- `target_x`와 `target_y`의 좌표값을 통해 전진, 후진, 좌, 우 결정

### For Bypass

<table>
  <tr>
    <td align="center"><img width="70%" alt="Bypass Path" src="https://github.com/user-attachments/assets/5a268ae8-4fb4-4c78-a954-390496a22902" /></td>
    <td align="center"><img width="100%" alt="Bypass Path Huskylens Vector" src="https://github.com/user-attachments/assets/056de300-0562-46d5-a9fe-a2ea61361b10" /></td>
  </tr>
</table>

&nbsp; 시간단축을 위해서, 좌측의 해당 곡선 구간을 Bypass로 직선처럼 뚫고 가도 된다고 하셨습니다.😅
그래서 왼쪽 가장자리에서 보이는 화살표의 벡터를 메뉴얼로 `suspicious_corner`로 잡고, 해당 구간의 벡터가 생성되었을 시, 우회전하도록 코드를 작성했습니다. (일종의 편법😂)

## Demonstration Video
- [시연](https://drive.google.com/file/d/1z0jZW0NXodH2Qp09Abp8ZEoy0Y-oiPmv/view?usp=share_link)
- [야간주행](https://drive.google.com/file/d/1WUIFHR_LId_Tm8nQf5J5kNpQTcRpVetm/view?usp=share_link)
