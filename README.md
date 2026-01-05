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
*   **Database**: PostgreSQL (Cloud-hosted via **Supabase**).

---

## Deployment Guide (Cloud)

This system is designed to be deployed to the cloud for real-time access from anywhere.

### 1. Database (Supabase)

1.  **Create Project**: Go to [Supabase](https://supabase.com/), create a new project, and note down your **Database Password**.
2.  **Get Credentials**: In Project Settings -> Database, copy the **Host**, **User**, **Port**, and **Database Name**.
3.  **Setup Tables**: The backend handles table creation automatically. Optionally, you can run the `backend/schema.sql` file in the Supabase SQL Editor as a backup.

### 2. Backend (Render)

1.  **Create Web Service**: Go to [Render](https://render.com/), connect your GitHub repo, and create a new **Web Service**.
2.  **Configuration**:
    *   **Root Directory**: `backend`
    *   **Build Command**: `npm install && npm run build`
    *   **Start Command**: `npm run start:prod`
    *   **Environment**: `Node`
3.  **Environment Variables**: Add these key/value pairs in Render:
    *   `NODE_ENV`: `production`
    *   `DB_HOST`: [Your Supabase Host]
    *   `DB_PORT`: `5432`
    *   `DB_USERNAME`: `postgres`
    *   `DB_PASSWORD`: [Your Supabase Password]
    *   `DB_NAME`: `postgres`
    *   `DB_SSL`: `true`

### 3. Frontend (Flutter App)

**Update Connection URL**:
1.  Once Render finishes deploying, copy your backend URL (e.g., `https://pos-backend.onrender.com`).
2.  Open `assets/config.json` in your source code.
3.  Update the `baseUrl`:
    ```json
    {
      "baseUrl": "https://pos-backend.onrender.com"
    }
    ```

**Build & Run**:
*   **Windows**:
    ```powershell
    flutter run -d windows --release
    ```
*   **Android** (Connect phone via USB):
    ```powershell
    flutter run -d android --release
    ```
