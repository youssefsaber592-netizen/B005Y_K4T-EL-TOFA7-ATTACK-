# ⚡ B005Y_K4T: EL TOFA7 ATTACK ⚡

A fast-paced 2D Arcade Time-Attack Platformer game built using **Godot 4**. The game challenges players to collect apples under strict time constraints, featuring dynamic game feels, persistent local storage, and real-time state management.

---

## 📸 Game Previews & Showcase

### 🎮 Main Menu Screen
The arcade-style main menu with custom pixel text, high-score tracking, and custom button themes.
<p align="center">
  <img src="project description/Screenshot 2026-06-26 085752.png" width="700" alt="Main Menu">
</p>

### 🍏 Gameplay & Juice Elements
Real-time animated notifications for picking up items, clearing levels, and managing intense level switches.
<p align="center">
  <img src="project description/Screenshot 2026-06-26 085629.png" width="45%" alt="Level Start">
  <img src="project description/Screenshot 2026-06-26 085804.png" width="45%" alt="Apple Collected">
</p>

<p align="center">
  <img src="project description/Screenshot 2026-06-26 085813.png" width="45%" alt="Level Cleared">
  <img src="project description/Screenshot 2026-06-26 085818.png" width="45%" alt="Level 2 Fight">
</p>

### 💀 Critical States & Victory
Dynamic system warnings for health drops, Game Over sequences, and ultimate Victory conditions.
<p align="center">
  <img src="project description/Screenshot 2026-06-26 085831.png" width="31%" alt="Heart Lost">
  <img src="project description/Screenshot 2026-06-26 085846.png" width="31%" alt="Last Heart Warning">
  <img src="project description/Screenshot 2026-06-26 085906.png" width="31%" alt="Victory Screen">
</p>

---

## 🎮 Key Features

* **Time Attack System:** Strictly managed timers optimized for gameplay tension (Level 1: 30s | Level 2: 45s).
* **Save System:** High score persistence across game sessions utilizing Godot's native `FileAccess` binary storage layer.
* **Juice & Game Feel:** Implemented dynamic camera screen shakes on impact/collection and animated asynchronous notification overlays using `Tweens`.
* **Anti-AFK Mechanism:** Programmatic player velocity tracking to prompt idle players.
* **State Management:** Automated scene reloading, dynamic progress calculation, and clean node memory layout cleanup via `queue_free()`.

## 🛠️ Tech Stack & Concepts Applied

* **Engine:** Godot 4.x (GDScript)
* **Architecture:** Node-based object hierarchy, strict signals/events decoupling, and asynchronous coroutines (`await`).
* **Clean Code:** Structured with scalability in mind, separating game loop systems from the HUD overlay interface.

## 🚀 How to Run Locally

1. Clone this repository:
   ```bash
   git clone[ (https://github.com/youssefsaber592-netizen/B005Y_K4T-EL-TOFA7-ATTACK-.git)
