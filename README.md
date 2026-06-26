# ⚡ B005Y_K4T: EL TOFA7 ATTACK ⚡

A fast-paced 2D Arcade Time-Attack Platformer game built using **Godot 4**. The game challenges players to collect apples under strict time constraints, featuring dynamic game feels, persistent local storage, and real-time state management.

---

## 📸 Game Previews & Showcase

### 🎮 Main Menu Screen
The arcade-style main menu with custom pixel text, high-score tracking, and custom button themes.
<p align="center">
  <img width="1280" height="720" alt="Screenshot 2026-06-26 085752" src="https://github.com/user-attachments/assets/fd774d9d-029c-4a0d-a75c-360c7496c036" />
</p>

### 🍏 Gameplay & Juice Elements
Real-time animated notifications for picking up items, clearing levels, and managing intense level switches.
<p align="center">
  <img width="45%" alt="Screenshot 2026-06-26 085629" src="https://github.com/user-attachments/assets/19c3dcfa-79a2-4bdb-8a64-fb8cd70a63d6" />
  <img width="45%" alt="Screenshot 2026-06-26 085804" src="https://github.com/user-attachments/assets/93448a8e-e814-41a3-b286-348e5bf62bc9" />
</p>

<p align="center">
  <img width="45%" alt="Screenshot 2026-06-26 085813" src="https://github.com/user-attachments/assets/55f641a4-5e14-4e85-a6c0-722e0f4e3cfe" />
  <img width="45%" alt="Screenshot 2026-06-26 085818" src="https://github.com/user-attachments/assets/c1cae440-1ee4-481a-841e-928df80df991" />
</p>

### 💀 Critical States & Victory
Dynamic system warnings for health drops, Game Over sequences, and ultimate Victory conditions.
<p align="center">
  <img width="31%" alt="Screenshot 2026-06-26 085831" src="https://github.com/user-attachments/assets/993ea78c-abac-4ddc-99e6-7ee1ad27f55c" />
  <img width="31%" alt="Screenshot 2026-06-26 085846" src="https://github.com/user-attachments/assets/1830bd40-4a6e-4757-85ba-34cef96c809a" />
  <img width="31%" alt="Screenshot 2026-06-26 085906" src="https://github.com/user-attachments/assets/7016197c-c076-4583-bc15-0da609981dc5" />
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
   git clone [https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git](https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git)
