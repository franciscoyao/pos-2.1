# Restaurant POS System

A complete Point of Sale (POS) system designed for busy restaurants, featuring a Flutter-based multi-platform frontend (Windows, Android, iOS) and a robust NestJS backend with PostgreSQL.

## Features

*   **Multi-Role Dashboard**: Interfaces for Waiters, Kitchen, Bar, and Admin.
*   **Real-Time Synchronization**: Instant updates across all devices (Order status, Table occupancy, Menu changes).
*   **Offline-First**: Waiter apps work with a local database and sync automatically.
*   **Kitchen Display System (KDS)**: Dedicated view for kitchen staff to manage orders.
*   **Performance Optimized**: Efficient sync logic (active orders + recent history) to handle high volume.

## System Architecture

*   **Frontend**: Flutter (Windows Executable, Mobile Apps). Uses `Drift` for local SQLite storage.
*   **Backend**: NestJS (Node.js). Exposes REST APIs and WebSockets (`Socket.IO`).
*   **Database**: PostgreSQL (Containerized via Docker).

---

## Deployment Guide

### 1. Server Setup (The Computer)

To run the system, one computer must act as the "Server". This computer will host the database and the backend API.

**Prerequisites:**
*   [Docker Desktop](https://www.docker.com/products/docker-desktop/) (for the database).
*   [Node.js](https://nodejs.org/) (LTS version).
*   **Static IP**: Assign a static IP to this computer (e.g., `192.168.1.78`) in your router settings to ensure phones can always find it.

**Steps:**
1.  **Start Database**:
    Open a terminal in the `backend/` folder and run:
    ```powershell
    docker-compose up -d
    ```
    *Ensure Docker Desktop is running first.*

2.  **Start Backend**:
    In the same `backend/` folder, run:
    ```powershell
    npm install
    npm run start:prod
    ```
    The server is now listening at `http://<YOUR_IP>:3000`.

### 2. Client Setup (Windows POS)

The Windows application is the main terminal, usually running on the same computer as the server or another counter.

**Configuration:**
1.  Navigate to the build folder (or where you put the executable):
    `build/windows/x64/runner/Release/data/flutter_assets/assets/`
2.  Open `config.json` in a text editor.
3.  Set the `baseUrl` to your server's IP:
    ```json
    {
      "baseUrl": "http://192.168.1.78:3000"
    }
    ```

**Running:**
*   Double-click `pos_system.exe` in `build/windows/x64/runner/Release/`.

### 3. Client Setup (Mobile Waiter Apps)

**Configuration:**
1.  Connect your Android phone via USB.
2.  In the source code, open `assets/config.json`.
3.  Set the `baseUrl` to your server's IP (e.g., `http://192.168.1.78:3000`).
    *Note: Do not use `localhost` for phones; they must use the computer's actual Wi-Fi IP.*

**Install:**
Run the following command to install the release version on the connected phone:
```powershell
flutter run --release
```

## Troubleshooting

*   **"Connection Refused" on Phones**:
    *   Make sure the phone and computer are on the **same Wi-Fi network**.
    *   Check **Windows Firewall**. You may need to allow `Node.js` through the firewall on Private/Public networks.
    *   Ensure you are using the computer's IPv4 address (run `ipconfig` to check), not `localhost`.

*   **Docker Error**:
    *   If you see "pipe not found", start **Docker Desktop** application and wait for it to initialize.

*   **Data Not Syncing**:
    *   Check the server logs (`npm run start:dev` is better for debugging).
    *   Ensure the `baseUrl` in `config.json` is correct and includes port `:3000`.
