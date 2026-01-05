-- Enable UUID extension if needed (though we use serial IDs in Flutter, staying consistent is key)
-- But Drift uses autoIncrement integer, so we will use SERIAL/INTEGER GENERATED ALWAYS AS IDENTITY

-- Users Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    full_name TEXT,
    username TEXT UNIQUE,
    pin TEXT,
    role TEXT NOT NULL, -- "admin", "waiter", "kitchen", "bar", "kiosk"
    status TEXT DEFAULT 'active' NOT NULL,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL
);

-- Categories Table
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    menu_type TEXT DEFAULT 'dine-in' NOT NULL, -- "dine-in", "takeaway"
    sort_order INTEGER DEFAULT 0 NOT NULL,
    station TEXT, -- "kitchen", "bar"
    status TEXT DEFAULT 'active' NOT NULL
);

-- MenuItems Table
CREATE TABLE menu_items (
    id SERIAL PRIMARY KEY,
    code TEXT UNIQUE,
    name TEXT NOT NULL,
    price DOUBLE PRECISION NOT NULL,
    category_id INTEGER NOT NULL REFERENCES categories(id),
    station TEXT DEFAULT 'kitchen' NOT NULL, -- "kitchen", "bar"
    type TEXT DEFAULT 'dine-in' NOT NULL, -- "dine-in", "takeaway"
    status TEXT DEFAULT 'active' NOT NULL,
    allow_price_edit BOOLEAN DEFAULT FALSE NOT NULL
);

-- RestaurantTables Table
CREATE TABLE restaurant_tables (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    status TEXT DEFAULT 'available' NOT NULL, -- "available", "occupied"
    x INTEGER DEFAULT 0 NOT NULL,
    y INTEGER DEFAULT 0 NOT NULL
);

-- Orders Table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_number TEXT UNIQUE NOT NULL,
    table_number TEXT,
    type TEXT DEFAULT 'dine-in' NOT NULL, -- "dine-in", "takeaway"
    waiter_id INTEGER REFERENCES users(id),
    status TEXT DEFAULT 'pending' NOT NULL, -- "pending", "sent", "completed", "paid", "cancelled"
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    total_amount DOUBLE PRECISION DEFAULT 0.0 NOT NULL,
    tax_amount DOUBLE PRECISION DEFAULT 0.0 NOT NULL,
    service_amount DOUBLE PRECISION DEFAULT 0.0 NOT NULL,
    payment_method TEXT, -- "cash", "card", "mixed"
    tip_amount DOUBLE PRECISION DEFAULT 0.0 NOT NULL,
    tax_number TEXT,
    completed_at TIMESTAMP
);

-- OrderItems Table
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id),
    menu_item_id INTEGER NOT NULL REFERENCES menu_items(id),
    quantity INTEGER DEFAULT 1 NOT NULL,
    price_at_time DOUBLE PRECISION NOT NULL,
    status TEXT DEFAULT 'pending' NOT NULL -- "pending", "cooking", "ready", "served"
);

-- Printers Table (Missing in original backend)
CREATE TABLE printers (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    mac_address TEXT NOT NULL,
    role TEXT NOT NULL, -- "kitchen", "bar", "receipt"
    status TEXT DEFAULT 'active' NOT NULL
);

-- Settings Table (Missing in original backend)
CREATE TABLE settings (
    id SERIAL PRIMARY KEY,
    tax_rate DOUBLE PRECISION DEFAULT 0.0 NOT NULL,
    service_rate DOUBLE PRECISION DEFAULT 0.0 NOT NULL,
    currency_symbol TEXT DEFAULT '$' NOT NULL,
    kiosk_mode BOOLEAN DEFAULT FALSE NOT NULL,
    order_delay_threshold INTEGER DEFAULT 15 NOT NULL
);
