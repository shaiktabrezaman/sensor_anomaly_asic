# Persistence-Based Anomaly Detector for Structural Health Monitoring

## 1. Project Overview

The Persistence-Based Anomaly Detector for Structural Health Monitoring is a compact sequential digital circuit designed to detect persistent abnormal sensor readings using threshold-based detection, a persistence counter, and a finite-state machine (FSM).
And one small suggestion is that we don't mention as evidence heading. We'll keep the photos displayed to understand the flow properly rather than keeping everything, every heading inside evidence heading and turning it
The project follows the digital ASIC design flow, from Verilog RTL development and functional verification to logic synthesis, SKY130 standard-cell mapping, and gate-level simulation. Physical design and final GDS verification will be documented in subsequent sections.

**Design constraints**
- Target dimensions: 100 µm × 100 µm
- Technology: SKY130A
- Implementation: Standard cells only
- Macros: None

## 2. Project Objectives

- Design a synthesizable Verilog RTL module for persistent sensor-anomaly detection.
- Implement sequential logic using an FSM, registers, and a persistence counter.
- Verify the design through a self-checking testbench.
- Inspect simulation waveforms using GTKWave.
- Synthesize the RTL using Yosys.
- Map the design to SKY130 standard cells.
- Verify the synthesized netlist through gate-level simulation.
- Continue through physical design, timing analysis, and final GDS generation.

## 3. Real-World Application

Structural health monitoring systems use sensors to observe physical parameters in structures such as buildings and bridges. Persistent abnormal measurements can indicate conditions that require further investigation.

This project implements the digital decision-making block that detects threshold violations persisting for a defined number of clock cycles. It does not directly diagnose structural damage; it identifies abnormal sensor behavior for a larger monitoring system.

## 4. Design Functionality

The circuit includes:
- An 8-bit sensor-data input.
- A configurable threshold.
- Monitoring enable and active-low reset.
- Persistence-counting logic.
- FSM-based status control.
- Warning, critical, and event-detection outputs.

The persistence mechanism helps distinguish sustained abnormal readings from brief threshold excursions. Exact state transitions and recovery behavior are determined by the RTL implementation.

## 5. Technology and Tools

| Component | Tool or technology |
|---|---|
| Hardware description | Verilog HDL |
| RTL simulation | Icarus Verilog |
| Waveform inspection | GTKWave |
| Logic synthesis | Yosys |
| Standard-cell library | SKY130A |
| Gate-level simulation | Icarus Verilog and SKY130 simulation models |
| Physical design | OpenLane |
| Layout inspection | Magic |

## 6. Repository Structure

```text
Persistence-Based-Anomaly-Detector/
├── rtl/
│   └── sensor_anomaly_detector.v
├── tb/
│   └── tb_sensor_anomaly_detector.v
├── sim/
├── synthesis/
├── reports/
│   └── synthesis/
└── README.md
```

*Note: Update this structure to match the actual repository directories and filenames.*

## 7. RTL Design and Functional Verification

The design was implemented in Verilog HDL with sequential logic for persistence counting and FSM-based status control.

The self-checking testbench applies normal and abnormal sensor readings, exercises control signals, and checks the expected behavior.

### Evidence: RTL Design

<!-- Add your RTL source-code screenshot here. -->

### Evidence: RTL Simulation

<!-- Add your Icarus Verilog compilation and simulation output screenshot here. -->

## 8. Waveform Verification Using GTKWave

The generated Value Change Dump (VCD) file was opened in GTKWave to inspect the clock, reset, sensor input, FSM state, persistence counter, warning, critical, and event-detection signals.

Waveform inspection helps verify the sequence of state transitions and the relationship between sensor inputs and status outputs.

### Evidence: GTKWave Waveforms

<!-- Add your GTKWave waveform screenshot here. -->

## 9. Logic Synthesis Using Yosys

Yosys was used to synthesize the RTL and prepare the design for mapping to the SKY130A standard-cell library.

The synthesis process included design hierarchy analysis, logic optimization, technology mapping, structural checking, and cell statistics reporting.

### Reported Synthesis Results

- Generic Yosys cell count: 75 in the earlier synthesis checkpoint.
- Memory elements: 0.
- Processes remaining after synthesis: 0.
- Structural check: 0 reported problems.
- SKY130 standard-cell mapping: Completed.

These values describe the earlier recorded checkpoint. Update them if subsequent synthesis runs produce different results.

### Evidence: Yosys Synthesis

<!-- Add your Yosys synthesis output and cell-statistics screenshots here. -->

### Evidence: Synthesized Netlist

<!-- Add your mapped netlist or Yosys netlist-view screenshot here. -->

## 10. Gate-Level Simulation (GLS)

The synthesized netlist was simulated using Icarus Verilog with the required SKY130 simulation models and testbench.

Gate-level simulation checks the behavior of the mapped design rather than only the original RTL.

### Reported Verification Result

**13/13 gate-level tests passed** in the previously reported run.

### Evidence: GLS Results

<!-- Add your GLS terminal output showing the test results here. -->

### Evidence: GLS Waveforms

<!-- Add your GTKWave screenshot for the gate-level simulation here. -->

## 11. Physical Design: RTL to GDSII

The design was taken through the physical design flow using OpenLane and the SKY130A standard-cell technology. The flow included floorplanning, standard-cell placement, clock-tree synthesis (CTS), routing, and final layout generation.

**Design configuration**
- **Technology:** SKY130A
- **Target die dimensions:** 100 µm × 100 µm
- **Target clock period:** 15 ns (approximately 66.67 MHz)
- **Standard-cell library:** `sky130_fd_sc_hd`
- **Macros:** None

### 11.1 Floorplanning

Floorplanning establishes the die and core regions and prepares the design for physical implementation.

![Floorplan of the anomaly detector](evidence/screenshots/01_floorplan.png)

*Figure 1: Floorplan of the Persistence-Based Anomaly Detector.*

### 11.2 Standard-Cell Placement

During placement, the synthesized standard cells are positioned within the core to prepare for clock-tree construction and routing.

![Standard-cell placement](evidence/screenshots/02_placement.png)

*Figure 2: Standard-cell placement within the design area.*

### 11.3 Clock-Tree Synthesis

Clock-tree synthesis builds the clock distribution network required to deliver the clock signal to sequential elements.

![Clock-tree synthesis](evidence/screenshots/03_cts.png)

*Figure 3: Physical design after clock-tree synthesis.*

### 11.4 Routing

Routing establishes the physical interconnections between the placed standard cells. The resulting layout contains the signal and clock connections required by the implemented design.

![Routed design](evidence/screenshots/04_routing.png)

*Figure 4: Design after routing.*

### 11.5 Final Layout Inspection

The final layout was inspected using KLayout and Magic. These views provide a visual representation of the implemented standard cells, routing, and physical layout.

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

These are the results reported by the recorded flow. They should not be interpreted as independent foundry signoff or proof that every possible physical-design issue has been ruled out.

## 12. Static Timing Analysis

Static Timing Analysis (STA) was used to examine setup and hold timing at different process, voltage, and temperature (PVT) corners.

The 15 ns timing report contains pre-layout and post-layout results for 16 corners. The reported worst setup and hold slack values were:

| Timing metric | Worst corner | Pre-layout slack | Post-layout slack |
|---|---|---:|---:|
| Setup (maximum) | `ss_n40C_1v28` | +2.2256 ns | +1.9052 ns |
| Hold (minimum) | `ff_n40C_1v95` | +0.1844 ns | +0.1922 ns |

Positive slack indicates that the corresponding timing check passed under the constraints and conditions represented by that report.

The 15 ns clock period corresponds to a target frequency of approximately 66.67 MHz. These results apply to the reported 15 ns timing configuration; they should not be generalized to other clock periods or operating conditions.

The earlier 10 ns report showed a worst post-layout setup slack of −3.0948 ns at `ss_n40C_1v28`. The later 15 ns target provides a longer clock period, which relaxes the setup timing requirement.

Detailed timing results are available in:
- `evidence/sta_report.md`
- `evidence/sta_report_15ns.md`

The reports should be interpreted alongside the timing constraints, library warnings, and tool logs. Positive slack in these reports alone does not establish complete timing signoff.

## 13. Project Status and Future Work

The project has progressed through RTL development, functional verification, synthesis, gate-level simulation, and the physical design flow.

Potential next steps include:
- Reviewing timing and physical-verification reports.
- Confirming that the documented RTL, synthesized netlist, and physical-design outputs correspond to the intended project revision.
- Organizing reproducible commands, configuration files, and reports in the repository.
- Preparing the final project demonstration and documentation.
