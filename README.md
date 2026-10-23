# Persistence-Based Anomaly Detector for Structural Health Monitoring

## 1. Project Overview

The **Persistence-Based Anomaly Detector for Structural Health Monitoring** is a compact sequential digital circuit designed to detect persistent abnormal sensor readings using threshold-based detection, a persistence counter, and a finite-state machine (FSM).

The project follows a digital ASIC design flow, from Verilog RTL development and functional verification to logic synthesis, SKY130 standard-cell mapping, gate-level simulation, physical design, timing analysis, and GDSII generation.

**Design configuration**
- **Technology:** SKY130A
- **Target die dimensions:** 100 µm × 100 µm
- **Target clock period:** 15 ns (approximately 66.67 MHz)
- **Implementation:** Standard cells
- **Macros:** None

## 2. Project Objectives

- Design a synthesizable Verilog RTL module for persistent sensor-anomaly detection.
- Implement sequential logic using an FSM, registers, and a persistence counter.
- Verify the design using a testbench and simulation waveforms.
- Synthesize the RTL using Yosys and map it to SKY130 standard cells.
- Examine the mapped design through gate-level simulation.
- Run the OpenLane physical-design flow.
- Review timing and physical-verification reports.
- Generate and inspect the final GDSII layout.

## 3. Real-World Application

Structural health monitoring systems use sensors to observe physical parameters in structures such as buildings and bridges. Persistent abnormal measurements can indicate conditions that require further investigation.

This project implements a digital decision-making block that detects threshold violations persisting for a defined number of clock cycles. It does not directly diagnose structural damage; it identifies abnormal sensor behavior for a larger monitoring system.

## 4. Design Functionality

The design interface includes:
- An 8-bit sensor-data input.
- A configurable threshold.
- Monitoring enable and active-low reset.
- Persistence-counting logic.
- FSM-based status control.
- Warning, critical, and event-detection outputs.

The persistence mechanism is intended to distinguish sustained abnormal readings from brief threshold excursions. Exact state transitions and recovery behavior are defined by the RTL implementation.

## 5. Technology and Tools

| Component | Tool or technology |
|---|---|
| Hardware description | Verilog HDL |
| RTL simulation | Icarus Verilog |
| Waveform inspection | GTKWave |
| Logic synthesis | Yosys |
| Standard-cell library | SKY130A / `sky130_fd_sc_hd` |
| Gate-level simulation | Icarus Verilog with the required SKY130 simulation models |
| Physical design | OpenLane |
| Timing analysis | OpenSTA / STA scripts and reports |
| Layout inspection | Magic and KLayout |

## 6. Repository Structure

```text
sensor_anomaly_asic/
├── rtl/
│   └── sensor_anomaly_detector.v
├── tb/
│   └── tb_sensor_anomaly_detector.v
├── constraints/
│   └── sensor_anomaly_detector.sdc
├── openlane/
│   ├── config.tcl
│   ├── pin_order.cfg
│   ├── run_console.log
│   └── run_console2.log
├── evidence/
│   ├── screenshots/
│   │   ├── 01_floorplan.png
│   │   ├── 02_placement.png
│   │   ├── 03_cts.png
│   │   ├── 04_routing.png
│   │   ├── 05_final_layout_klayout.png
│   │   └── 06_final_layout_magic.png
│   ├── sta_report.md
│   └── sta_report_15ns.md
├── results/
│   ├── final_summary_report.csv
│   ├── sensor_anomaly_detector.gds
│   ├── sensor_anomaly_detector.spef
│   └── sensor_anomaly_detector.synthesis_preroute.v
├── timing/
│   ├── prelayout/
│   ├── postlayout/
│   └── run_sta.tcl
├── .gitignore
└── README.md
```

## 7. RTL Design and Functional Verification

The design was implemented in Verilog HDL using sequential logic for persistence counting and FSM-based status control. The testbench exercises the design by applying input patterns and control signals and checking the expected behavior.

The main RTL source is [`rtl/sensor_anomaly_detector.v`](rtl/sensor_anomaly_detector.v), and the testbench is [`tb/tb_sensor_anomaly_detector.v`](tb/tb_sensor_anomaly_detector.v).

## 8. Waveform Verification Using GTKWave

Simulation waveforms can be inspected in GTKWave to examine signals such as the clock, reset, sensor input, FSM state, persistence counter, warning, critical, and event-detection outputs. Waveform inspection helps show the relationship between sensor inputs, state transitions, and status outputs.

## 9. Logic Synthesis

Yosys was used for RTL synthesis and logic preparation. The earlier recorded synthesis checkpoint reported:
- **Generic Yosys cell count:** 75
- **Memory elements:** 0
- **Processes remaining after synthesis:** 0
- **Structural check:** 0 reported problems

These values refer to the earlier generic synthesis checkpoint. They are not the same as the number of technology-mapped SKY130 cells in the OpenLane flow.

The repository also contains a synthesized Verilog netlist at [`results/sensor_anomaly_detector.synthesis_preroute.v`](results/sensor_anomaly_detector.synthesis_preroute.v).

## 10. Gate-Level Simulation (GLS)

Gate-level simulation uses a synthesized netlist and the required SKY130 simulation models to check the behavior of the mapped design. This is distinct from simulation of the original RTL.

The previously recorded verification run reported **13/13 tests passed**. Confirm that this result corresponds to the exact netlist and testbench revision being documented before treating it as a result for the final OpenLane netlist.

## 11. Physical Design: RTL to GDSII

The design was taken through the OpenLane physical-design flow using the SKY130A standard-cell technology. The recorded flow includes floorplanning, standard-cell placement, clock-tree synthesis (CTS), routing, and final layout generation.

### 11.1 Floorplanning

Floorplanning defines the die and core regions and prepares the design for physical implementation.

![Floorplan of the anomaly detector](evidence/screenshots/01_floorplan.png)

*Figure 1: Floorplan of the Persistence-Based Anomaly Detector.*

### 11.2 Standard-Cell Placement

Placement positions the synthesized standard cells within the core before clock-tree construction and routing.

![Standard-cell placement](evidence/screenshots/02_placement.png)

*Figure 2: Standard-cell placement within the design area.*

### 11.3 Clock-Tree Synthesis

Clock-tree synthesis (CTS) builds the clock distribution network for sequential elements.

![Clock-tree synthesis](evidence/screenshots/03_cts.png)

*Figure 3: Physical design after clock-tree synthesis.*

### 11.4 Routing

Routing establishes physical interconnections between placed cells, including signal and clock connections.

![Routed design](evidence/screenshots/04_routing.png)

*Figure 4: Design after routing.*

### 11.5 Final Layout Inspection

The final layout was inspected using KLayout and Magic. These views show the implemented physical layout and routed geometry.

![Final layout in KLayout](evidence/screenshots/05_final_layout_klayout.png)

*Figure 5: Final layout viewed in KLayout.*

![Final layout in Magic](evidence/screenshots/06_final_layout_magic.png)

*Figure 6: Final layout viewed in Magic.*

### 11.6 Physical Verification

The recorded OpenLane run reported the following results:

| Check | Reported result |
|---|---|
| Magic DRC | 0 violations |
| LVS | 0 errors |
| Antenna checks | 0 pin and net violations |
| CVC | 0 total errors |

These are results reported by the recorded flow. They should not be interpreted as independent foundry signoff or proof that every possible physical-design issue has been ruled out.

The generated GDSII file is available at [`results/sensor_anomaly_detector.gds`](results/sensor_anomaly_detector.gds).

## 12. Static Timing Analysis

Static Timing Analysis (STA) was used to examine setup and hold timing at different process, voltage, and temperature (PVT) corners.

The 15 ns timing report contains pre-layout and post-layout results for 16 corners. The reported worst setup and hold slack values are:

| Timing metric | Worst corner | Pre-layout slack | Post-layout slack |
|---|---|---:|---:|
| Setup (maximum) | `ss_n40C_1v28` | +2.2256 ns | +1.9052 ns |
| Hold (minimum) | `ff_n40C_1v95` | +0.1844 ns | +0.1922 ns |

Positive slack indicates that the corresponding timing check passed under the constraints and conditions represented by the report.

The 15 ns clock period corresponds to a target frequency of approximately 66.67 MHz. These results apply to the reported 15 ns timing configuration and should not be generalized to other clock periods or operating conditions.

The earlier 10 ns report showed a worst post-layout setup slack of −3.0948 ns at `ss_n40C_1v28`. Moving to a 15 ns target provides a longer clock period and therefore relaxes the setup timing requirement; this is not, by itself, evidence of a hardware optimization.

Detailed reports:
- [`evidence/sta_report.md`](evidence/sta_report.md) — earlier timing report.
- [`evidence/sta_report_15ns.md`](evidence/sta_report_15ns.md) — timing report at 15 ns.

Interpret the reports alongside the timing constraints, library warnings, and tool logs. Positive slack in these reports alone does not establish complete timing signoff.

## 13. Project Status and Future Work

The repository contains the RTL and testbench, OpenLane configuration, physical-design screenshots, timing reports, and generated design outputs.

Potential next steps:
- Confirm that the documented RTL, synthesized netlist, timing reports, and GDSII correspond to the same intended design revision.
- Keep commands and configuration files needed to reproduce the flow.
- Add concise RTL simulation, synthesis, and gate-level simulation logs if they are available and verified.
- Prepare the final project demonstration and documentation.
