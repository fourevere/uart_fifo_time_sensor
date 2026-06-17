# UART FIFO Time Sensor

UART 명령과 버튼 입력으로 시계, 스톱워치, 초음파 거리 센서, DHT11 온습도 센서를 제어하고 결과를 FND/LED/UART로 표시하는 Vivado FPGA 프로젝트입니다.

## 개요

이 프로젝트는 Basys 3 보드 계열을 대상으로 한 Verilog 통합 실습입니다. UART RX로 받은 ASCII 명령과 보드 버튼 입력을 공통 제어 신호로 변환하고, 센서 데이터와 시간 데이터를 FIFO를 통해 UART TX로 전송합니다.

## 주요 기능

- UART 9600 bps 송수신
- RX/TX FIFO 버퍼링
- ASCII 명령 디코딩 및 센서/시간 데이터 ASCII 송신
- Watch, Stopwatch 모드
- HC-SR04 초음파 거리 측정
- DHT11 온습도 측정
- FND 표시와 LED 상태 표시
- 버튼 디바운스 및 스위치 기반 표시 모드 선택

## 프로젝트 구조

| 경로 | 내용 |
| --- | --- |
| `uart_fifo_time_sensor_final.xpr` | Vivado 프로젝트 파일 |
| `uart_fifo_time_sensor_final.srcs/sources_1/` | RTL 소스 |
| `uart_fifo_time_sensor_final.srcs/constrs_1/Basys-3-Master.xdc` | Basys 3 제약 파일 |

## 핵심 모듈

| 모듈 | 역할 |
| --- | --- |
| `top_uart_time_sensor` | UART, FIFO, 센서, 시계/스톱워치, FND를 연결하는 최상위 모듈 |
| `uart`, `uart_rx`, `uart_tx`, `baud_tick_gen` | UART 송수신 및 baud tick 생성 |
| `fifo`, `register_file`, `fifo_control_unit` | RX/TX 데이터 버퍼 |
| `ascii_decoder`, `ascii_sender`, `sender_data_splitter` | ASCII 명령 해석과 데이터 전송 포맷 구성 |
| `watch_datapath`, `watch_control_unit` | 시계 동작 |
| `stopwatch_datapath`, `stop_watch_control_unit` | 스톱워치 동작 |
| `sr04_controller`, `tick_gen_us` | HC-SR04 거리 센서 제어 |
| `dht11_controller`, `dht11_control_unit` | DHT11 온습도 센서 제어 |
| `fnd_controller` | FND multiplexing, digit split, BCD 표시 |
| `button_debounce`, `signal_decision` | 버튼/명령 입력 정리 및 모드 제어 |

## 입출력 요약

최상위 모듈 `top_uart_time_sensor`는 다음 신호를 사용합니다.

- 입력: `clk`, `rst`, `echo`, `btnR`, `btnL`, `btnU`, `btnD`, `sw[3:0]`, `rx`
- 출력: `tx`, `trig`, `fnd_data[7:0]`, `fnd_com[3:0]`, `led[7:0]`
- 양방향: `dht11`

## 사용 방법

Vivado에서 프로젝트 파일을 엽니다.

```text
uart_fifo_time_sensor_final.xpr
```

일반적인 작업 순서는 다음과 같습니다.

1. Vivado에서 프로젝트 열기
2. `top_uart_time_sensor`를 top module로 확인
3. `Basys-3-Master.xdc`에서 보드 핀 매핑 확인
4. Synthesis, Implementation, Bitstream 생성
5. UART 터미널을 9600 bps로 연결해 명령과 센서 데이터를 확인

## 개발 환경

- HDL: Verilog
- Tool: Xilinx Vivado
- Board/Constraint: Basys 3 계열
- UART: 9600 bps 기준

## License

별도 라이선스 파일이 없는 학습용 저장소입니다. 외부 사용 전 저장소 소유자에게 확인하세요.
